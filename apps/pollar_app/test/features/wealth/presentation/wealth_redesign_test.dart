import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_controller.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_screen.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';

import '../../../support/analysis_redesign_fixture.dart';

void main() {
  void viewport(WidgetTester tester, Size size, [double scale = 1]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  ProviderContainer scope(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(WealthScreen)));

  testWidgets(
    'compact position precedes creation and keeps the priority goal findable',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await tester.pumpWidget(analysisRedesignApp(wealth: true));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Patrimônio líquido')).dy,
        lessThan(tester.getTopLeft(find.text('Nova meta')).dy),
      );
      expect(find.text('Meta prioritária').hitTestable(), findsOneWidget);
      expect(
        scope(tester)
            .read(wealthProvider)
            .requireValue
            .snapshot
            .netWorth
            .minorUnits,
        51500000,
      );
    },
  );

  testWidgets(
    'wealth columns use available content width inside a large window',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      await tester.pumpWidget(
        analysisRedesignApp(wealth: true, contentWidth: 700),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Patrimônio líquido')).dy,
        lessThan(tester.getTopLeft(find.text('Meta prioritária')).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'privacy hides all goal percentages and debt rates without shifting the composition',
    (tester) async {
      viewport(tester, const Size(1200, 1600));
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(analysisRedesignApp(wealth: true));
        await tester.pumpAndSettle();
        expect(find.text('41% reservado'), findsOneWidget);
        expect(find.textContaining('9,75% a.a.'), findsOneWidget);
        final before = tester.getRect(find.text('Composição do patrimônio'));
        scope(tester).read(privacyModeProvider.notifier).set(true);
        await tester.pump();
        expect(find.byType(MoneyText), findsNothing);
        expect(find.textContaining('% reservado'), findsNothing);
        expect(find.textContaining('9,75% a.a.'), findsNothing);
        expect(
          find.bySemanticsLabel(RegExp('.*(41%|33%|9,75%).*')),
          findsNothing,
        );
        expect(find.textContaining('taxa oculta'), findsOneWidget);
        expect(tester.getRect(find.text('Composição do patrimônio')), before);
        expect(
          tester.widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          ),
          isEmpty,
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('wealth currency changes preserve exact separate positions', (
    tester,
  ) async {
    viewport(tester, const Size(1200, 1000));
    await tester.pumpWidget(analysisRedesignApp(wealth: true, long: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Currency>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();
    final snapshot = scope(tester).read(wealthProvider).requireValue.snapshot;
    expect(snapshot.currency, Currency.usd);
    expect(snapshot.netWorth.minorUnits, 25000);
    expect(snapshot.goals, isEmpty);
    expect(
      tester
          .widgetList<MoneyText>(find.byType(MoneyText))
          .every((w) => w.money.currency == Currency.usd),
      isTrue,
    );
    expect(find.text('Nenhuma meta ativa'), findsOneWidget);
  });

  for (final spec in [(320.0, 2.0), (640.0, 1.3), (1024.0, 1.0)]) {
    testWidgets('complete wealth records fit ${spec.$1}/${spec.$2}x', (
      tester,
    ) async {
      viewport(tester, Size(spec.$1, 1000), spec.$2);
      await tester.pumpWidget(analysisRedesignApp(wealth: true, long: true));
      await tester.pumpAndSettle();
      for (final heading in [
        'Meta prioritária',
        'Composição do patrimônio',
        'Metas acompanhadas',
        'Gerenciar registros',
      ]) {
        await tester.scrollUntilVisible(
          find.text(heading),
          350,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: heading);
      }
      expect(find.text(longAnalysisName), findsWidgets);
    });
  }

  testWidgets('empty wealth offers real creation without a fabricated goal', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.pumpWidget(analysisRedesignApp(wealth: true, empty: true));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma meta ativa'), findsOneWidget);
    expect(
      scope(tester).read(wealthProvider).requireValue.snapshot.netWorth.isZero,
      isTrue,
    );
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    expect(find.text('Salvar meta'), findsOneWidget);
  });
}
