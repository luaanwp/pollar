import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/planning/application/planning_ledger_source.dart';
import 'package:pollar_app/features/planning/data/in_memory_planning_repository.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';
import 'package:pollar_app/features/planning/domain/recurring_rule.dart';
import 'package:pollar_app/features/planning/presentation/planning_controller.dart';
import 'package:pollar_app/features/planning/presentation/planning_screen.dart';

import 'planning_fixture.dart';

Widget planningRedesignApp({
  bool dark = false,
  bool hidden = false,
  bool reduced = false,
  bool accessibleNavigation = false,
  bool long = false,
  bool empty = false,
  double? contentWidth,
}) => ProviderScope(
  overrides: [
    planningRepositoryProvider.overrideWithValue(
      empty
          ? InMemoryPlanningRepository()
          : long
          ? createLongPlanningRepository()
          : createPlanningFixtureRepository(),
    ),
    planningLedgerSourceProvider.overrideWithValue(
      empty
          ? const EmptyPlanningLedgerSource()
          : long
          ? const LongPlanningLedgerSource()
          : const PlanningFixtureLedgerSource(),
    ),
    planningClockProvider.overrideWithValue(() => planningFixtureNow),
    privacyModeProvider.overrideWith(() => _InitialPrivacy(hidden)),
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
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reduced,
        accessibleNavigation: accessibleNavigation,
      ),
      child: child!,
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: contentWidth ?? double.infinity,
          child: const PlanningScreen(),
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

class EmptyPlanningLedgerSource implements PlanningLedgerSource {
  const EmptyPlanningLedgerSource();
  @override
  Future<List<PlanningAccountReference>> listAccounts() async => [];
  @override
  Future<List<PlanningLedgerRecord>> listMovements() async => [];
}

const longPlanningCategory =
    'Saúde, assistência familiar e cuidados continuados';
const longPlanningDescription =
    'Assistência familiar com acompanhamento e cuidados continuados';

InMemoryPlanningRepository createLongPlanningRepository() =>
    InMemoryPlanningRepository(
      budgets: [
        Budget(
          id: 'long',
          category: longPlanningCategory,
          month: DateTime(2026, 9),
          limit: const Money(minorUnits: 123456789012, currency: Currency.brl),
        ),
        Budget(
          id: 'usd',
          category: 'Serviços em dólar',
          month: DateTime(2026, 9),
          limit: const Money(minorUnits: 10000, currency: Currency.usd),
        ),
      ],
      recurringRules: [
        RecurringRule(
          id: 'long',
          description: longPlanningDescription,
          kind: RecurringKind.subscription,
          frequency: RecurrenceFrequency.monthly,
          amount: const Money(minorUnits: 87654321099, currency: Currency.brl),
          accountId: 'bank',
          firstDueDate: DateTime(2026, 9, 10),
        ),
      ],
    );

class LongPlanningLedgerSource implements PlanningLedgerSource {
  const LongPlanningLedgerSource();

  @override
  Future<List<PlanningAccountReference>> listAccounts() async => const [
    PlanningAccountReference(
      id: 'bank',
      name: 'Conta principal',
      currency: Currency.brl,
      active: true,
    ),
    PlanningAccountReference(
      id: 'usd',
      name: 'Conta em dólar',
      currency: Currency.usd,
      active: true,
    ),
  ];

  @override
  Future<List<PlanningLedgerRecord>> listMovements() async => [
    PlanningLedgerRecord(
      occurredAt: DateTime(2026, 9, 8),
      amount: const Money(minorUnits: 98765432100, currency: Currency.brl),
      kind: PlanningMovementKind.expense,
      canceled: false,
      category: longPlanningCategory,
    ),
  ];
}
