import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/main.dart';

void main() {
  testWidgets('Overview renders with the Pollar theme applied', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PollarApp()));
    await tester.pumpAndSettle();

    expect(find.text('Visão geral'), findsOneWidget);
    expect(find.text('SALDO TOTAL'), findsOneWidget);

    // Primary token drives the color scheme (light default).
    final context = tester.element(find.text('Visão geral'));
    expect(Theme.of(context).colorScheme.primary, PollarColors.light.primary);
    expect(context.pollar.danger, PollarColors.light.danger);
  });

  testWidgets('theme toggle switches light↔dark', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PollarApp()));
    await tester.pumpAndSettle();

    // System default resolves to light in the test harness.
    var context = tester.element(find.text('Visão geral'));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.tap(find.byTooltip('Tema escuro'));
    await tester.pumpAndSettle();

    context = tester.element(find.text('Visão geral'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.pollar.primary, PollarColors.dark.primary);
  });
}
