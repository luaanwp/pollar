import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/data_management/application/backup_data_source.dart';
import 'package:pollar_app/features/data_management/application/data_backup_service.dart';
import 'package:pollar_app/features/data_management/domain/data_backup.dart';

void main() {
  final now = DateTime.utc(2026, 9, 24, 15, 30);

  test('creates a deterministic, versioned backup with SHA-256', () async {
    final source = _MemorySource(_tables());
    final files = _MemoryFiles();
    final service = DataBackupService(source, files);

    final first = await service.create(now: now);
    final firstContents = files.saved!.contents;
    final second = await service.create(now: now);

    expect(first.path, second.path);
    expect(
      files.saved!.fileName,
      'pollar-backup-2026-09-24T15-30-00-000Z.json',
    );
    expect(files.saved!.contents, firstContents);
    final decoded = jsonDecode(firstContents) as Map<String, dynamic>;
    expect(decoded['format'], DataBackupService.format);
    expect(decoded['version'], DataBackupService.version);
    expect(decoded['database_schema'], DataBackupService.databaseSchema);
    expect(decoded['checksum_sha256'], hasLength(64));
  });

  test('inspects a created backup and restores the validated tables', () async {
    final source = _MemorySource(_tables());
    final files = _MemoryFiles();
    final service = DataBackupService(source, files);
    await service.create(now: now);
    files.picked = PickedBackupFile(
      name: files.saved!.fileName,
      contents: files.saved!.contents,
    );

    final backup = await service.pickAndInspect();
    expect(backup, isNotNull);
    expect(backup!.preview.inventory.accounts, 1);
    expect(backup.preview.inventory.transactions, 1);
    expect(backup.preview.createdAt.toUtc(), now);

    await service.restore(backup);
    expect(source.restored, backup.tables);
  });

  test('rejects a backup changed after its checksum was generated', () async {
    final files = _MemoryFiles();
    final service = DataBackupService(_MemorySource(_tables()), files);
    await service.create(now: now);
    final tampered = files.saved!.contents.replaceFirst(
      'Conta principal',
      'Conta alterada',
    );

    expect(
      () => service.inspect(
        PickedBackupFile(name: 'alterado.json', contents: tampered),
      ),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.message,
          'message',
          contains('SHA-256'),
        ),
      ),
    );
  });

  test('rejects malformed and incompatible files before restore', () {
    final service = DataBackupService(_MemorySource(_tables()), _MemoryFiles());

    expect(
      () => service.inspect(
        const PickedBackupFile(name: 'texto.json', contents: 'não é json'),
      ),
      throwsA(isA<BackupValidationException>()),
    );
    expect(
      () => service.inspect(
        const PickedBackupFile(
          name: 'outro.json',
          contents: '{"format":"outro","version":1}',
        ),
      ),
      throwsA(isA<BackupValidationException>()),
    );
  });
}

Map<String, List<Map<String, Object?>>> _tables() => {
  'accounts': [
    {'id': 'account-1', 'name': 'Conta principal'},
  ],
  'transactions': [
    {'id': 'transaction-1'},
  ],
  'budgets': [],
  'recurring_rules': [],
  'wealth_goals': [],
  'wealth_assets': [],
  'wealth_debts': [],
};

class _MemorySource implements BackupDataSource {
  _MemorySource(this.tables);

  final Map<String, List<Map<String, Object?>>> tables;
  Map<String, List<Map<String, Object?>>>? restored;

  @override
  Future<Map<String, List<Map<String, Object?>>>> exportTables() async =>
      tables;

  @override
  Future<DataInventory> inventory() async => const DataInventory(
    accounts: 1,
    transactions: 1,
    budgets: 0,
    recurringRules: 0,
    wealthGoals: 0,
    wealthAssets: 0,
    wealthDebts: 0,
  );

  @override
  void validateTables(Map<String, List<Map<String, Object?>>> tables) {}

  @override
  Future<void> restoreTables(
    Map<String, List<Map<String, Object?>>> tables,
  ) async {
    restored = tables;
  }
}

class _MemoryFiles implements BackupFileGateway {
  BackupDocument? saved;
  PickedBackupFile? picked;

  @override
  Future<PickedBackupFile?> pick() async => picked;

  @override
  Future<BackupSaveResult> save(BackupDocument document) async {
    saved = document;
    return BackupSaveResult(path: 'C:\\Downloads\\${document.fileName}');
  }
}
