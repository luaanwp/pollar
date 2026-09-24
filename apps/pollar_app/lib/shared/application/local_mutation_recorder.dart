abstract interface class LocalMutationRecorder {
  Future<void> recordUpsert({
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
  });

  Future<void> recordDelete({
    required String entityType,
    required String entityId,
  });
}

class NoopLocalMutationRecorder implements LocalMutationRecorder {
  const NoopLocalMutationRecorder();

  @override
  Future<void> recordUpsert({
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
  }) async {}

  @override
  Future<void> recordDelete({
    required String entityType,
    required String entityId,
  }) async {}
}
