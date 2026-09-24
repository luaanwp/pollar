import '../domain/sync_models.dart';
import 'sync_gateway.dart';

class SyncUnavailableException implements Exception {
  const SyncUnavailableException(this.message);

  final String message;
}

class SyncService {
  SyncService(this._session, this._local, this._remote);

  final SyncSessionAccess _session;
  final SyncLocalStore _local;
  final SyncRemoteGateway? _remote;
  Future<SyncRunResult>? _inFlight;

  Future<SyncOverview> overview() =>
      _local.overview(remoteConfigured: _remote != null);

  Future<SyncRunResult> synchronize({required DateTime now}) =>
      _inFlight ??= _runAndClear(now);

  Future<SyncRunResult> _runAndClear(DateTime now) async {
    try {
      return await _synchronize(now);
    } finally {
      _inFlight = null;
    }
  }

  Future<SyncRunResult> _synchronize(DateTime now) async {
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
      const pageSize = 500;
      var cursor = await _local.cursor();
      var pulledCount = 0;
      while (true) {
        final page = await _remote.pull(afterCursor: cursor, limit: pageSize);
        if (page.changes.isNotEmpty && page.cursor <= cursor) {
          throw StateError('Sync pull did not advance the cursor.');
        }
        conflicts += await _local.applyRemote(page);
        pulledCount += page.changes.length;
        cursor = page.cursor;
        if (page.changes.length < pageSize) break;
      }
      final completedAt = now.toUtc();
      await _local.markCompleted(cursor: cursor, completedAt: completedAt);
      return SyncRunResult(
        pushed: pushed,
        pulled: pulledCount,
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
