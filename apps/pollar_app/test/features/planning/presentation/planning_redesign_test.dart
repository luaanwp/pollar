import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/features/planning/presentation/planning_controller.dart';
import 'package:pollar_app/features/planning/presentation/planning_screen.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';

import '../../../support/planning_redesign_fixture.dart';

void main() {
  void viewport(WidgetTester tester, Size size, [double scale = 1]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(PlanningScreen)));

  testWidgets(
    'compact agenda and first commitments are visible before budgets',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await tester.pumpWidget(planningRedesignApp());
      await tester.pumpAndSettle();
      expect(find.text('Agenda do mês').hitTestable(), findsOneWidget);
      expect(find.text('Aluguel').hitTestable(), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Agenda do mês')).dy,
        lessThan(tester.getTopLeft(find.text('Orçamentos por categoria')).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('desktop pairs agenda and budgets, bounded width stacks them', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await tester.pumpWidget(planningRedesignApp());
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Agenda do mês')).dy,
      tester.getTopLeft(find.text('Orçamentos por categoria')).dy,
    );
    await tester.pumpWidget(planningRedesignApp(contentWidth: 700));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Agenda do mês')).dy,
      lessThan(tester.getTopLeft(find.text('Orçamentos por categoria')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'privacy removes money, percentages and fill during motion without geometry change',
    (tester) async {
      viewport(tester, const Size(1200, 1200));
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(planningRedesignApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));
      final before = tester.getRect(find.text('Agenda do mês'));
      expect(
        tester
            .widgetList<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .any((w) => w.value! > 0 && w.value! < .9),
        isTrue,
      );
      container(tester).read(privacyModeProvider.notifier).set(true);
      await tester.pump();
      expect(find.byType(MoneyText), findsNothing);
      expect(find.text('74%'), findsNothing);
      expect(find.text('90%'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('.*(74|90)%.*')), findsNothing);
      expect(
        tester
            .widgetList<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .every((w) => w.value == 0),
        isTrue,
      );
      expect(tester.getRect(find.text('Agenda do mês')), before);
      expect(find.text('Uso oculto'), findsNWidgets(2));
      semantics.dispose();
    },
  );

  for (final accessible in [false, true]) {
    testWidgets(
      'budget geometry is final with ${accessible ? 'accessible navigation' : 'reduced motion'}',
      (tester) async {
        viewport(tester, const Size(1200, 1000));
        await tester.pumpWidget(
          planningRedesignApp(
            reduced: !accessible,
            accessibleNavigation: accessible,
          ),
        );
        await tester.pump();
        expect(
          tester
              .widgetList<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .map((w) => w.value),
          containsAll([.74, .9]),
        );
        await tester.pumpAndSettle();
      },
    );
  }

  for (final spec in [(320.0, 2.0), (640.0, 1.3), (1024.0, 1.0)]) {
    testWidgets(
      'full long values and names reflow at ${spec.$1} and ${spec.$2}x',
      (tester) async {
        viewport(tester, Size(spec.$1, 1000), spec.$2);
        await tester.pumpWidget(planningRedesignApp(long: true));
        await tester.pumpAndSettle();
        for (final heading in [
          'Agenda do mês',
          'Orçamentos por categoria',
          'Assinaturas',
          'Lembretes locais',
          'Gerenciar planejamento',
        ]) {
          await tester.scrollUntilVisible(
            find.text(heading),
            350,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: heading);
        }
        expect(find.text(longPlanningDescription), findsWidgets);
      },
    );
  }

  testWidgets(
    'month and currency controls keep figures scoped to the selected period and currency',
    (tester) async {
      viewport(tester, const Size(1200, 1000));
      await tester.pumpWidget(planningRedesignApp(long: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<Currency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').last);
      await tester.pumpAndSettle();
      final usd = container(tester)
          .read(planningProvider)
          .requireValue
          .snapshot;
      expect(usd.currency, Currency.usd);
      expect(usd.totalBudgeted.minorUnits, 10000);
      expect(usd.totalSpent.minorUnits, 0);
      expect(usd.occurrences, isEmpty);
      expect(find.text(longPlanningDescription), findsNothing);
      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      expect(find.text('Planejamento de Outubro 2026'), findsOneWidget);
      expect(
        container(tester)
            .read(planningProvider)
            .requireValue
            .snapshot
            .totalBudgeted
            .minorUnits,
        0,
      );
      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pumpAndSettle();
      expect(
        container(tester)
            .read(planningProvider)
            .requireValue
            .snapshot
            .totalBudgeted
            .minorUnits,
        10000,
      );
    },
  );

  testWidgets(
    'empty planning keeps budget creation and disables commitments without accounts',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await tester.pumpWidget(planningRedesignApp(empty: true));
      await tester.pumpAndSettle();
      expect(find.text('Nenhum compromisso previsto'), findsOneWidget);
      await tester.tap(find.text('Novo compromisso'));
      await tester.pumpAndSettle();
      expect(find.text('Salvar compromisso'), findsNothing);
      await tester.tap(find.text('Novo orçamento'));
      await tester.pumpAndSettle();
      expect(find.text('Salvar orçamento'), findsOneWidget);
    },
  );
}
