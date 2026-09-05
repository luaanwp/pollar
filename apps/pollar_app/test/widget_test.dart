import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/main.dart';

void main() {
  testWidgets('Overview renders inside the shell with the Pollar theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PollarApp()));
    await tester.pumpAndSettle();

    expect(find.text('Visão geral'), findsWidgets); // shell title + rail label
    expect(find.text('SALDO TOTAL'), findsOneWidget);

    final context = tester.element(find.text('SALDO TOTAL'));
    expect(Theme.of(context).colorScheme.primary, PollarColors.light.primary);
  });

  testWidgets('theme toggle switches light↔dark', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PollarApp()));
    await tester.pumpAndSettle();

    var context = tester.element(find.text('SALDO TOTAL'));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.tap(find.byTooltip('Tema escuro'));
    await tester.pumpAndSettle();

    context = tester.element(find.text('SALDO TOTAL'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.pollar.primary, PollarColors.dark.primary);
  });

  testWidgets('navigating to Transações shows its empty state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PollarApp()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma transação ainda'), findsNothing);

    await tester.tap(find.text('Transações').first);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma transação ainda'), findsOneWidget);
  });
}
