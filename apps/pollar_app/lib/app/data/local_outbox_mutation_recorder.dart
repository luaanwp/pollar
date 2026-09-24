import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../shared/application/local_mutation_recorder.dart';
import '../../shared/data/local_database.dart';

class LocalOutboxMutationRecorder implements LocalMutationRecorder {
  LocalOutboxMutationRecorder(this._database, {this._uuid = const Uuid()});

  final LocalDatabase _database;
  final Uuid _uuid;

  @override
  Future<void> recordUpsert({
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
  }) => _record(
    entityType: entityType,
    entityId: entityId,
    operation: 'upsert',
    payload: payload,
  );

  @override
  Future<void> recordDelete({
    required String entityType,
    required String entityId,
  }) => _record(
    entityType: entityType,
    entityId: entityId,
    operation: 'delete',
    payload: const {},
  );

  Future<void> _record({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
  }) async {
    final existing =
        await (_database.select(_database.syncOutboxEntries)
              ..where(
                (row) =>
                    row.entityType.equals(entityType) &
                    row.entityId.equals(entityId),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.occurredAtMicros)])
              ..limit(1))
            .getSingleOrNull();
    final metadata =
        await (_database.select(_database.syncMetadataEntries)..where(
              (row) =>
                  row.entityType.equals(entityType) &
                  row.entityId.equals(entityId),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (_database.update(
        _database.syncOutboxEntries,
      )..where((row) => row.id.equals(existing.id))).write(
        SyncOutboxEntriesCompanion(
          // An in-flight snapshot must keep its operation ID for server
          // idempotency; the newer local edit is a distinct operation.
          id: Value(_uuid.v4()),
          operation: Value(operation),
          payloadJson: Value(jsonEncode(payload)),
          occurredAtMicros: Value(
            DateTime.now().toUtc().microsecondsSinceEpoch,
          ),
          attemptCount: const Value(0),
          nextAttemptAtMicros: const Value(null),
          lastError: const Value(null),
        ),
      );
      return;
    }
    await _database
        .into(_database.syncOutboxEntries)
        .insert(
          SyncOutboxEntriesCompanion.insert(
            id: _uuid.v4(),
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: jsonEncode(payload),
            baseVersion: Value(metadata?.remoteVersion ?? 0),
            occurredAtMicros: DateTime.now().toUtc().microsecondsSinceEpoch,
          ),
        );
  }
}
