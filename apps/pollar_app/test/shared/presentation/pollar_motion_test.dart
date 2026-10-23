import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pollar_app/features/reports/domain/report_snapshot.dart';
import 'package:pollar_app/features/reports/presentation/widgets/report_charts.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/pollar_button.dart';
import 'package:pollar_app/shared/presentation/pollar_kinetic_card.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';
import 'package:pollar_app/shared/presentation/pollar_rolling_amount.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';

Widget app(Widget child, {bool reduced = false}) => MaterialApp(
  theme: PollarTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(
      body: Center(child: SizedBox(width: 320, child: child)),
    ),
  ),
);

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));
  Widget amount(
    int minor, {
    bool hidden = false,
    Currency currency = Currency.brl,
  }) => PrivacyAmount(
    Money(minorUnits: minor, currency: currency),
    hidden: hidden,
    animateChanges: true,
    allowWrap: true,
    reserveLayout: true,
    style: PollarTypography.balanceHeroCompact,
  );

  testWidgets(
    'rolling exposes only the new exact semantic value at every frame',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(app(amount(803000)));
        await tester.pumpWidget(app(amount(817520)));
        await tester.pump(const Duration(milliseconds: 90));
        expect(find.byType(PollarRollingAmount), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(
          find.bySemanticsLabel(RegExp(r'BRL R\$ 8.175,20')),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel(RegExp('8.030,00')), findsNothing);
        await tester.pumpWidget(app(amount(1)));
        await tester.pumpAndSettle();
        expect(
          tester.widget<MoneyText>(find.byType(MoneyText)).money.minorUnits,
          1,
        );
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'privacy interrupts rolling immediately and removes both numerical frames',
    (tester) async {
      await tester.pumpWidget(app(amount(803000)));
      await tester.pumpWidget(app(amount(817520)));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpWidget(app(amount(817520, hidden: true)));
      expect(find.byType(PollarRollingAmount), findsNothing);
      expect(find.byType(MoneyText), findsNothing);
      expect(find.text('R\$ ••••••'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reduced motion and currency switches show the exact value immediately',
    (tester) async {
      await tester.pumpWidget(app(amount(12345), reduced: true));
      await tester.pumpWidget(app(amount(54321), reduced: true));
      expect(find.byType(Opacity), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(app(amount(54321, currency: Currency.usd)));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MoneyText>(find.byType(MoneyText)).money.currency,
        Currency.usd,
      );
    },
  );

  Widget card() => PollarKineticCard(
    front: (flip, focus) => Row(
      children: [
        const Expanded(child: Text('Frente')),
        PollarIconButton(
          label: 'Virar',
          icon: LucideIcons.flipHorizontal,
          focusNode: focus,
          onPressed: flip,
        ),
      ],
    ),
    back: (flip, focus) => Row(
      children: [
        const Expanded(child: Text('Verso')),
        PollarIconButton(
          label: 'Voltar',
          icon: LucideIcons.flipHorizontal,
          focusNode: focus,
          onPressed: flip,
        ),
      ],
    ),
  );

  testWidgets(
    'card flip supports keyboard and restores focus to the visible face',
    (tester) async {
      await tester.pumpWidget(app(card()));
      final front = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Virar',
        ),
      );
      front.focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Frente'), findsNothing);
      expect(find.text('Verso'), findsOneWidget);
      final back = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Voltar',
        ),
      );
      expect(back.focusNode!.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Frente'), findsOneWidget);
      expect(front.focusNode!.hasFocus, isTrue);
    },
  );

  testWidgets('reduced motion still allows flipping without a transition', (
    tester,
  ) async {
    await tester.pumpWidget(app(card(), reduced: true));
    await tester.tap(find.byTooltip('Virar'));
    await tester.pump();
    expect(find.text('Verso'), findsOneWidget);
    expect(find.byType(AnimatedSize), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'chart retargeting keeps current semantics and privacy removes all geometry',
    (tester) async {
      final handle = tester.ensureSemantics();
      Money money(int value) =>
          Money(minorUnits: value, currency: Currency.brl);
      Widget chart(int value, {bool hidden = false}) => app(
        BalanceTrendChart(
          privacyHidden: hidden,
          months: [
            for (var i = 0; i < 3; i++)
              ReportMonth(
                month: DateTime(2026, i + 1),
                income: money(value),
                expenses: money(0),
                netResult: money(value),
                accountNetBalance: money(value * (i + 1)),
              ),
          ],
        ),
      );
      try {
        await tester.pumpWidget(chart(10000));
        await tester.pumpAndSettle();
        await tester.pumpWidget(chart(20000));
        await tester.pump(const Duration(milliseconds: 70));
        expect(find.bySemanticsLabel(RegExp(r'R\$ 600,00')), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp(r'R\$ 100,00')), findsNothing);
        await tester.pumpWidget(chart(30000));
        await tester.pump(const Duration(milliseconds: 30));
        await tester.pumpWidget(chart(30000, hidden: true));
        expect(
          find.descendant(
            of: find.byType(BalanceTrendChart),
            matching: find.byType(CustomPaint),
          ),
          findsNothing,
        );
        expect(find.bySemanticsLabel(RegExp(r'R\$ 900,00')), findsNothing);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'progress hides its proportion and exact semantics during privacy',
    (tester) async {
      await tester.pumpWidget(
        app(const PollarGoalProgress(value: 0.41, hidden: false)),
      );
      await tester.pump(const Duration(milliseconds: 90));
      await tester.pumpWidget(
        app(const PollarGoalProgress(value: 0.41, hidden: true)),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('celebration is finite and never takes pointer input', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => PollarButton(
            label: 'Concluir',
            onPressed: () {
              pressed++;
              showPollarGoalCelebration(context);
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Concluir'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('Concluir'));
    expect(pressed, 2);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
