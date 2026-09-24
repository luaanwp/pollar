import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../domain/data_backup.dart';
import 'backup_data_source.dart';

const backupTableNames = <String>[
  'accounts',
  'transactions',
  'budgets',
  'recurring_rules',
  'wealth_goals',
  'wealth_assets',
  'wealth_debts',
];

class DataBackupService {
  const DataBackupService(this._source, this._files);

  static const format = 'pollar_backup';
  static const version = 1;
  static const databaseSchema = 5;

  final BackupDataSource _source;
  final BackupFileGateway _files;

  Future<DataInventory> inventory() => _source.inventory();

  Future<BackupSaveResult> create({required DateTime now}) async {
    final tables = await _source.exportTables();
    final createdAt = now.toUtc();
    final envelope = <String, Object?>{
      'format': format,
      'version': version,
      'database_schema': databaseSchema,
      'created_at': createdAt.toIso8601String(),
      'tables': tables,
    };
    final checksum = _checksum(envelope);
    final document = <String, Object?>{
      ...envelope,
      'checksum_sha256': checksum,
    };
    final stamp = createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    return _files.save(
      BackupDocument(
        fileName: 'pollar-backup-$stamp.json',
        contents: const JsonEncoder.withIndent('  ').convert(document),
      ),
    );
  }

  Future<ValidatedBackup?> pickAndInspect() async {
    final file = await _files.pick();
    if (file == null) return null;
    return inspect(file);
  }

  ValidatedBackup inspect(PickedBackupFile file) {
    final Object? decoded;
    try {
      decoded = jsonDecode(file.contents);
    } on FormatException {
      throw const BackupValidationException(
        'O arquivo não contém um backup JSON válido.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BackupValidationException(
        'O backup não tem uma estrutura válida.',
      );
    }
    if (decoded['format'] != format || decoded['version'] != version) {
      throw const BackupValidationException(
        'Este arquivo não é um backup compatível do Pollar.',
      );
    }
    if (decoded['database_schema'] != databaseSchema) {
      throw const BackupValidationException(
        'Este backup usa uma versão de dados incompatível.',
      );
    }
    final checksum = decoded['checksum_sha256'];
    if (checksum is! String || checksum.length != 64) {
      throw const BackupValidationException(
        'O backup não contém uma verificação válida.',
      );
    }
    final envelope = Map<String, Object?>.from(decoded)
      ..remove('checksum_sha256');
    if (_checksum(envelope) != checksum) {
      throw const BackupValidationException(
        'A verificação SHA-256 falhou. O arquivo pode ter sido alterado ou corrompido.',
      );
    }
    final createdAtValue = decoded['created_at'];
    final DateTime createdAt;
    try {
      createdAt = DateTime.parse(createdAtValue as String).toLocal();
    } catch (_) {
      throw const BackupValidationException(
        'A data de criação do backup é inválida.',
      );
    }
    final rawTables = decoded['tables'];
    if (rawTables is! Map<String, dynamic> ||
        rawTables.length != backupTableNames.length) {
      throw const BackupValidationException(
        'O backup não contém todas as tabelas esperadas.',
      );
    }
    final tables = <String, List<Map<String, Object?>>>{};
    for (final name in backupTableNames) {
      final rows = rawTables[name];
      if (rows is! List) {
        throw BackupValidationException('A tabela "$name" está inválida.');
      }
      final parsedRows = <Map<String, Object?>>[];
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          throw BackupValidationException(
            'A tabela "$name" contém um registro inválido.',
          );
        }
        parsedRows.add(Map<String, Object?>.from(row));
      }
      tables[name] = List.unmodifiable(parsedRows);
    }
    if (rawTables.keys.any((key) => !backupTableNames.contains(key))) {
      throw const BackupValidationException(
        'O backup contém tabelas desconhecidas.',
      );
    }
    _source.validateTables(tables);
    return ValidatedBackup(
      preview: BackupPreview(
        fileName: file.name,
        createdAt: createdAt,
        databaseSchema: databaseSchema,
        checksum: checksum,
        inventory: _inventoryFrom(tables),
      ),
      tables: Map.unmodifiable(tables),
    );
  }

  Future<void> restore(ValidatedBackup backup) =>
      _source.restoreTables(backup.tables);

  DataInventory _inventoryFrom(
    Map<String, List<Map<String, Object?>>> tables,
  ) => DataInventory(
    accounts: tables['accounts']!.length,
    transactions: tables['transactions']!.length,
    budgets: tables['budgets']!.length,
    recurringRules: tables['recurring_rules']!.length,
    wealthGoals: tables['wealth_goals']!.length,
    wealthAssets: tables['wealth_assets']!.length,
    wealthDebts: tables['wealth_debts']!.length,
  );

  String _checksum(Map<String, Object?> envelope) =>
      sha256.convert(utf8.encode(_canonicalJson(envelope))).toString();
}

String _canonicalJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return '{${keys.map((key) => '${jsonEncode(key)}:${_canonicalJson(value[key])}').join(',')}}';
  }
  if (value is List) {
    return '[${value.map(_canonicalJson).join(',')}]';
  }
  return jsonEncode(value);
}
