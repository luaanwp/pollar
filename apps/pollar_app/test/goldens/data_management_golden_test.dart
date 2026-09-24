import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'));
    final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
      ..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
    await Future.wait([inter.load(), lucide.load()]);
  });

  Future<void> render(WidgetTester tester, Size size, String golden) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(_Source(), _Files()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'data management compact 390x844',
    (tester) =>
        render(tester, const Size(390, 844), 'data_management_390x844.png'),
  );

  testWidgets(
    'data management wide 1200x900',
    (tester) =>
        render(tester, const Size(1200, 900), 'data_management_1200x900.png'),
  );

  testWidgets('data management compact at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_app(_Source(), _Files()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('data_management_text_200_390x844.png'),
    );
  });

  testWidgets('restore preview compact', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = _Source();
    final files = _Files();
    await DataBackupService(
      source,
      files,
    ).create(now: DateTime.utc(2026, 9, 24, 15, 30));
    files.picked = PickedBackupFile(
      name: files.saved!.fileName,
      contents: files.saved!.contents,
    );
    await tester.pumpWidget(_app(source, files));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selecionar backup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('data_management_restore_390x844.png'),
    );
  });
}

Widget _app(_Source source, _Files files) => ProviderScope(
  overrides: [
    backupDataSourceProvider.overrideWithValue(source),
    backupFileGatewayProvider.overrideWithValue(files),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: PollarTheme.light(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: const Scaffold(body: DataManagementScreen()),
  ),
);

class _Source implements BackupDataSource {
  final tables = <String, List<Map<String, Object?>>>{
    'accounts': List.generate(4, (index) => {'id': 'account-$index'}),
    'transactions': List.generate(128, (index) => {'id': 'transaction-$index'}),
    'budgets': List.generate(3, (index) => {'id': 'budget-$index'}),
    'recurring_rules': List.generate(5, (index) => {'id': 'rule-$index'}),
    'wealth_goals': List.generate(2, (index) => {'id': 'goal-$index'}),
    'wealth_assets': List.generate(6, (index) => {'id': 'asset-$index'}),
    'wealth_debts': List.generate(1, (index) => {'id': 'debt-$index'}),
  };

  @override
  Future<Map<String, List<Map<String, Object?>>>> exportTables() async =>
      tables;

  @override
  Future<DataInventory> inventory() async => const DataInventory(
    accounts: 4,
    transactions: 128,
    budgets: 3,
    recurringRules: 5,
    wealthGoals: 2,
    wealthAssets: 6,
    wealthDebts: 1,
  );

  @override
  void validateTables(Map<String, List<Map<String, Object?>>> tables) {}

  @override
  Future<void> restoreTables(
    Map<String, List<Map<String, Object?>>> tables,
  ) async {}
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
