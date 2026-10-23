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
import 'package:pollar_app/main.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';

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
