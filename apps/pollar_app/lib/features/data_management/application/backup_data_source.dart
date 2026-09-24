import '../domain/data_backup.dart';

abstract interface class BackupDataSource {
  Future<DataInventory> inventory();

  Future<Map<String, List<Map<String, Object?>>>> exportTables();

  void validateTables(Map<String, List<Map<String, Object?>>> tables);

  Future<void> restoreTables(Map<String, List<Map<String, Object?>>> tables);
}

abstract interface class BackupFileGateway {
  Future<BackupSaveResult> save(BackupDocument document);

  Future<PickedBackupFile?> pick();
}
