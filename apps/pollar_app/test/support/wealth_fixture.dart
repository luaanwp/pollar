import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/wealth/application/wealth_ledger_source.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_asset.dart';
import 'package:pollar_app/features/wealth/domain/wealth_debt.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';

final wealthFixtureNow = DateTime(2026, 9, 10);

Money _brl(int minor) => Money(minorUnits: minor, currency: Currency.brl);

InMemoryWealthRepository createWealthFixtureRepository() =>
    InMemoryWealthRepository(
      goals: [
        WealthGoal(
          id: 'reserve',
          name: 'Reserva de emergência',
          target: _brl(3000000),
          saved: _brl(1250000),
          createdAt: DateTime(2026, 1, 1),
          deadline: DateTime(2027, 6, 30),
          priority: true,
        ),
        WealthGoal(
          id: 'trip',
          name: 'Viagem em família',
          target: _brl(1800000),
          saved: _brl(600000),
          createdAt: DateTime(2026, 4, 1),
          deadline: DateTime(2027, 1, 15),
        ),
        WealthGoal(
          id: 'paused-goal',
          name: 'Troca do veículo',
          target: _brl(7000000),
          saved: _brl(900000),
          createdAt: DateTime(2026, 2, 1),
          active: false,
        ),
      ],
      assets: [
        WealthAsset(
          id: 'home',
          name: 'Apartamento',
          kind: WealthAssetKind.property,
          currentValue: _brl(35000000),
          valuedAt: DateTime(2026, 8, 31),
        ),
        WealthAsset(
          id: 'car',
          name: 'Veículo',
          kind: WealthAssetKind.vehicle,
          currentValue: _brl(4500000),
          valuedAt: DateTime(2026, 7, 20),
        ),
        WealthAsset(
          id: 'collection',
          name: 'Coleção',
          kind: WealthAssetKind.valuable,
          currentValue: _brl(800000),
          valuedAt: DateTime(2026, 1, 10),
          active: false,
        ),
      ],
      debts: [
        WealthDebt(
          id: 'mortgage',
          name: 'Financiamento do imóvel',
          kind: WealthDebtKind.financing,
          originalAmount: _brl(22000000),
          outstandingAmount: _brl(11800000),
          annualInterestBasisPoints: 975,
          dueDate: DateTime(2040, 8, 1),
          updatedAt: wealthFixtureNow,
        ),
        WealthDebt(
          id: 'family',
          name: 'Empréstimo familiar',
          kind: WealthDebtKind.personal,
          originalAmount: _brl(500000),
          outstandingAmount: _brl(250000),
          updatedAt: wealthFixtureNow,
          active: false,
        ),
      ],
    );

class WealthFixtureLedgerSource implements WealthLedgerSource {
  const WealthFixtureLedgerSource();

  @override
  Future<List<Currency>> listCurrencies() async => const [Currency.brl];

  @override
  Future<List<WealthLedgerPosition>> listConfirmedPositions() async => [
    WealthLedgerPosition(
      id: 'bank',
      name: 'Conta principal',
      balance: _brl(25000000),
      isCreditCard: false,
      active: true,
    ),
    WealthLedgerPosition(
      id: 'card',
      name: 'Cartão Ouro',
      balance: _brl(-1200000),
      isCreditCard: true,
      active: true,
    ),
  ];
}
