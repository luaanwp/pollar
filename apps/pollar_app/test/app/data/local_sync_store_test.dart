import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/data/local_outbox_mutation_recorder.dart';
import 'package:pollar_app/app/data/local_sync_store.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/data/drift_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/features/sync/domain/sync_models.dart';
import 'package:pollar_app/shared/application/local_mutation_recorder.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;

  setUp(() => database = LocalDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  Account account({String name = 'Conta principal'}) => Account(
    id: '8b65c52e-bf2d-4979-8611-a87903594278',
    name: name,
    type: AccountType.checking,
    currency: Currency.brl,
    openingBalance: const Money(minorUnits: 10000, currency: Currency.brl),
  );

  test('account and outbox entry commit atomically', () async {
    final repository = DriftAccountRepository(
      database,
      mutationRecorder: LocalOutboxMutationRecorder(database),
    );

    await repository.add(account());

    final outbox = await database.select(database.syncOutboxEntries).get();
    expect(outbox, hasLength(1));
    expect(outbox.single.entityType, 'account');
    expect(outbox.single.entityId, account().id);
    expect(outbox.single.baseVersion, 0);
    expect(outbox.single.payloadJson, contains('Conta principal'));

    await repository.replace(account(name: 'Conta revisada'));
    final coalesced = await database.select(database.syncOutboxEntries).get();
    expect(coalesced, hasLength(1));
    expect(coalesced.single.payloadJson, contains('Conta revisada'));
  });

  test('recorder failure rolls the financial write back', () async {
    final repository = DriftAccountRepository(
      database,
      mutationRecorder: const _FailingRecorder(),
    );

    await expectLater(repository.add(account()), throwsStateError);

    expect(await database.select(database.accountEntries).get(), isEmpty);
  });

  test('acknowledgement clears outbox and stores remote version', () async {
    final repository = DriftAccountRepository(
      database,
      mutationRecorder: LocalOutboxMutationRecorder(database),
    );
    final store = LocalSyncStore(database);
    await repository.add(account());
    final pending = await store.pending(now: DateTime.now());

    final conflicts = await store.applyPushResults(pending, [
      PushMutationResult(
        operationId: pending.single.operationId,
        entityType: 'account',
        entityId: account().id,
        applied: true,
        remoteVersion: 1,
      ),
    ]);

    expect(conflicts, 0);
    expect(await store.pending(now: DateTime.now()), isEmpty);
    final metadata = await database.select(database.syncMetadataEntries).get();
    expect(metadata.single.remoteVersion, 1);
  });

  test(
    'edit during push survives acknowledgement as a new operation',
    () async {
      final repository = DriftAccountRepository(
        database,
        mutationRecorder: LocalOutboxMutationRecorder(database),
      );
      final store = LocalSyncStore(database);
      await repository.add(account());
      final inFlight = await store.pending(now: DateTime.now());

      await repository.replace(account(name: 'Editada durante o envio'));
      final edited = await store.pending(now: DateTime.now());
      expect(edited, hasLength(1));
      expect(edited.single.operationId, isNot(inFlight.single.operationId));

      await store.applyPushResults(inFlight, [
        PushMutationResult(
          operationId: inFlight.single.operationId,
          entityType: 'account',
          entityId: account().id,
          applied: true,
          remoteVersion: 1,
        ),
      ]);

      final remaining = await store.pending(now: DateTime.now());
      expect(remaining, hasLength(1));
      expect(remaining.single.operationId, edited.single.operationId);
      expect(remaining.single.payload['name'], 'Editada durante o envio');
      expect(remaining.single.baseVersion, 1);
    },
  );

  test('local ledger binds once and rejects a different account', () async {
    final store = LocalSyncStore(database);

    expect(await store.bindIdentity('user-one'), isTrue);
    expect(await store.bindIdentity('user-one'), isTrue);
    expect(await store.bindIdentity('user-two'), isFalse);
  });

  test('remote tombstone is preserved through conflict resolution', () async {
    final repository = DriftAccountRepository(
      database,
      mutationRecorder: LocalOutboxMutationRecorder(database),
    );
    final store = LocalSyncStore(database);
    await repository.add(account());

    expect(
      await store.applyRemote(
        PullResult(
          cursor: 4,
          changes: [
            RemoteChange(
              cursor: 4,
              entityType: 'account',
              entityId: account().id,
              version: 2,
              deleted: true,
              payload: const {},
            ),
          ],
        ),
      ),
      1,
    );
    final conflict =
        (await database.select(database.syncConflictEntries).get()).single;
    expect(conflict.remoteDeleted, isTrue);

    await store.resolveConflict(conflict.id, keepLocal: false);

    expect(
      (await repository.findById(account().id))?.status,
      AccountStatus.archived,
    );
    expect(
      (await database.select(database.syncMetadataEntries).get())
          .single
          .deleted,
      isTrue,
    );
    expect(await database.select(database.syncOutboxEntries).get(), isEmpty);
  });

  test(
    'rejected push preserves local edits until conflict resolution',
    () async {
      final repository = DriftAccountRepository(
        database,
        mutationRecorder: LocalOutboxMutationRecorder(database),
      );
      final store = LocalSyncStore(database);
      await repository.add(account(name: 'Versão local'));
      final sent = await store.pending(now: DateTime.now());
      final remote2 = {...sent.single.payload, 'name': 'Versão remota 2'};

      expect(
        await store.applyPushResults(sent, [
          PushMutationResult(
            operationId: sent.single.operationId,
            entityType: 'account',
            entityId: account().id,
            applied: false,
            remoteVersion: 2,
            remotePayload: remote2,
          ),
        ]),
        1,
      );
      expect(
        await store.applyRemote(
          PullResult(
            cursor: 4,
            changes: [
              RemoteChange(
                cursor: 4,
                entityType: 'account',
                entityId: account().id,
                version: 2,
                deleted: false,
                payload: remote2,
              ),
            ],
          ),
        ),
        0,
      );
      expect((await repository.findById(account().id))?.name, 'Versão local');
      expect(await store.cursor(), 4);
      expect(await store.conflicts(), hasLength(1));

      await repository.replace(account(name: 'Edição após conflito'));
      expect(await store.pending(now: DateTime.now()), isEmpty);
      expect(
        (await store.conflicts()).single.localPayload['name'],
        'Edição após conflito',
      );
      final remote3 = {...remote2, 'name': 'Versão remota 3'};
      expect(
        await store.applyRemote(
          PullResult(
            cursor: 5,
            changes: [
              RemoteChange(
                cursor: 5,
                entityType: 'account',
                entityId: account().id,
                version: 3,
                deleted: false,
                payload: remote3,
              ),
            ],
          ),
        ),
        0,
      );
      final conflict =
          (await database.select(database.syncConflictEntries).get()).single;
      expect(conflict.remoteVersion, 3);
      expect(conflict.remotePayloadJson, contains('Versão remota 3'));
      expect(
        (await repository.findById(account().id))?.name,
        'Edição após conflito',
      );

      await store.resolveConflict(conflict.id, keepLocal: true);
      final remaining = await store.pending(now: DateTime.now());
      expect(remaining, hasLength(1));
      expect(remaining.single.payload['name'], 'Edição após conflito');
      expect(remaining.single.baseVersion, 3);
      expect(await store.conflicts(), isEmpty);
    },
  );
}

class _FailingRecorder implements LocalMutationRecorder {
  const _FailingRecorder();

  @override
  Future<void> recordDelete({
    required String entityType,
    required String entityId,
  }) async {
    throw StateError('outbox unavailable');
  }

  @override
  Future<void> recordUpsert({
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
  }) async {
    throw StateError('outbox unavailable');
  }
}
