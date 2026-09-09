import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/overview/application/overview_data_source.dart';
import 'package:pollar_app/features/overview/presentation/overview_controller.dart';
import 'package:pollar_app/shared/application/financial_data_revision.dart';

void main() {
  test(
    'reloads the derived snapshot after the shared revision changes',
    () async {
      final source = _MutableOverviewSource(_data(10000));
      final container = ProviderContainer(
        overrides: [
          overviewDataSourceProvider.overrideWithValue(source),
          overviewClockProvider.overrideWithValue(() => DateTime(2026, 9, 8)),
        ],
      );
      addTearDown(container.dispose);

      final first = await container.read(overviewProvider.future);
      expect(first.summaryFor(Currency.brl)!.confirmed.minorUnits, 10000);

      source.data = _data(25000);
      container.read(financialDataRevisionProvider.notifier).bump();
      final second = await container.read(overviewProvider.future);

      expect(second.summaryFor(Currency.brl)!.confirmed.minorUnits, 25000);
      expect(source.loadCount, 2);
    },
  );
}

OverviewSourceData _data(int openingMinorUnits) => OverviewSourceData(
  accounts: [
    OverviewAccountRecord(
      id: 'checking',
      name: 'Conta',
      currency: Currency.brl,
      openingBalance: Money(
        minorUnits: openingMinorUnits,
        currency: Currency.brl,
      ),
      kind: OverviewAccountKind.asset,
      isArchived: false,
    ),
  ],
  transactions: const [],
);

class _MutableOverviewSource implements OverviewDataSource {
  _MutableOverviewSource(this.data);

  OverviewSourceData data;
  int loadCount = 0;

  @override
  Future<OverviewSourceData> load() async {
    loadCount++;
    return data;
  }
}
