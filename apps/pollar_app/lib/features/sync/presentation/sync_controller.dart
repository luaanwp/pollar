import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/application/financial_data_revision.dart';
import '../application/sync_gateway.dart';
import '../application/sync_service.dart';
import '../domain/sync_models.dart';

final syncLocalStoreProvider = Provider<SyncLocalStore>((ref) {
  throw StateError('SyncLocalStore was not configured');
});

final syncRemoteGatewayProvider = Provider<SyncRemoteGateway?>((ref) => null);

final syncSessionAccessProvider = Provider<SyncSessionAccess>((ref) {
  throw StateError('SyncSessionAccess was not configured');
});

final syncClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    ref.watch(syncSessionAccessProvider),
    ref.watch(syncLocalStoreProvider),
    ref.watch(syncRemoteGatewayProvider),
  ),
);

final syncControllerProvider =
    AsyncNotifierProvider<SyncController, SyncOverview>(SyncController.new);

final syncConflictsProvider = FutureProvider<List<SyncConflictRecord>>(
  (ref) => ref.watch(syncLocalStoreProvider).conflicts(),
);

class SyncController extends AsyncNotifier<SyncOverview> {
  @override
  Future<SyncOverview> build() => ref.watch(syncServiceProvider).overview();

  Future<void> synchronize() async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(previous.copyWith(phase: SyncPhase.syncing));
    }
    try {
      final result = await ref
          .read(syncServiceProvider)
          .synchronize(now: ref.read(syncClockProvider)());
      ref.read(financialDataRevisionProvider.notifier).bump();
      ref.invalidate(syncConflictsProvider);
      final overview = await ref.read(syncServiceProvider).overview();
      state = AsyncData(
        overview.copyWith(
          message: result.conflicts > 0
              ? result.conflicts == 1
                    ? '1 conflito precisa de decisão.'
                    : '${result.conflicts} conflitos precisam de decisão.'
              : 'Sincronização concluída.',
        ),
      );
    } catch (error, stackTrace) {
      final overview = await ref.read(syncServiceProvider).overview();
      state = AsyncError(error, stackTrace);
      state = AsyncData(
        overview.copyWith(
          phase: SyncPhase.error,
          message: error is SyncUnavailableException ? error.message : 'Não foi possível sincronizar agora. As alterações continuam seguras neste dispositivo.',
        ),
      );
    }
  }

  Future<void> resolve(String id, {required bool keepLocal}) async {
    await ref
        .read(syncLocalStoreProvider)
        .resolveConflict(id, keepLocal: keepLocal);
    ref.read(financialDataRevisionProvider.notifier).bump();
    ref.invalidate(syncConflictsProvider);
    ref.invalidateSelf();
  }
}
