import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/sync/application/sync_gateway.dart';
import '../../features/sync/domain/sync_models.dart';
import '../../shared/data/local_database.dart';

class LocalSyncStore implements SyncLocalStore {
  LocalSyncStore(this._database, {this._uuid = const Uuid()});

  static const _runtimeId = 'primary';

  final LocalDatabase _database;
  final Uuid _uuid;

  @override
  Future<SyncOverview> overview({required bool remoteConfigured}) async {
    final pendingExpression = _database.syncOutboxEntries.id.count();
    final pendingQuery = _database.selectOnly(_database.syncOutboxEntries)
      ..addColumns([pendingExpression]);
    final conflictExpression = _database.syncConflictEntries.id.count();
    final conflictQuery = _database.selectOnly(_database.syncConflictEntries)
      ..addColumns([conflictExpression])
      ..where(_database.syncConflictEntries.resolvedAtMicros.isNull());
    final runtime = await _runtime();
    final pendingCount =
        (await pendingQuery.getSingle()).read(pendingExpression) ?? 0;
    final conflictCount =
        (await conflictQuery.getSingle()).read(conflictExpression) ?? 0;
    return SyncOverview(
      phase: !remoteConfigured
          ? SyncPhase.localOnly
          : conflictCount > 0
          ? SyncPhase.conflict
          : SyncPhase.idle,
      pendingCount: pendingCount,
      conflictCount: conflictCount,
      lastSyncedAt: runtime.lastSyncedAtMicros == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              runtime.lastSyncedAtMicros!,
              isUtc: true,
            ).toLocal(),
    );
  }

  @override
  Future<String> deviceId() async => (await _runtime()).deviceId;

  @override
  Future<int> cursor() async => (await _runtime()).remoteCursor;

  @override
  Future<bool> bindIdentity(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return false;
    return _database.transaction(() async {
      final runtime = await _runtime();
      if (runtime.boundUserId == null) {
        await (_database.update(_database.syncRuntimeEntries)
              ..where((row) => row.id.equals(_runtimeId)))
            .write(SyncRuntimeEntriesCompanion(boundUserId: Value(normalized)));
        return true;
      }
      return runtime.boundUserId == normalized;
    });
  }

  @override
  Future<List<SyncMutation>> pending({
    required DateTime now,
    int limit = 100,
  }) async {
    final nowMicros = now.toUtc().microsecondsSinceEpoch;
    final query = _database.select(_database.syncOutboxEntries)
      ..where(
        (row) =>
            row.nextAttemptAtMicros.isNull() |
            row.nextAttemptAtMicros.isSmallerOrEqualValue(nowMicros),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.occurredAtMicros)])
      ..limit(limit);
    return (await query.get())
        .map(
          (row) => SyncMutation(
            operationId: row.id,
            entityType: row.entityType,
            entityId: row.entityId,
            operation: row.operation,
            payload: Map<String, Object?>.from(
              jsonDecode(row.payloadJson) as Map,
            ),
            baseVersion: row.baseVersion,
            occurredAt: DateTime.fromMicrosecondsSinceEpoch(
              row.occurredAtMicros,
              isUtc: true,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<int> applyPushResults(
    List<SyncMutation> sent,
    List<PushMutationResult> results,
  ) async {
    final byOperation = {
      for (final result in results) result.operationId: result,
    };
    if (sent.any(
      (mutation) => !byOperation.containsKey(mutation.operationId),
    )) {
      throw StateError('The server omitted a sync mutation result.');
    }
    var conflicts = 0;
    await _database.transaction(() async {
      for (final mutation in sent) {
        final result = byOperation[mutation.operationId]!;
        if (result.applied) {
          await _upsertMetadata(
            entityType: result.entityType,
            entityId: result.entityId,
            remoteVersion: result.remoteVersion,
            deleted: mutation.operation == 'delete',
          );
          // A local edit may have replaced this operation while the request
          // was in flight. Keep that edit and base it on the acknowledged
          // server version so its next push does not conflict with itself.
          await (_database.update(_database.syncOutboxEntries)..where(
                (row) =>
                    row.entityType.equals(mutation.entityType) &
                    row.entityId.equals(mutation.entityId) &
                    row.id.isNotIn([mutation.operationId]),
              ))
              .write(
                SyncOutboxEntriesCompanion(
                  baseVersion: Value(result.remoteVersion),
                ),
              );
        } else {
          conflicts++;
          await _storeConflict(
            entityType: mutation.entityType,
            entityId: mutation.entityId,
            localPayload: mutation.payload,
            localOperation: mutation.operation,
            remotePayload: result.remotePayload ?? const {},
            remoteVersion: result.remoteVersion,
            remoteDeleted: result.remoteDeleted,
            reason: result.reason ?? 'remote_version_changed',
          );
        }
        await (_database.delete(
          _database.syncOutboxEntries,
        )..where((row) => row.id.equals(mutation.operationId))).go();
      }
    });
    return conflicts;
  }

  @override
  Future<int> applyRemote(PullResult result) async {
    var conflicts = 0;
    final latestByEntity = <String, RemoteChange>{};
    for (final change in result.changes) {
      final key = '${change.entityType}:${change.entityId}';
      final previous = latestByEntity[key];
      if (previous == null || change.version > previous.version) {
        latestByEntity[key] = change;
      }
    }
    final ordered = latestByEntity.values.toList()
      ..sort((a, b) {
        if (a.deleted != b.deleted) return a.deleted ? -1 : 1;
        if (a.entityType == b.entityType) return a.cursor.compareTo(b.cursor);
        return a.entityType == 'account' ? -1 : 1;
      });
    await _database.transaction(() async {
      for (final change in ordered) {
        final metadata = await _metadata(change.entityType, change.entityId);
        if (metadata != null && metadata.remoteVersion >= change.version) {
          continue;
        }
        final localMutation =
            await (_database.select(_database.syncOutboxEntries)
                  ..where(
                    (row) =>
                        row.entityType.equals(change.entityType) &
                        row.entityId.equals(change.entityId),
                  )
                  ..orderBy([(row) => OrderingTerm.desc(row.occurredAtMicros)])
                  ..limit(1))
                .getSingleOrNull();
        if (localMutation != null) {
          conflicts++;
          await _storeConflict(
            entityType: change.entityType,
            entityId: change.entityId,
            localPayload: Map<String, Object?>.from(
              jsonDecode(localMutation.payloadJson) as Map,
            ),
            localOperation: localMutation.operation,
            remotePayload: change.payload,
            remoteVersion: change.version,
            remoteDeleted: change.deleted,
            reason: 'concurrent_remote_change',
          );
          continue;
        }
        await _applyChange(change);
        await _upsertMetadata(
          entityType: change.entityType,
          entityId: change.entityId,
          remoteVersion: change.version,
          deleted: change.deleted,
        );
      }
    });
    return conflicts;
  }

  @override
  Future<void> markAttemptFailed(
    List<SyncMutation> mutations, {
    required DateTime now,
  }) async {
    await _database.transaction(() async {
      for (final mutation in mutations) {
        final row =
            await (_database.select(_database.syncOutboxEntries)
                  ..where((item) => item.id.equals(mutation.operationId)))
                .getSingleOrNull();
        if (row == null) continue;
        final attempts = row.attemptCount + 1;
        final delaySeconds = math.min(3600, 1 << math.min(attempts, 11));
        await (_database.update(
          _database.syncOutboxEntries,
        )..where((item) => item.id.equals(row.id))).write(
          SyncOutboxEntriesCompanion(
            attemptCount: Value(attempts),
            nextAttemptAtMicros: Value(
              now.add(Duration(seconds: delaySeconds)).microsecondsSinceEpoch,
            ),
            lastError: const Value('Falha de rede ou servidor'),
          ),
        );
      }
    });
  }

  @override
  Future<void> markCompleted({
    required int cursor,
    required DateTime completedAt,
  }) async {
    final runtime = await _runtime();
    await (_database.update(
      _database.syncRuntimeEntries,
    )..where((row) => row.id.equals(_runtimeId))).write(
      SyncRuntimeEntriesCompanion(
        remoteCursor: Value(math.max(runtime.remoteCursor, cursor)),
        lastSyncedAtMicros: Value(completedAt.toUtc().microsecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<List<SyncConflictRecord>> conflicts() async {
    final query = _database.select(_database.syncConflictEntries)
      ..where((row) => row.resolvedAtMicros.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.detectedAtMicros)]);
    final records = <SyncConflictRecord>[];
    for (final row in await query.get()) {
      records.add(
        SyncConflictRecord(
          id: row.id,
          entityType: row.entityType,
          entityId: row.entityId,
          localPayload: await _displayPayload(
            Map<String, Object?>.from(jsonDecode(row.localPayloadJson) as Map),
          ),
          remotePayload: await _displayPayload(
            Map<String, Object?>.from(jsonDecode(row.remotePayloadJson) as Map),
          ),
          detectedAt: DateTime.fromMicrosecondsSinceEpoch(
            row.detectedAtMicros,
            isUtc: true,
          ).toLocal(),
        ),
      );
    }
    return records;
  }

  Future<Map<String, Object?>> _displayPayload(
    Map<String, Object?> payload,
  ) async {
    final display = Map<String, Object?>.of(payload)
      ..remove('id')
      ..remove('installment_group_id')
      ..remove('statement_id');
    for (final entry in const {
      'account_id': 'account_name',
      'counter_account_id': 'counter_account_name',
    }.entries) {
      final accountId = display.remove(entry.key);
      if (accountId is! String) continue;
      final account = await (_database.select(
        _database.accountEntries,
      )..where((row) => row.id.equals(accountId))).getSingleOrNull();
      display[entry.value] = account?.name ?? 'Conta indisponível';
    }
    return display;
  }

  @override
  Future<void> resolveConflict(String id, {required bool keepLocal}) async {
    await _database.transaction(() async {
      final conflict = await (_database.select(
        _database.syncConflictEntries,
      )..where((row) => row.id.equals(id))).getSingleOrNull();
      if (conflict == null || conflict.resolvedAtMicros != null) {
        throw StateError('Sync conflict not found: $id');
      }
      await (_database.delete(_database.syncOutboxEntries)..where(
            (row) =>
                row.entityType.equals(conflict.entityType) &
                row.entityId.equals(conflict.entityId),
          ))
          .go();
      if (keepLocal) {
        await _database
            .into(_database.syncOutboxEntries)
            .insert(
              SyncOutboxEntriesCompanion.insert(
                id: _uuid.v4(),
                entityType: conflict.entityType,
                entityId: conflict.entityId,
                operation: conflict.localOperation,
                payloadJson: conflict.localPayloadJson,
                baseVersion: Value(conflict.remoteVersion),
                occurredAtMicros: DateTime.now().toUtc().microsecondsSinceEpoch,
              ),
            );
      } else {
        await _applyChange(
          RemoteChange(
            cursor: 0,
            entityType: conflict.entityType,
            entityId: conflict.entityId,
            version: conflict.remoteVersion,
            deleted: conflict.remoteDeleted,
            payload: Map<String, Object?>.from(
              jsonDecode(conflict.remotePayloadJson) as Map,
            ),
          ),
        );
        await _upsertMetadata(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          remoteVersion: conflict.remoteVersion,
          deleted: conflict.remoteDeleted,
        );
      }
      await (_database.update(
        _database.syncConflictEntries,
      )..where((row) => row.id.equals(id))).write(
        SyncConflictEntriesCompanion(
          resolvedAtMicros: Value(
            DateTime.now().toUtc().microsecondsSinceEpoch,
          ),
        ),
      );
    });
  }

  Future<StoredSyncRuntime> _runtime() async {
    final existing = await (_database.select(
      _database.syncRuntimeEntries,
    )..where((row) => row.id.equals(_runtimeId))).getSingleOrNull();
    if (existing != null) return existing;
    final runtime = StoredSyncRuntime(
      id: _runtimeId,
      deviceId: _uuid.v4(),
      remoteCursor: 0,
    );
    await _database
        .into(_database.syncRuntimeEntries)
        .insert(runtime.toCompanion(true));
    return runtime;
  }

  Future<StoredSyncMetadata?> _metadata(String entityType, String entityId) =>
      (_database.select(_database.syncMetadataEntries)..where(
            (row) =>
                row.entityType.equals(entityType) &
                row.entityId.equals(entityId),
          ))
          .getSingleOrNull();

  Future<void> _upsertMetadata({
    required String entityType,
    required String entityId,
    required int remoteVersion,
    required bool deleted,
  }) => _database
      .into(_database.syncMetadataEntries)
      .insertOnConflictUpdate(
        SyncMetadataEntriesCompanion.insert(
          entityType: entityType,
          entityId: entityId,
          remoteVersion: Value(remoteVersion),
          lastSyncedAtMicros: Value(
            DateTime.now().toUtc().microsecondsSinceEpoch,
          ),
          deleted: Value(deleted),
        ),
      );

  Future<void> _storeConflict({
    required String entityType,
    required String entityId,
    required Map<String, Object?> localPayload,
    required String localOperation,
    required Map<String, Object?> remotePayload,
    required int remoteVersion,
    required bool remoteDeleted,
    required String reason,
  }) => _database
      .into(_database.syncConflictEntries)
      .insert(
        SyncConflictEntriesCompanion.insert(
          id: _uuid.v4(),
          entityType: entityType,
          entityId: entityId,
          localPayloadJson: jsonEncode(localPayload),
          localOperation: Value(localOperation),
          remotePayloadJson: jsonEncode(remotePayload),
          remoteVersion: remoteVersion,
          remoteDeleted: Value(remoteDeleted),
          reason: reason,
          detectedAtMicros: DateTime.now().toUtc().microsecondsSinceEpoch,
        ),
      );

  Future<void> _applyChange(RemoteChange change) async {
    switch (change.entityType) {
      case 'account':
        return _applyAccount(change);
      case 'transaction':
        return _applyTransaction(change);
      default:
        throw StateError('Unsupported remote entity: ${change.entityType}');
    }
  }

  Future<void> _applyAccount(RemoteChange change) async {
    if (change.deleted) {
      await (_database.update(_database.accountEntries)
            ..where((row) => row.id.equals(change.entityId)))
          .write(const AccountEntriesCompanion(status: Value('archived')));
      return;
    }
    final value = change.payload;
    await _database
        .into(_database.accountEntries)
        .insertOnConflictUpdate(
          AccountEntriesCompanion.insert(
            id: value['id'] as String,
            name: value['name'] as String,
            type: value['type'] as String,
            currencyCode: value['currency_code'] as String,
            currencyDecimalDigits: value['currency_decimal_digits'] as int,
            currencySymbol: value['currency_symbol'] as String,
            openingBalanceMinor: value['opening_balance_minor'] as int,
            status: value['status'] as String,
            creditLimitMinor: Value(value['credit_limit_minor'] as int?),
            closingDay: Value(value['closing_day'] as int?),
            dueDay: Value(value['due_day'] as int?),
          ),
        );
  }

  Future<void> _applyTransaction(RemoteChange change) async {
    if (change.deleted) {
      await (_database.update(_database.transactionEntries)
            ..where((row) => row.id.equals(change.entityId)))
          .write(const TransactionEntriesCompanion(status: Value('cancelado')));
      return;
    }
    final value = change.payload;
    await _database
        .into(_database.transactionEntries)
        .insertOnConflictUpdate(
          TransactionEntriesCompanion.insert(
            id: value['id'] as String,
            description: value['description'] as String,
            type: value['type'] as String,
            status: value['status'] as String,
            amountMinor: value['amount_minor'] as int,
            currencyCode: value['currency_code'] as String,
            currencyDecimalDigits: value['currency_decimal_digits'] as int,
            currencySymbol: value['currency_symbol'] as String,
            accountId: value['account_id'] as String,
            counterAccountId: Value(value['counter_account_id'] as String?),
            occurredAtMicros: DateTime.parse(value['occurred_at'] as String)
                .toUtc()
                .microsecondsSinceEpoch,
            category: Value(value['category'] as String?),
            note: Value(value['note'] as String?),
            installmentGroupId: Value(value['installment_group_id'] as String?),
            installmentNumber: Value(value['installment_number'] as int?),
            installmentCount: Value(value['installment_count'] as int?),
            purchaseTotalMinor: Value(value['purchase_total_minor'] as int?),
            statementId: Value(value['statement_id'] as String?),
          ),
        );
  }
}
