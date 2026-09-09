import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/overview/application/overview_data_source.dart';
import 'package:pollar_app/features/overview/presentation/overview_controller.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/main.dart';

import '../../../support/overview_fixture.dart';

void main() {
  testWidgets('shows exact derived balances and recent transaction evidence', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const OverviewFixtureDataSource()));
    await tester.pumpAndSettle();

    expect(find.text('Saldo confirmado'), findsOneWidget);
    expect(find.text(r'R$ 8.030,00'), findsOneWidget);
    expect(find.text(r'R$ 9.350,00'), findsWidgets);
    expect(find.text('Dívida projetada nos cartões'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Freelance — projeto Vega'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Freelance — projeto Vega'), findsOneWidget);
  });

  testWidgets('supports 200% text on a compact viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(const OverviewFixtureDataSource()));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Posições por conta'), findsOneWidget);
  });

  testWidgets('supports 200% text when the metric summary uses columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(const OverviewFixtureDataSource()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Posições por conta'), findsOneWidget);
  });

  testWidgets('selects a currency without mixing account positions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(const _MultiCurrencySource()));
    await tester.pumpAndSettle();

    expect(find.text('Conta em reais'), findsOneWidget);
    expect(find.text('Conta em dólar'), findsNothing);
    await tester.tap(find.text('BRL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();

    expect(find.text('Conta em reais'), findsNothing);
    expect(find.text('Conta em dólar'), findsOneWidget);
    expect(find.text('1 posição ativa · USD'), findsOneWidget);
  });

  testWidgets('explains the empty account state', (tester) async {
    await tester.pumpWidget(
      _app(
        const _StaticSource(OverviewSourceData(accounts: [], transactions: [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cadastre sua primeira conta'), findsOneWidget);
    expect(find.text('Cadastrar conta'), findsOneWidget);
  });

  testWidgets('recovers after a source error', (tester) async {
    final source = _RecoveringSource();
    await tester.pumpWidget(_app(source));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível calcular os saldos'), findsOneWidget);
    await tester.tap(find.text('Recalcular saldos'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastre sua primeira conta'), findsOneWidget);
    expect(source.calls, 2);
  });
}

Widget _app(OverviewDataSource source) => ProviderScope(
  overrides: [
    overviewDataSourceProvider.overrideWithValue(source),
    overviewClockProvider.overrideWithValue(() => overviewFixtureNow),
  ],
  child: const PollarApp(),
);

class _StaticSource implements OverviewDataSource {
  const _StaticSource(this.data);

  final OverviewSourceData data;

  @override
  Future<OverviewSourceData> load() async => data;
}

class _RecoveringSource implements OverviewDataSource {
  int calls = 0;

  @override
  Future<OverviewSourceData> load() async {
    calls++;
    if (calls == 1) throw StateError('offline database');
    return const OverviewSourceData(accounts: [], transactions: []);
  }
}

class _MultiCurrencySource implements OverviewDataSource {
  const _MultiCurrencySource();

  @override
  Future<OverviewSourceData> load() async => const OverviewSourceData(
    accounts: [
      OverviewAccountRecord(
        id: 'brl',
        name: 'Conta em reais',
        currency: Currency.brl,
        openingBalance: Money(minorUnits: 10000, currency: Currency.brl),
        kind: OverviewAccountKind.asset,
        isArchived: false,
      ),
      OverviewAccountRecord(
        id: 'usd',
        name: 'Conta em dólar',
        currency: Currency.usd,
        openingBalance: Money(minorUnits: 2000, currency: Currency.usd),
        kind: OverviewAccountKind.asset,
        isArchived: false,
      ),
    ],
    transactions: [],
  );
}
