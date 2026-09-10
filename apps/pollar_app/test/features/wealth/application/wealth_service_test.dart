import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/wealth/application/wealth_ledger_source.dart';
import 'package:pollar_app/features/wealth/application/wealth_service.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_asset.dart';
import 'package:pollar_app/features/wealth/domain/wealth_debt.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';

void main() {
  test(
    'reconciles confirmed account positions with manual assets and debts',
    () async {
      final service = WealthService(
        InMemoryWealthRepository(
          assets: [
            WealthAsset(
              id: 'home',
              name: 'Apartamento',
              kind: WealthAssetKind.property,
              currentValue: _brl(30000000),
              valuedAt: DateTime(2026, 9, 10),
            ),
          ],
          debts: [
            WealthDebt(
              id: 'mortgage',
              name: 'Financiamento',
              kind: WealthDebtKind.financing,
              originalAmount: _brl(20000000),
              outstandingAmount: _brl(10000000),
              updatedAt: DateTime(2026, 9, 10),
            ),
          ],
        ),
        const _Ledger(),
      );

      final snapshot = await service.load(Currency.brl);

      expect(snapshot.totalAssets.minorUnits, 40000000);
      expect(snapshot.totalLiabilities.minorUnits, 12500000);
      expect(snapshot.netWorth.minorUnits, 27500000);
      expect(snapshot.accountPositions, hasLength(3));
    },
  );

  test(
    'calculates exact goal progress and chooses the explicit priority',
    () async {
      final repository = InMemoryWealthRepository(
        goals: [
          WealthGoal(
            id: 'later',
            name: 'Viagem',
            target: _brl(1000000),
            saved: _brl(250000),
            createdAt: DateTime(2026, 1, 1),
          ),
          WealthGoal(
            id: 'priority',
            name: 'Reserva',
            target: _brl(3000000),
            saved: _brl(1000000),
            createdAt: DateTime(2026, 1, 1),
            priority: true,
          ),
        ],
      );
      final snapshot = await WealthService(
        repository,
        const _Ledger(),
      ).load(Currency.brl);

      expect(snapshot.priorityGoal!.goal.id, 'priority');
      expect(snapshot.priorityGoal!.percent, 33);
      expect(snapshot.priorityGoal!.remaining.minorUnits, 2000000);
    },
  );

  test(
    'new priority clears the previous priority in the same currency',
    () async {
      final old = WealthGoal(
        id: 'old',
        name: 'Reserva',
        target: _brl(100000),
        saved: _brl(10000),
        createdAt: DateTime(2026, 1, 1),
        priority: true,
      );
      final repository = InMemoryWealthRepository(goals: [old]);
      final service = WealthService(repository, const _Ledger());
      await service.createGoal(
        WealthGoal(
          id: 'new',
          name: 'Entrada do imóvel',
          target: _brl(5000000),
          saved: _brl(200000),
          createdAt: DateTime(2026, 9, 10),
          priority: true,
        ),
      );

      final goals = await repository.listGoals();
      expect(goals.singleWhere((item) => item.id == 'old').priority, isFalse);
      expect(goals.singleWhere((item) => item.id == 'new').priority, isTrue);
    },
  );

  test('paused and foreign-currency records do not cross totals', () async {
    final repository = InMemoryWealthRepository(
      assets: [
        WealthAsset(
          id: 'paused',
          name: 'Coleção',
          kind: WealthAssetKind.valuable,
          currentValue: _brl(100000),
          valuedAt: DateTime(2026, 9, 10),
          active: false,
        ),
        WealthAsset(
          id: 'usd',
          name: 'Bem no exterior',
          kind: WealthAssetKind.other,
          currentValue: const Money(minorUnits: 50000, currency: Currency.usd),
          valuedAt: DateTime(2026, 9, 10),
        ),
      ],
    );

    final snapshot = await WealthService(
      repository,
      const _Ledger(),
    ).load(Currency.brl);
    expect(snapshot.assets, isEmpty);
    expect(snapshot.totalAssets.minorUnits, 10000000);
  });

  test('updates records without replacing their identity or history', () async {
    final createdAt = DateTime(2025, 1, 2);
    final goal = WealthGoal(
      id: 'goal',
      name: 'Reserva',
      target: _brl(100000),
      saved: _brl(10000),
      createdAt: createdAt,
    );
    final repository = InMemoryWealthRepository(goals: [goal]);
    final service = WealthService(repository, const _Ledger());

    await service.updateGoal(
      WealthGoal(
        id: goal.id,
        name: 'Reserva ampliada',
        target: _brl(200000),
        saved: _brl(20000),
        createdAt: goal.createdAt,
        priority: true,
      ),
    );

    final updated = (await repository.listGoals()).single;
    expect(updated.id, goal.id);
    expect(updated.createdAt, createdAt);
    expect(updated.name, 'Reserva ampliada');
    expect(updated.priority, isTrue);
  });

  test('completes goals and settles debts with exact zero balances', () async {
    final goal = WealthGoal(
      id: 'goal',
      name: 'Reserva',
      target: _brl(100000),
      saved: _brl(10000),
      createdAt: DateTime(2025, 1, 2),
    );
    final debt = WealthDebt(
      id: 'debt',
      name: 'Empréstimo',
      kind: WealthDebtKind.loan,
      originalAmount: _brl(500000),
      outstandingAmount: _brl(250000),
      updatedAt: DateTime(2026, 1, 1),
    );
    final repository = InMemoryWealthRepository(goals: [goal], debts: [debt]);
    final service = WealthService(repository, const _Ledger());
    final settledAt = DateTime(2026, 9, 10);

    await service.completeGoal(goal);
    await service.settleDebt(debt, settledAt);

    expect((await repository.listGoals()).single.completed, isTrue);
    final settled = (await repository.listDebts()).single;
    expect(settled.settled, isTrue);
    expect(settled.updatedAt, settledAt);
  });
}

Money _brl(int minor) => Money(minorUnits: minor, currency: Currency.brl);

class _Ledger implements WealthLedgerSource {
  const _Ledger();

  @override
  Future<List<Currency>> listCurrencies() async => const [Currency.brl];

  @override
  Future<List<WealthLedgerPosition>> listConfirmedPositions() async => [
    WealthLedgerPosition(
      id: 'bank',
      name: 'Conta principal',
      balance: _brl(10000000),
      isCreditCard: false,
      active: true,
    ),
    WealthLedgerPosition(
      id: 'card',
      name: 'Cartão',
      balance: _brl(-2000000),
      isCreditCard: true,
      active: true,
    ),
    WealthLedgerPosition(
      id: 'overdraft',
      name: 'Cheque especial',
      balance: _brl(-500000),
      isCreditCard: false,
      active: true,
    ),
  ];
}
