import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/transactions/application/transaction_account_catalog.dart';
import 'package:pollar_app/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:pollar_app/features/transactions/presentation/transactions_controller.dart';
import 'package:pollar_app/main.dart';

void main() {
  Widget app() => ProviderScope(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(
        InMemoryTransactionRepository(),
      ),
      transactionAccountCatalogProvider.overrideWithValue(
        const _EmptyAccountCatalog(),
      ),
    ],
    child: const PollarApp(),
  );

  testWidgets('Overview renders inside the shell with the Pollar theme', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Visão geral'), findsWidgets); // shell title + rail label
    expect(find.text('SALDO TOTAL'), findsOneWidget);

    final context = tester.element(find.text('SALDO TOTAL'));
    expect(Theme.of(context).colorScheme.primary, PollarColors.light.primary);
  });

  testWidgets('theme toggle switches light↔dark', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    var context = tester.element(find.text('SALDO TOTAL'));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.tap(find.byTooltip('Tema escuro'));
    await tester.pumpAndSettle();

    context = tester.element(find.text('SALDO TOTAL'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.pollar.primary, PollarColors.dark.primary);
  });

  testWidgets('privacy toggle masks every overview amount', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('R\$ 8.595,95'), findsOneWidget);
    expect(find.text('R\$ ••••••'), findsNothing);

    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pump();

    expect(find.text('R\$ 8.595,95'), findsNothing);
    expect(find.text('R\$ ••••••'), findsOneWidget);
    expect(find.text('R\$ •••••'), findsNWidgets(4));
    expect(find.byTooltip('Mostrar valores'), findsOneWidget);
  });

  testWidgets('navigating to Transações shows its empty state', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma transação ainda'), findsNothing);

    await tester.tap(find.text('Transações').first);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma transação ainda'), findsOneWidget);
  });
}

class _EmptyAccountCatalog implements TransactionAccountCatalog {
  const _EmptyAccountCatalog();

  @override
  Future<List<TransactionAccountReference>> findAll() async => const [];
}
