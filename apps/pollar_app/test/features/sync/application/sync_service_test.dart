import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/data/local_sync_store.dart';
import 'package:pollar_app/features/sync/application/sync_gateway.dart';
import 'package:pollar_app/features/sync/application/sync_service.dart';
import 'package:pollar_app/features/sync/domain/sync_models.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;
  late LocalSyncStore store;

  setUp(() {
    database = LocalDatabase(NativeDatabase.memory());
    store = LocalSyncStore(database);
  });
  tearDown(() => database.close());

  test(
    'identity change during pull discards response and completion',
    () async {
      final session = _MutableSession();
      addTearDown(session.changes.close);
      final remote = _BlockingRemote(
        result: PullResult(
          cursor: 1,
          changes: [
            RemoteChange(
              cursor: 1,
              entityType: 'account',
              entityId: 'remote-account',
              version: 1,
              deleted: true,
              payload: const {},
            ),
          ],
        ),
      );
      final service = SyncService(session, store, remote);
      final run = service.synchronize(now: DateTime.utc(2026, 10, 6));
      await remote.started.future;
      session.currentUserId = 'user-two';
      final assertion = expectLater(
        run,
        throwsA(isA<SyncUnavailableException>()),
      );
      remote.release.complete();
      await assertion;
      expect(
        (await store.overview(remoteConfigured: true)).lastSyncedAt,
        isNull,
      );
      expect(await store.bindIdentity('user-two'), isFalse);
      expect(await store.cursor(), 0);
      expect(
        await database.select(database.syncMetadataEntries).get(),
        isEmpty,
      );
    },
  );

  test('another identity cannot join the previous synchronization', () async {
    final session = _MutableSession();
    addTearDown(session.changes.close);
    final remote = _BlockingRemote();
    final service = SyncService(session, store, remote);
    final run = service.synchronize(now: DateTime.utc(2026, 10, 6));
    await remote.started.future;
    session.currentUserId = 'user-two';
    final assertion = expectLater(
      run,
      throwsA(isA<SyncUnavailableException>()),
    );
    final joined = expectLater(
      service.synchronize(now: DateTime.utc(2026, 10, 6)),
      throwsA(isA<SyncUnavailableException>()),
    );
    remote.release.complete();
    await Future.wait([assertion, joined]);
  });

  test(
    'leaving and returning to the same identity aborts the old run',
    () async {
      final session = _MutableSession();
      addTearDown(session.changes.close);
      final remote = _BlockingRemote();
      final service = SyncService(session, store, remote);
      final run = service.synchronize(now: DateTime.utc(2026, 10, 6));
      await remote.started.future;
      session.currentUserId = null;
      session.currentUserId = 'user-one';
      final assertion = expectLater(
        run,
        throwsA(isA<SyncUnavailableException>()),
      );
      remote.release.complete();
      await assertion;
      expect(
        (await store.overview(remoteConfigured: true)).lastSyncedAt,
        isNull,
      );
      await service.synchronize(now: DateTime.utc(2026, 10, 6));
      expect(
        (await store.overview(remoteConfigured: true)).lastSyncedAt,
        isNotNull,
      );
    },
  );

  test('pulls every page before reporting completion', () async {
    final remote = _PagedRemote();
    final now = DateTime.utc(2026, 9, 24);

    final result = await SyncService(
      const _Session(),
      store,
      remote,
    ).synchronize(now: now);

    expect(remote.requestedCursors, [0, 500]);
    expect(result.pulled, 501);
    expect(await store.cursor(), 501);
    expect(
      (await store.overview(remoteConfigured: true)).lastSyncedAt,
      now.toLocal(),
    );
  });

  test('failed later page resumes from the atomically saved cursor', () async {
    final remote = _PagedRemote(failSecondPageOnce: true);
    final service = SyncService(const _Session(), store, remote);
    final now = DateTime.utc(2026, 9, 24);

    await expectLater(service.synchronize(now: now), throwsStateError);
    expect(await store.cursor(), 500);
    expect((await store.overview(remoteConfigured: true)).lastSyncedAt, isNull);

    final result = await service.synchronize(now: now);
    expect(remote.requestedCursors, [0, 500, 500]);
    expect(result.pulled, 1);
    expect(await store.cursor(), 501);
  });

  test('concurrent requests share one synchronization run', () async {
    final remote = _BlockingRemote();
    final service = SyncService(const _Session(), store, remote);
    final now = DateTime.utc(2026, 9, 24);

    final first = service.synchronize(now: now);
    await remote.started.future;
    final second = service.synchronize(now: now);
    expect(identical(first, second), isTrue);
    remote.release.complete();
    await Future.wait([first, second]);
    expect(remote.pullCalls, 1);

    await service.synchronize(now: now);
    expect(remote.pullCalls, 2);
  });
}

class _Session implements SyncSessionAccess {
  const _Session();

  @override
  bool get isConfigured => true;
  @override
  bool get hasSession => true;
  @override
  String? get userId => 'user-one';
  @override
  String? get email => 'user@example.test';
  @override
  Stream<String?> identityChanges() => Stream.value(userId);
  @override
  Future<void> signOut() async {}
}

class _MutableSession implements SyncSessionAccess {
  final changes = StreamController<String?>.broadcast(sync: true);
  String? _currentUserId = 'user-one';
  String? get currentUserId => _currentUserId;
  set currentUserId(String? value) {
    _currentUserId = value;
    changes.add(value);
  }

  @override
  Stream<String?> identityChanges() => changes.stream;
  @override
  bool get isConfigured => true;
  @override
  bool get hasSession => currentUserId != null;
  @override
  String? get userId => currentUserId;
  @override
  String? get email => 'test@example.test';
  @override
  Future<void> signOut() async {
    currentUserId = null;
  }
}

class _PagedRemote implements SyncRemoteGateway {
  _PagedRemote({this.failSecondPageOnce = false});

  bool failSecondPageOnce;
  final requestedCursors = <int>[];

  @override
  Future<PullResult> pull({required int afterCursor, int limit = 500}) async {
    requestedCursors.add(afterCursor);
    if (afterCursor == 500 && failSecondPageOnce) {
      failSecondPageOnce = false;
      throw StateError('connection lost');
    }
    final end = afterCursor + limit > 501 ? 501 : afterCursor + limit;
    return PullResult(
      cursor: end,
      changes: [
        for (var value = afterCursor + 1; value <= end; value++)
          RemoteChange(
            cursor: value,
            entityType: 'account',
            entityId: 'checking-main',
            version: value,
            deleted: true,
            payload: const {},
          ),
      ],
    );
  }

  @override
  Future<List<PushMutationResult>> push({
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async => const [];
}

class _BlockingRemote implements SyncRemoteGateway {
  _BlockingRemote({this.result});

  final PullResult? result;
  final started = Completer<void>();
  final release = Completer<void>();
  int pullCalls = 0;

  @override
  Future<PullResult> pull({required int afterCursor, int limit = 500}) async {
    pullCalls++;
    if (!started.isCompleted) started.complete();
    await release.future;
    return result ?? PullResult(cursor: afterCursor, changes: const []);
  }

  @override
  Future<List<PushMutationResult>> push({
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async => const [];
}
