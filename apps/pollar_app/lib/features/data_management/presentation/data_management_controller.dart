import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/application/financial_data_revision.dart';
import '../application/backup_data_source.dart';
import '../application/data_backup_service.dart';
import '../domain/data_backup.dart';

final backupDataSourceProvider = Provider<BackupDataSource>((ref) {
  throw StateError('BackupDataSource was not configured');
});

final backupFileGatewayProvider = Provider<BackupFileGateway>((ref) {
  throw StateError('BackupFileGateway was not configured');
});

final dataBackupClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final dataBackupServiceProvider = Provider<DataBackupService>(
  (ref) => DataBackupService(
    ref.watch(backupDataSourceProvider),
    ref.watch(backupFileGatewayProvider),
  ),
);

final dataManagementProvider =
    AsyncNotifierProvider<DataManagementController, DataInventory>(
      DataManagementController.new,
    );

class DataManagementController extends AsyncNotifier<DataInventory> {
  @override
  Future<DataInventory> build() =>
      ref.watch(dataBackupServiceProvider).inventory();

  void retry() => ref.invalidateSelf();

  Future<BackupSaveResult> createBackup() => ref
      .read(dataBackupServiceProvider)
      .create(now: ref.read(dataBackupClockProvider)());

  Future<ValidatedBackup?> chooseBackup() =>
      ref.read(dataBackupServiceProvider).pickAndInspect();

  Future<void> restore(ValidatedBackup backup) async {
    await ref.read(dataBackupServiceProvider).restore(backup);
    ref.read(financialDataRevisionProvider.notifier).bump();
    ref.invalidateSelf();
  }
}
