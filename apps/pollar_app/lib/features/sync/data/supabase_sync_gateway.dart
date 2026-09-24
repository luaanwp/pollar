import 'package:supabase_flutter/supabase_flutter.dart';

import '../application/sync_gateway.dart';
import '../domain/sync_models.dart';

class SupabaseSyncGateway implements SyncRemoteGateway {
  const SupabaseSyncGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PushMutationResult>> push({
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async {
    final response = await _client.rpc(
      'apply_sync_mutations',
      params: {
        'p_device_id': deviceId,
        'p_mutations': mutations.map((item) => item.toRemoteJson()).toList(),
      },
    );
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows
        .map(
          (row) => PushMutationResult(
            operationId: row['operation_id'] as String,
            entityType: row['entity_type'] as String,
            entityId: row['entity_id'] as String,
            applied: row['applied'] as bool,
            remoteVersion: row['remote_version'] as int,
            remoteDeleted: row['remote_deleted'] as bool? ?? false,
            remotePayload: _map(row['remote_payload']),
            reason: row['reason'] as String?,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<PullResult> pull({required int afterCursor, int limit = 500}) async {
    final response = await _client.rpc(
      'pull_sync_changes',
      params: {'p_after_cursor': afterCursor, 'p_limit': limit},
    );
    final envelope = Map<String, dynamic>.from(response as Map);
    final changes = (envelope['changes'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (row) => RemoteChange(
            cursor: row['cursor'] as int,
            entityType: row['entity_type'] as String,
            entityId: row['entity_id'] as String,
            version: row['version'] as int,
            deleted: row['deleted'] as bool,
            payload: _map(row['payload']) ?? const {},
          ),
        )
        .toList(growable: false);
    return PullResult(cursor: envelope['cursor'] as int, changes: changes);
  }

  Map<String, Object?>? _map(Object? value) => value == null
      ? null
      : Map<String, Object?>.from(value as Map<dynamic, dynamic>);
}
