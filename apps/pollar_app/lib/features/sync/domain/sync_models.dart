enum SyncPhase { localOnly, offline, idle, syncing, conflict, error }

class SyncMutation {
  const SyncMutation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.baseVersion,
    required this.occurredAt,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, Object?> payload;
  final int baseVersion;
  final DateTime occurredAt;

  Map<String, Object?> toRemoteJson() => {
    'operation_id': operationId,
    'entity_type': entityType,
    'entity_id': entityId,
    'operation': operation,
    'payload': payload,
    'base_version': baseVersion,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
  };
}

class PushMutationResult {
  const PushMutationResult({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.applied,
    required this.remoteVersion,
    this.remoteDeleted = false,
    this.remotePayload,
    this.reason,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final bool applied;
  final int remoteVersion;
  final bool remoteDeleted;
  final Map<String, Object?>? remotePayload;
  final String? reason;
}

class RemoteChange {
  const RemoteChange({
    required this.cursor,
    required this.entityType,
    required this.entityId,
    required this.version,
    required this.deleted,
    required this.payload,
  });

  final int cursor;
  final String entityType;
  final String entityId;
  final int version;
  final bool deleted;
  final Map<String, Object?> payload;
}

class PullResult {
  const PullResult({required this.cursor, required this.changes});

  final int cursor;
  final List<RemoteChange> changes;
}

class SyncOverview {
  const SyncOverview({
    required this.phase,
    required this.pendingCount,
    required this.conflictCount,
    this.lastSyncedAt,
    this.message,
  });

  final SyncPhase phase;
  final int pendingCount;
  final int conflictCount;
  final DateTime? lastSyncedAt;
  final String? message;

  SyncOverview copyWith({
    SyncPhase? phase,
    int? pendingCount,
    int? conflictCount,
    DateTime? lastSyncedAt,
    String? message,
  }) => SyncOverview(
    phase: phase ?? this.phase,
    pendingCount: pendingCount ?? this.pendingCount,
    conflictCount: conflictCount ?? this.conflictCount,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    message: message,
  );
}

class SyncRunResult {
  const SyncRunResult({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.completedAt,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
  final DateTime completedAt;
}

class SyncConflictRecord {
  const SyncConflictRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localPayload,
    required this.remotePayload,
    required this.detectedAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final Map<String, Object?> localPayload;
  final Map<String, Object?> remotePayload;
  final DateTime detectedAt;
}
