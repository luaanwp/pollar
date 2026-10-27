import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/overview/application/overview_data_source.dart';
import 'package:pollar_app/features/overview/presentation/overview_controller.dart';
import 'package:pollar_app/features/overview/presentation/overview_screen.dart';
import 'package:pollar_app/features/overview/presentation/widgets/overview_monthly_flow.dart';
import 'package:pollar_app/features/overview/domain/overview_snapshot.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/main.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';
import 'package:pollar_app/shared/presentation/pollar_rolling_amount.dart';
import 'package:pollar_app/shared/application/financial_data_revision.dart';

import '../../../support/overview_fixture.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
  });

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double scale = 1,
    OverviewDataSource source = const OverviewFixtureDataSource(),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          overviewDataSourceProvider.overrideWithValue(source),
          overviewClockProvider.overrideWithValue(() => overviewFixtureNow),
        ],
        child: const PollarApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder contentScroll() => find.descendant(
    of: find.byType(OverviewScreen),
    matching: find.byType(Scrollable),
  );

  OverviewCurrencySummary flowSummary(int income, int expense) =>
      OverviewCurrencySummary(
        currency: Currency.brl,
        confirmed: Money.zero(Currency.brl),
        projected: Money.zero(Currency.brl),
        projectedMonthlyIncome: Money(
          minorUnits: income,
          currency: Currency.brl,
        ),
        projectedMonthlyExpenses: Money(
          minorUnits: expense,
          currency: Currency.brl,
        ),
        confirmedCardDebt: Money.zero(Currency.brl),
        projectedCardDebt: Money.zero(Currency.brl),
      );

  testWidgets(
    'monthly comparison animates real ratios and privacy removes them immediately',
    (tester) async {
      var hidden = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: PollarTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return OverviewMonthlyFlow(
                  summary: flowSummary(10000, 2500),
                  hidden: hidden,
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 90));
      Finder fill(String label) =>
          find.byKey(ValueKey('overview-flow-fill-$label'));
      final growing = tester
          .widget<FractionallySizedBox>(fill('Entradas'))
          .widthFactor!;
      expect(growing, greaterThan(0));
      expect(growing, lessThan(1));
      update(() => hidden = true);
      await tester.pump();
      expect(fill('Entradas'), findsNothing);
      expect(fill('Saídas'), findsNothing);
      expect(find.byKey(const Key('overview-flow-hidden')), findsNWidgets(2));
      expect(find.byType(MoneyText), findsNothing);
      update(() => hidden = false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<FractionallySizedBox>(fill('Entradas')).widthFactor,
        1,
      );
      expect(
        tester.widget<FractionallySizedBox>(fill('Saídas')).widthFactor,
        0.25,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion shows the final comparison immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PollarTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: OverviewMonthlyFlow(
              summary: flowSummary(2500, 10000),
              hidden: false,
            ),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<FractionallySizedBox>(
            find.byKey(const ValueKey('overview-flow-fill-Entradas')),
          )
          .widthFactor,
      0.25,
    );
    expect(
      tester
          .widget<FractionallySizedBox>(
            find.byKey(const ValueKey('overview-flow-fill-Saídas')),
          )
          .widthFactor,
      1,
    );
    expect(
      find.descendant(
        of: find.byType(OverviewMonthlyFlow),
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
      findsNothing,
    );
  });

  testWidgets('zero monthly activity draws no artificial bars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PollarTheme.light(),
        home: Scaffold(
          body: OverviewMonthlyFlow(summary: flowSummary(0, 0), hidden: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final bar in tester.widgetList<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    )) {
      expect(bar.widthFactor, 0);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'mobile reads confirmed, projected and month before the create action',
    (tester) async {
      await mount(tester);
      final confirmed = tester.getTopLeft(find.text('Saldo confirmado')).dy;
      final projected = tester.getTopLeft(find.text('Saldo projetado')).dy;
      final monthly = tester
          .getTopLeft(find.text('Resultado projetado do mês'))
          .dy;
      final action = tester.getTopLeft(find.text('Nova transação')).dy;
      expect(confirmed, lessThan(projected));
      expect(projected, lessThan(monthly));
      expect(monthly, lessThan(action));
      expect(tester.getBottomRight(find.text('Saídas')).dy, lessThan(764));
      await tester.tap(find.text('Nova transação'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(
        container.read(routerProvider).state.uri.path,
        '/transactions/new',
      );
    },
  );

  for (final sample in [
    (size: const Size(320, 844), scale: 1.3),
    (size: const Size(390, 844), scale: 2.0),
    (size: const Size(1440, 1000), scale: 1.0),
  ]) {
    testWidgets(
      'privacy preserves monetary geometry at ${sample.size.width}/${sample.scale}',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await mount(tester, size: sample.size, scale: sample.scale);
          List<Rect> monetaryRects() => [
            for (final widget in tester.widgetList<PrivacyAmount>(
              find.byType(PrivacyAmount),
            ))
              tester.getRect(find.byWidget(widget)),
          ];
          final before = monetaryRects();
          final monthlyBefore = tester.getRect(
            find.text('Resultado projetado do mês'),
          );
          await tester.tap(find.byTooltip('Ocultar valores'));
          await tester.pumpAndSettle();
          expect(monetaryRects(), before);
          expect(
            tester.getRect(find.text('Resultado projetado do mês')),
            monthlyBefore,
          );
          expect(find.byType(MoneyText), findsNothing);
          expect(
            find.bySemanticsLabel(RegExp('Valor oculto pelo modo privacidade')),
            findsWidgets,
          );
          await tester.tap(find.byTooltip('Mostrar valores'));
          await tester.pumpAndSettle();
          expect(monetaryRects(), before);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }

  testWidgets('enlarged desktop evidence stacks accounts before transactions', (
    tester,
  ) async {
    await mount(tester, size: const Size(1440, 1000), scale: 2);
    await tester.scrollUntilVisible(
      find.text('Transações recentes'),
      400,
      scrollable: contentScroll(),
    );
    expect(
      tester.getTopLeft(find.text('Posições por conta')).dy,
      lessThan(tester.getTopLeft(find.text('Transações recentes')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  for (final negative in [false, true]) {
    testWidgets(
      'large ${negative ? 'negative' : 'positive'} amounts and names reflow at 320px/2x',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await mount(
            tester,
            size: const Size(320, 844),
            scale: 2,
            source: _ExtremeSource(negative: negative),
          );
          final confirmed = tester.widget<PrivacyAmount>(
            find.byKey(const Key('overview-confirmed')),
          );
          expect(
            confirmed.money.minorUnits,
            negative ? -100099999999998 : 99900000000000,
          );
          expect(
            find.bySemanticsLabel(RegExp('saldo, BRL .*999')),
            findsWidgets,
          );
          await tester.scrollUntilVisible(
            find.text('Transações recentes'),
            400,
            scrollable: contentScroll(),
          );
          final accountText = tester.widget<Text>(
            find.text(_ExtremeSource.accountName),
          );
          expect(accountText.maxLines, isNull);
          await tester.scrollUntilVisible(
            find.text(_ExtremeSource.description),
            300,
            scrollable: contentScroll(),
          );
          expect(
            tester.widget<Text>(find.text(_ExtremeSource.description)).maxLines,
            isNull,
          );
          for (final text in tester.widgetList<Text>(
            find.descendant(
              of: find.byType(PrivacyAmount),
              matching: find.byType(Text),
            ),
          )) {
            expect(text.maxLines, isNull);
            expect(text.overflow, isNot(TextOverflow.ellipsis));
          }
          await tester.tap(find.byTooltip('Ocultar valores'));
          await tester.pumpAndSettle();
          expect(find.byType(MoneyText), findsNothing);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }

  testWidgets(
    'a real financial reload preserves the balance animator and then shows the exact new value',
    (tester) async {
      final source = _ReloadingSource();
      await mount(tester, source: source);
      final before = tester.state(find.byType(PollarRollingAmount));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OverviewScreen)),
      );
      container.read(financialDataRevisionProvider.notifier).bump();
      await tester.pump();
      expect(find.text('Saldo confirmado'), findsOneWidget);
      expect(tester.state(find.byType(PollarRollingAmount)), same(before));
      final data = await const OverviewFixtureDataSource().load();
      final account = data.accounts.first;
      source.pending.complete(
        OverviewSourceData(
          accounts: [
            OverviewAccountRecord(
              id: account.id,
              name: account.name,
              currency: account.currency,
              openingBalance:
                  account.openingBalance +
                  const Money(minorUnits: 10000, currency: Currency.brl),
              kind: account.kind,
              isArchived: account.isArchived,
            ),
            ...data.accounts.skip(1),
          ],
          transactions: data.transactions,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));
      expect(tester.state(find.byType(PollarRollingAmount)), same(before));
      expect(
        tester
            .widget<PrivacyAmount>(find.byKey(const Key('overview-confirmed')))
            .money
            .minorUnits,
        813000,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'first account action remains reachable in a short window at 2x',
    (tester) async {
      await mount(
        tester,
        size: const Size(390, 360),
        scale: 2,
        source: const _EmptySource(),
      );
      final scroll = find.descendant(
        of: find.byType(OverviewScreen),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Cadastrar conta'),
        180,
        scrollable: scroll,
      );
      await tester.tap(find.text('Cadastrar conta'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(container.read(routerProvider).state.uri.path, '/accounts/new');
      expect(tester.takeException(), isNull);
    },
  );
}

class _ReloadingSource implements OverviewDataSource {
  var calls = 0;
  final pending = Completer<OverviewSourceData>();
  @override
  Future<OverviewSourceData> load() =>
      calls++ == 0 ? const OverviewFixtureDataSource().load() : pending.future;
}

class _EmptySource implements OverviewDataSource {
  const _EmptySource();
  @override
  Future<OverviewSourceData> load() async =>
      const OverviewSourceData(accounts: [], transactions: []);
}

class _ExtremeSource implements OverviewDataSource {
  const _ExtremeSource({required this.negative});
  final bool negative;
  static const accountName =
      'Conta de investimentos com um nome completo muito extenso para testar a leitura';
  static const description =
      'Pagamento com descrição extensa, categoria e contexto preservados na visão geral';
  @override
  Future<OverviewSourceData> load() async => OverviewSourceData(
    accounts: [
      OverviewAccountRecord(
        id: 'extreme',
        name: accountName,
        currency: Currency.brl,
        openingBalance: Money(
          minorUnits: negative ? -99999999999999 : 99999999999999,
          currency: Currency.brl,
        ),
        kind: OverviewAccountKind.asset,
        isArchived: false,
      ),
    ],
    transactions: [
      OverviewTransactionRecord(
        id: 'movement',
        description: description,
        type: TransactionType.expense,
        status: TransactionStatus.compensado,
        amount: const Money(minorUnits: 99999999999, currency: Currency.brl),
        accountId: 'extreme',
        occurredAt: overviewFixtureNow,
        category: 'Categoria completa e extensa',
      ),
    ],
  );
}
