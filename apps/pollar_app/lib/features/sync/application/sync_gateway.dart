import '../domain/sync_models.dart';

abstract interface class SyncSessionAccess {
  bool get isConfigured;

  bool get hasSession;

  String? get userId;

  String? get email;

  Future<void> signOut();
}

abstract interface class SyncRemoteGateway {
  Future<List<PushMutationResult>> push({
    required String deviceId,
    required List<SyncMutation> mutations,
  });

  Future<PullResult> pull({required int afterCursor, int limit = 500});
}

abstract interface class SyncLocalStore {
  Future<SyncOverview> overview({required bool remoteConfigured});

  Future<String> deviceId();

  Future<int> cursor();

  Future<bool> bindIdentity(String userId);

  Future<List<SyncMutation>> pending({required DateTime now, int limit = 100});

  Future<int> applyPushResults(
    List<SyncMutation> sent,
    List<PushMutationResult> results,
  );

  Future<int> applyRemote(PullResult result);

  Future<void> markAttemptFailed(
    List<SyncMutation> mutations, {
    required DateTime now,
  });

  Future<void> markCompleted({
    required int cursor,
    required DateTime completedAt,
  });

  Future<List<SyncConflictRecord>> conflicts();

  Future<void> resolveConflict(String id, {required bool keepLocal});
}
