class DataInventory {
  const DataInventory({
    required this.accounts,
    required this.transactions,
    required this.budgets,
    required this.recurringRules,
    required this.wealthGoals,
    required this.wealthAssets,
    required this.wealthDebts,
  });

  final int accounts;
  final int transactions;
  final int budgets;
  final int recurringRules;
  final int wealthGoals;
  final int wealthAssets;
  final int wealthDebts;

  int get planningRecords => budgets + recurringRules;
  int get wealthRecords => wealthGoals + wealthAssets + wealthDebts;
  int get totalRecords =>
      accounts + transactions + planningRecords + wealthRecords;
}

class BackupDocument {
  const BackupDocument({required this.fileName, required this.contents});

  final String fileName;
  final String contents;
}

class BackupSaveResult {
  const BackupSaveResult({required this.path});

  final String path;
}

class PickedBackupFile {
  const PickedBackupFile({required this.name, required this.contents});

  final String name;
  final String contents;
}

class BackupPreview {
  const BackupPreview({
    required this.fileName,
    required this.createdAt,
    required this.databaseSchema,
    required this.checksum,
    required this.inventory,
  });

  final String fileName;
  final DateTime createdAt;
  final int databaseSchema;
  final String checksum;
  final DataInventory inventory;
}

class ValidatedBackup {
  const ValidatedBackup({required this.preview, required this.tables});

  final BackupPreview preview;
  final Map<String, List<Map<String, Object?>>> tables;
}

class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
