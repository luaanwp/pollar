import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/wealth/data/drift_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_asset.dart';
import 'package:pollar_app/features/wealth/domain/wealth_debt.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;
  late DriftWealthRepository repository;

  setUp(() {
    database = LocalDatabase(NativeDatabase.memory());
    repository = DriftWealthRepository(database);
  });
  tearDown(() => database.close());

  test('round trips goals including lifecycle and deadline', () async {
    final goal = WealthGoal(
      id: 'goal',
      name: 'Reserva',
      target: _brl(3000000),
      saved: _brl(750000),
      createdAt: DateTime(2026, 1, 2),
      deadline: DateTime(2027, 6, 30),
      priority: true,
    );
    await repository.addGoal(goal);
    await repository.replaceGoal(goal.copyWith(active: false));

    final stored = (await repository.listGoals()).single;
    expect(stored.name, 'Reserva');
    expect(stored.target, goal.target);
    expect(stored.saved, goal.saved);
    expect(stored.deadline, DateTime(2027, 6, 30));
    expect(stored.priority, isTrue);
    expect(stored.active, isFalse);
  });

  test('round trips assets and debts with exact values', () async {
    final asset = WealthAsset(
      id: 'asset',
      name: 'Apartamento',
      kind: WealthAssetKind.property,
      currentValue: _brl(35000000),
      valuedAt: DateTime(2026, 9, 10),
    );
    final debt = WealthDebt(
      id: 'debt',
      name: 'Financiamento',
      kind: WealthDebtKind.financing,
      originalAmount: _brl(25000000),
      outstandingAmount: _brl(11800000),
      annualInterestBasisPoints: 975,
      dueDate: DateTime(2040, 8, 1),
      updatedAt: DateTime(2026, 9, 10),
    );
    await repository.addAsset(asset);
    await repository.addDebt(debt);

    final storedAsset = (await repository.listAssets()).single;
    final storedDebt = (await repository.listDebts()).single;
    expect(storedAsset.currentValue, asset.currentValue);
    expect(storedAsset.kind, WealthAssetKind.property);
    expect(storedDebt.outstandingAmount, debt.outstandingAmount);
    expect(storedDebt.annualInterestBasisPoints, 975);
    expect(storedDebt.dueDate, DateTime(2040, 8, 1));
  });
}

Money _brl(int minor) => Money(minorUnits: minor, currency: Currency.brl);
