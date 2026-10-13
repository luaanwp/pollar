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
  String? _inFlightUserId;

  Future<SyncOverview> overview() =>
      _local.overview(remoteConfigured: _remote != null);

  Future<SyncRunResult> synchronize({required DateTime now}) {
    if (_inFlight != null && _session.userId != _inFlightUserId) {
      return Future.error(
        const SyncUnavailableException(
          'A conta mudou durante a sincronização. Entre com a conta original para continuar.',
        ),
      );
    }
    _inFlightUserId = _session.userId;
    return _inFlight ??= _runAndClear(now);
  }

  Future<SyncRunResult> _runAndClear(DateTime now) async {
    try {
      return await _synchronize(now);
    } finally {
      _inFlight = null;
      _inFlightUserId = null;
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
    if (userId == null) {
      throw const SyncUnavailableException(
        'Entre na conta antes de sincronizar.',
      );
    }
    var identityChanged = false;
    final subscription = _session.identityChanges().listen(
      (id) {
        if (id != userId) identityChanged = true;
      },
      onError: (Object _, StackTrace _) {
        identityChanged = true;
      },
    );
    void requireOriginalIdentity() {
      if (identityChanged ||
          !_session.hasSession ||
          _session.userId != userId) {
        throw const SyncUnavailableException(
          'A conta mudou durante a sincronização. Entre com a conta original para continuar.',
        );
      }
    }

    var pending = <SyncMutation>[];
    var pushed = 0;
    var conflicts = 0;
    try {
      if (!await _local.bindIdentity(userId)) {
        throw const SyncUnavailableException(
          'Os dados deste dispositivo pertencem a outra conta. Entre com a conta original para continuar.',
        );
      }
      requireOriginalIdentity();
      pending = await _local.pending(now: now);
      requireOriginalIdentity();
      if (pending.isNotEmpty) {
        final deviceId = await _local.deviceId();
        requireOriginalIdentity();
        final results = await _remote.push(
          deviceId: deviceId,
          mutations: pending,
        );
        requireOriginalIdentity();
        pushed = results.where((result) => result.applied).length;
        conflicts += await _local.applyPushResults(pending, results);
      }
      const pageSize = 500;
      var cursor = await _local.cursor();
      var pulledCount = 0;
      while (true) {
        requireOriginalIdentity();
        final page = await _remote.pull(afterCursor: cursor, limit: pageSize);
        requireOriginalIdentity();
        if (page.changes.isNotEmpty && page.cursor <= cursor) {
          throw StateError('Sync pull did not advance the cursor.');
        }
        conflicts += await _local.applyRemote(page);
        pulledCount += page.changes.length;
        cursor = page.cursor;
        if (page.changes.length < pageSize) break;
      }
      final completedAt = now.toUtc();
      requireOriginalIdentity();
      await _local.markCompleted(cursor: cursor, completedAt: completedAt);
      return SyncRunResult(
        pushed: pushed,
        pulled: pulledCount,
        conflicts: conflicts,
        completedAt: completedAt,
      );
    } catch (_) {
      if (pending.isNotEmpty && !identityChanged && _session.userId == userId) {
        await _local.markAttemptFailed(pending, now: now.toUtc());
      }
      rethrow;
    } finally {
      await subscription.cancel();
    }
  }
}
