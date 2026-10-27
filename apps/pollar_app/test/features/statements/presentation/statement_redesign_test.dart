import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/statements/domain/card_statement.dart';
import 'package:pollar_app/features/statements/presentation/widgets/statement_summary.dart';
import 'package:pollar_app/features/statements/presentation/widgets/statement_purchases.dart';
import 'package:pollar_app/features/statements/presentation/widgets/future_installments.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
  });
  Money money(int value) => Money(minorUnits: value, currency: Currency.brl);
  CardStatementSnapshot snapshot({int total = 55563, int pending = 20000}) =>
      CardStatementSnapshot(
        cardId: 'card',
        cardName: 'Cartão Ouro',
        currency: Currency.brl,
        creditLimit: money(500000),
        availableLimit: money(444437),
        statement: CardStatement(
          id: 'card:2026-09-20',
          periodStart: DateTime(2026, 8, 21),
          closingDate: DateTime(2026, 9, 20),
          dueDate: DateTime(2026, 9, 28),
          status: CardStatementStatus.open,
          total: money(total),
          paid: money(0),
          pendingPayments: money(pending),
          outstanding: money(total),
          purchases: [
            StatementPurchase(
              id: 'purchase',
              description: 'Compra com descrição completa e extensa para verificar a leitura sem cortes',
              date: DateTime(2026, 9, 8),
              amount: money(total),
              category: 'Categoria completa',
              installmentNumber: 1,
              installmentCount: 3,
            ),
          ],
        ),
        futureInstallments: [
          FutureInstallment(
            description: 'Compra com parcelas futuras e descrição completa que precisa permanecer legível',
            amount: money(total),
            date: DateTime(2026, 10, 8),
            number: 2,
            count: 3,
          ),
        ],
        paymentAccounts: const [],
      );

  Future<ProviderContainer> mount(
    WidgetTester tester, {
    Size size = const Size(390, 900),
    double scale = 1,
    CardStatementSnapshot? data,
    bool settle = true,
    bool reduced = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final current = data ?? snapshot();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PollarTheme.light(),
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final hidden = ref.watch(privacyModeProvider);
                      return Column(
                        children: [
                          StatementSummary(
                            snapshot: current,
                            privacyHidden: hidden,
                            onPay: () {},
                          ),
                          StatementPurchases(
                            items: current.statement.purchases,
                            privacyHidden: hidden,
                          ),
                          FutureInstallmentsCard(
                            items: current.futureInstallments,
                            privacyHidden: hidden,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    return ProviderScope.containerOf(
      tester.element(find.byType(StatementSummary)),
    );
  }

  for (final sample in [
    (size: const Size(390, 900), scale: 1.0),
    (size: const Size(320, 900), scale: 1.3),
    (size: const Size(320, 900), scale: 2.0),
    (size: const Size(1440, 1000), scale: 1.0),
  ]) {
    testWidgets(
      'statement privacy preserves all amount geometry at ${sample.size.width}/${sample.scale}',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          final container = await mount(
            tester,
            size: sample.size,
            scale: sample.scale,
          );
          List<Rect> geometry() => [
            for (final amount in tester.widgetList<PrivacyAmount>(
              find.byType(PrivacyAmount),
            ))
              tester.getRect(find.byWidget(amount)),
          ];
          final before = geometry();
          if (sample.size.width == 320 && sample.scale == 1.3) {
            Finder amount(int value) => find.byWidgetPredicate(
              (widget) =>
                  widget is MoneyText && widget.money.minorUnits == value,
            );
            expect(
              tester.getSize(amount(444437)).height,
              lessThanOrEqualTo(tester.getSize(amount(0)).height),
            );
          }
          expect(find.byKey(const Key('statement-limit-fill')), findsOneWidget);
          container.read(privacyModeProvider.notifier).set(true);
          await tester.pump();
          expect(geometry(), before);
          expect(find.byType(MoneyText), findsNothing);
          expect(find.byKey(const Key('statement-limit-fill')), findsNothing);
          expect(
            find.byKey(const Key('statement-limit-hidden')),
            findsOneWidget,
          );
          await tester.ensureVisible(find.text('Limite utilizado'));
          await tester.pump();
          expect(
            find.bySemanticsLabel('Limite utilizado oculto'),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(RegExp('Limite utilizado, 11')),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }

  testWidgets(
    'privacy interrupts usage drawing and reduced motion skips the tween',
    (tester) async {
      final container = await mount(tester, settle: false);
      await tester.pump(const Duration(milliseconds: 70));
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('statement-limit-fill')),
      );
      expect(bar.value, greaterThan(0));
      expect(bar.value, lessThan(0.11));
      container.read(privacyModeProvider.notifier).set(true);
      await tester.pump();
      expect(find.byKey(const Key('statement-limit-fill')), findsNothing);
      expect(find.byType(MoneyText), findsNothing);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester, reduced: true, settle: false);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byKey(const Key('statement-limit-fill')),
            )
            .value,
        0.11,
      );
      expect(
        find.ancestor(
          of: find.byKey(const Key('statement-limit-fill')),
          matching: find.byType(TweenAnimationBuilder<double>),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'pending reservations stay separate from paid and available balance',
    (tester) async {
      await mount(tester);
      final amounts = tester
          .widgetList<PrivacyAmount>(find.byType(PrivacyAmount))
          .map((item) => item.money.minorUnits)
          .toList();
      expect(amounts, containsAll([55563, 20000, 35563, 0, 444437]));
      expect(find.text('Pago'), findsOneWidget);
      expect(find.text('Pagamento pendente'), findsOneWidget);
      expect(find.text('Disponível para pagar'), findsOneWidget);
      expect(find.text('Pagar fatura'), findsOneWidget);
    },
  );

  testWidgets(
    'statement purchases and future amounts remain complete at 320px and double text',
    (tester) async {
      final data = snapshot(total: 99999999999999, pending: 1);
      await mount(tester, size: const Size(320, 900), scale: 2, data: data);
      for (final label in [
        data.statement.purchases.first.description,
        data.futureInstallments.first.description,
      ]) {
        final text = tester.widget<Text>(find.text(label));
        expect(text.maxLines, isNull);
        expect(text.overflow, isNot(TextOverflow.ellipsis));
      }
      for (final value in tester.widgetList<PrivacyAmount>(
        find.byType(PrivacyAmount),
      )) {
        expect(value.allowWrap, isTrue);
        expect(value.reserveLayout, isTrue);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
