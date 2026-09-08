import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/shared/presentation/pollar_banner.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';
import 'package:pollar_app/shared/presentation/status_badge.dart';
import 'package:pollar_app/shared/presentation/transaction_tile.dart';

void main() {
  const amount = Money(minorUnits: -123456, currency: Currency.brl);

  Widget app(Widget child) => MaterialApp(
    theme: PollarTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('PrivacyAmount hides the value from text and semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(app(const PrivacyAmount(amount, hidden: true)));

    expect(find.text('R\$ ••••••'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Valor oculto pelo modo privacidade'),
      findsOneWidget,
    );
    expect(find.textContaining('1.234,56'), findsNothing);
    handle.dispose();
  });

  testWidgets('StatusBadge carries a text status and icon', (tester) async {
    await tester.pumpWidget(
      app(
        const Center(
          child: StatusBadge(
            label: 'Conciliado',
            tone: PollarStatusTone.success,
            icon: LucideIcons.link,
          ),
        ),
      ),
    );

    expect(find.text('Conciliado'), findsOneWidget);
    expect(find.byIcon(LucideIcons.link), findsOneWidget);
  });

  testWidgets('TransactionTile keeps exact money and status visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const TransactionTile(
          title: 'Mercado do bairro',
          category: 'Alimentação',
          account: 'Cartão Ouro',
          date: '1 set 2026',
          amount: amount,
          installment: '3/12',
          status: 'Previsto',
          statusIcon: LucideIcons.clock,
        ),
      ),
    );

    expect(find.text('−R\$ 1.234,56'), findsOneWidget);
    expect(find.text('Alimentação · Cartão Ouro'), findsOneWidget);
    expect(find.text('3/12'), findsOneWidget);
    expect(find.text('Previsto'), findsOneWidget);
  });

  testWidgets('TransactionTile supports 200% text on a compact viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      app(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: TransactionTile(
            title: 'Assinatura de streaming',
            category: 'Serviços recorrentes',
            account: 'Cartão Ouro',
            date: '1 set 2026',
            amount: amount,
            installment: '3/12',
            status: 'Parcialmente paga',
            statusTone: PollarStatusTone.warning,
            statusIcon: LucideIcons.clock,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('danger banner keeps recovery action accessible', (tester) async {
    final handle = tester.ensureSemantics();
    var retried = false;

    await tester.pumpWidget(
      app(
        PollarBanner(
          tone: PollarStatusTone.danger,
          title: 'Falha na sincronização',
          message: 'Verifique a conexão e tente novamente.',
          actions: [
            TextButton(
              onPressed: () => retried = true,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Falha na sincronização. Verifique a conexão e tente novamente.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Tentar novamente'));
    expect(retried, isTrue);
    handle.dispose();
  });
}
