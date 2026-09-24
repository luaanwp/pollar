import '../domain/sync_models.dart';
import 'sync_gateway.dart';

class SyncUnavailableException implements Exception {
  const SyncUnavailableException(this.message);

  final String message;
}

class SyncService {
  const SyncService(this._session, this._local, this._remote);

  final SyncSessionAccess _session;
  final SyncLocalStore _local;
  final SyncRemoteGateway? _remote;

  Future<SyncOverview> overview() =>
      _local.overview(remoteConfigured: _remote != null);

  Future<SyncRunResult> synchronize({required DateTime now}) async {
    if (_remote == null || !_session.isConfigured) {
      throw const SyncUnavailableException(
        'Configure o Supabase para sincronizar entre dispositivos.',
      );
    }
    if (!_session.hasSession) {
      throw const SyncUnavailableException(
        'Entre na conta antes de sincronizar.',
      );
    }
    final userId = _session.userId;
    if (userId == null || !await _local.bindIdentity(userId)) {
      throw const SyncUnavailableException(
        'Os dados deste dispositivo pertencem a outra conta. Entre com a conta original para continuar.',
      );
    }
    final pending = await _local.pending(now: now);
    var pushed = 0;
    var conflicts = 0;
    try {
      if (pending.isNotEmpty) {
        final results = await _remote.push(
          deviceId: await _local.deviceId(),
          mutations: pending,
        );
        pushed = results.where((result) => result.applied).length;
        conflicts += await _local.applyPushResults(pending, results);
      }
      final pulled = await _remote.pull(afterCursor: await _local.cursor());
      conflicts += await _local.applyRemote(pulled);
      final completedAt = now.toUtc();
      await _local.markCompleted(
        cursor: pulled.cursor,
        completedAt: completedAt,
      );
      return SyncRunResult(
        pushed: pushed,
        pulled: pulled.changes.length,
        conflicts: conflicts,
        completedAt: completedAt,
      );
    } catch (_) {
      if (pending.isNotEmpty) {
        await _local.markAttemptFailed(pending, now: now.toUtc());
      }
      rethrow;
    }
  }
}
