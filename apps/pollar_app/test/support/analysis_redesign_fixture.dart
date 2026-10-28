import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/reports/application/report_data_source.dart';
import 'package:pollar_app/features/reports/application/report_exporter.dart';
import 'package:pollar_app/features/reports/presentation/reports_controller.dart';
import 'package:pollar_app/features/reports/presentation/reports_screen.dart';
import 'package:pollar_app/features/wealth/application/wealth_ledger_source.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_asset.dart';
import 'package:pollar_app/features/wealth/domain/wealth_debt.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_controller.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_screen.dart';

import 'report_fixture.dart';
import 'wealth_fixture.dart';

const longAnalysisName =
    'Reserva para cuidados continuados e assistência familiar';
const longAnalysisCategory =
    'Saúde e assistência familiar com acompanhamento continuado';
Money _brl(int value) => Money(minorUnits: value, currency: Currency.brl);

Widget analysisRedesignApp({
  required bool wealth,
  bool dark = false,
  bool hidden = false,
  bool reduced = false,
  bool long = false,
  bool empty = false,
  double? contentWidth,
  ReportExporter? exporter,
}) => ProviderScope(
  overrides: [
    privacyModeProvider.overrideWith(() => _InitialPrivacy(hidden)),
    reportClockProvider.overrideWithValue(() => reportFixtureNow),
    reportDataSourceProvider.overrideWithValue(
      _AnalysisReportSource(long: long, empty: empty),
    ),
    reportExporterProvider.overrideWithValue(
      exporter ?? RecordingAnalysisExporter(),
    ),
    wealthClockProvider.overrideWithValue(() => wealthFixtureNow),
    wealthLedgerSourceProvider.overrideWithValue(
      _AnalysisWealthSource(long: long, empty: empty),
    ),
    wealthRepositoryProvider.overrideWithValue(
      empty
          ? InMemoryWealthRepository()
          : long
          ? _longWealthRepository()
          : createWealthFixtureRepository(),
    ),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: PollarTheme.light(),
    darkTheme: PollarTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: contentWidth ?? double.infinity,
          child: wealth ? const WealthScreen() : const ReportsScreen(),
        ),
      ),
    ),
  ),
);

class _InitialPrivacy extends PrivacyModeNotifier {
  _InitialPrivacy(this.initial);
  final bool initial;
  @override
  bool build() => initial;
}

class RecordingAnalysisExporter implements ReportExporter {
  ReportExportDocument? document;
  int calls = 0;
  @override
  Future<ReportExportResult> export(ReportExportDocument document) async {
    calls++;
    this.document = document;
    return const ReportExportResult(
      csvPath: 'report.csv',
      checksumPath: 'report.csv.sha256',
    );
  }
}

class _AnalysisReportSource implements ReportDataSource {
  const _AnalysisReportSource({required this.long, required this.empty});
  final bool long;
  final bool empty;
  @override
  Future<ReportSourceData> load() async {
    if (empty) return const ReportSourceData(accounts: [], transactions: []);
    final source = await const ReportFixtureDataSource().load();
    if (!long) return source;
    Money scaled(Money money) => money.currency == Currency.brl
        ? _brl(money.minorUnits * 100000)
        : money;
    return ReportSourceData(
      accounts: [
        for (final a in source.accounts)
          ReportAccountRecord(
            id: a.id,
            currency: a.currency,
            openingBalance: scaled(a.openingBalance),
            isArchived: a.isArchived,
          ),
      ],
      transactions: [
        for (final t in source.transactions)
          ReportTransactionRecord(
            id: t.id,
            description: t.description,
            type: t.type,
            status: t.status,
            amount: scaled(t.amount),
            accountId: t.accountId,
            occurredAt: t.occurredAt,
            counterAccountId: t.counterAccountId,
            category: t.amount.currency == Currency.brl
                ? longAnalysisCategory
                : t.category,
          ),
      ],
    );
  }
}

InMemoryWealthRepository _longWealthRepository() => InMemoryWealthRepository(
  goals: [
    WealthGoal(
      id: 'long',
      name: longAnalysisName,
      target: _brl(123456789012),
      saved: _brl(24691357802),
      createdAt: DateTime(2026, 1, 1),
      deadline: DateTime(2027, 6, 30),
      priority: true,
    ),
  ],
  assets: [
    WealthAsset(
      id: 'long',
      name: 'Apartamento residencial com avaliação informada pelo proprietário',
      kind: WealthAssetKind.property,
      currentValue: _brl(98765432100),
      valuedAt: DateTime(2026, 9, 1),
    ),
  ],
  debts: [
    WealthDebt(
      id: 'long',
      name: 'Financiamento residencial com prazo e avaliação informados',
      kind: WealthDebtKind.financing,
      originalAmount: _brl(123456789012),
      outstandingAmount: _brl(34567890123),
      annualInterestBasisPoints: 975,
      dueDate: DateTime(2040, 8, 1),
      updatedAt: wealthFixtureNow,
    ),
  ],
);

class _AnalysisWealthSource implements WealthLedgerSource {
  const _AnalysisWealthSource({required this.long, required this.empty});
  final bool long;
  final bool empty;
  @override
  Future<List<Currency>> listCurrencies() async => empty
      ? []
      : long
      ? [Currency.brl, Currency.usd]
      : [Currency.brl];
  @override
  Future<List<WealthLedgerPosition>> listConfirmedPositions() async => empty
      ? []
      : long
      ? [
          WealthLedgerPosition(
            id: 'bank',
            name: 'Conta principal para compromissos e reservas familiares',
            balance: _brl(123456789012),
            isCreditCard: false,
            active: true,
          ),
          const WealthLedgerPosition(
            id: 'usd',
            name: 'Conta em dólar',
            balance: Money(minorUnits: 25000, currency: Currency.usd),
            isCreditCard: false,
            active: true,
          ),
        ]
      : await const WealthFixtureLedgerSource().listConfirmedPositions();
}
