import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/data_management/application/backup_data_source.dart';
import 'package:pollar_app/features/data_management/application/data_backup_service.dart';
import 'package:pollar_app/features/data_management/domain/data_backup.dart';
import 'package:pollar_app/features/data_management/presentation/data_management_controller.dart';
import 'package:pollar_app/features/data_management/presentation/data_management_screen.dart';

void main() {
  testWidgets('shows inventory and creates a full backup', (tester) async {
    final fixture = await _Fixture.create();
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();

    expect(find.text('Dados e backup'), findsOneWidget);
    expect(find.text('Arquivo sem criptografia'), findsOneWidget);
    expect(find.text('2 registros'), findsOneWidget);
    expect(find.text('Criar backup'), findsOneWidget);

    await tester.tap(find.text('Criar backup'));
    await tester.pumpAndSettle();

    expect(fixture.files.saved, isNotNull);
    expect(find.textContaining('Backup criado em'), findsOneWidget);
  });

  testWidgets('previews verified contents before destructive restore', (
    tester,
  ) async {
    final fixture = await _Fixture.create();
    await fixture.preparePickedBackup();
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selecionar backup'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Substituir dados locais?'), findsOneWidget);
    expect(find.textContaining('SHA-256 verificado'), findsOneWidget);
    expect(find.text('Manter dados atuais'), findsOneWidget);
    expect(fixture.source.restoreCount, 0);

    await tester.tap(find.text('Substituir dados locais'));
    await tester.pump(const Duration(seconds: 1));

    expect(fixture.source.restoreCount, 1);
    expect(find.textContaining('Backup restaurado'), findsOneWidget);
  });

  testWidgets('supports 200 percent text without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final fixture = await _Fixture.create();

    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Criar backup'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Criar backup'), findsOneWidget);
  });
}

class _Fixture {
  _Fixture(this.source, this.files);

  final _Source source;
  final _Files files;

  static Future<_Fixture> create() async => _Fixture(_Source(), _Files());

  Future<void> preparePickedBackup() async {
    await DataBackupService(
      source,
      files,
    ).create(now: DateTime.utc(2026, 9, 24, 15, 30));
    files.picked = PickedBackupFile(
      name: files.saved!.fileName,
      contents: files.saved!.contents,
    );
  }

  Widget app() => ProviderScope(
    overrides: [
      backupDataSourceProvider.overrideWithValue(source),
      backupFileGatewayProvider.overrideWithValue(files),
      dataBackupClockProvider.overrideWithValue(
        () => DateTime.utc(2026, 9, 24, 15, 30),
      ),
    ],
    child: MaterialApp(
      theme: PollarTheme.light(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(body: DataManagementScreen()),
    ),
  );
}

class _Source implements BackupDataSource {
  var restoreCount = 0;

  final tables = <String, List<Map<String, Object?>>>{
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
    restoreCount++;
  }
}

class _Files implements BackupFileGateway {
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
