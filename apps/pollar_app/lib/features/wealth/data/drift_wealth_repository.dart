import 'package:drift/drift.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/data/local_database.dart';
import '../domain/wealth_asset.dart';
import '../domain/wealth_debt.dart';
import '../domain/wealth_goal.dart';
import '../domain/wealth_repository.dart';

class DriftWealthRepository implements WealthRepository {
  const DriftWealthRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<List<WealthGoal>> listGoals() async =>
      (await _database.select(_database.wealthGoalEntries).get())
          .map(_goal)
          .toList();

  @override
  Future<List<WealthAsset>> listAssets() async =>
      (await _database.select(_database.wealthAssetEntries).get())
          .map(_asset)
          .toList();

  @override
  Future<List<WealthDebt>> listDebts() async =>
      (await _database.select(_database.wealthDebtEntries).get())
          .map(_debt)
          .toList();

  @override
  Future<void> addGoal(WealthGoal goal) async {
    await _database.into(_database.wealthGoalEntries).insert(_goalRow(goal));
  }

  @override
  Future<void> addAsset(WealthAsset asset) async {
    await _database.into(_database.wealthAssetEntries).insert(_assetRow(asset));
  }

  @override
  Future<void> addDebt(WealthDebt debt) async {
    await _database.into(_database.wealthDebtEntries).insert(_debtRow(debt));
  }

  @override
  Future<void> replaceGoal(WealthGoal goal) async {
    final changed = await (_database.update(
      _database.wealthGoalEntries,
    )..where((row) => row.id.equals(goal.id))).write(_goalRow(goal));
    if (changed != 1) throw StateError('Unknown goal: ${goal.id}');
  }

  @override
  Future<void> replaceAsset(WealthAsset asset) async {
    final changed = await (_database.update(
      _database.wealthAssetEntries,
    )..where((row) => row.id.equals(asset.id))).write(_assetRow(asset));
    if (changed != 1) throw StateError('Unknown asset: ${asset.id}');
  }

  @override
  Future<void> replaceDebt(WealthDebt debt) async {
    final changed = await (_database.update(
      _database.wealthDebtEntries,
    )..where((row) => row.id.equals(debt.id))).write(_debtRow(debt));
    if (changed != 1) throw StateError('Unknown debt: ${debt.id}');
  }

  WealthGoal _goal(StoredWealthGoal row) => WealthGoal(
    id: row.id,
    name: row.name,
    target: _money(
      row.targetMinor,
      row.currencyCode,
      row.currencyDecimalDigits,
      row.currencySymbol,
    ),
    saved: _money(
      row.savedMinor,
      row.currencyCode,
      row.currencyDecimalDigits,
      row.currencySymbol,
    ),
    createdAt: DateTime.fromMicrosecondsSinceEpoch(row.createdAtMicros),
    deadline: row.deadlineMicros == null
        ? null
        : DateTime.fromMicrosecondsSinceEpoch(row.deadlineMicros!),
    priority: row.priority,
    active: row.active,
  );

  WealthAsset _asset(StoredWealthAsset row) => WealthAsset(
    id: row.id,
    name: row.name,
    kind: WealthAssetKind.values.byName(row.kind),
    currentValue: _money(
      row.currentValueMinor,
      row.currencyCode,
      row.currencyDecimalDigits,
      row.currencySymbol,
    ),
    valuedAt: DateTime.fromMicrosecondsSinceEpoch(row.valuedAtMicros),
    active: row.active,
  );

  WealthDebt _debt(StoredWealthDebt row) => WealthDebt(
    id: row.id,
    name: row.name,
    kind: WealthDebtKind.values.byName(row.kind),
    originalAmount: _money(
      row.originalAmountMinor,
      row.currencyCode,
      row.currencyDecimalDigits,
      row.currencySymbol,
    ),
    outstandingAmount: _money(
      row.outstandingAmountMinor,
      row.currencyCode,
      row.currencyDecimalDigits,
      row.currencySymbol,
    ),
    annualInterestBasisPoints: row.annualInterestBasisPoints,
    dueDate: row.dueDateMicros == null
        ? null
        : DateTime.fromMicrosecondsSinceEpoch(row.dueDateMicros!),
    updatedAt: DateTime.fromMicrosecondsSinceEpoch(row.updatedAtMicros),
    active: row.active,
  );

  WealthGoalEntriesCompanion _goalRow(WealthGoal item) =>
      WealthGoalEntriesCompanion(
        id: Value(item.id),
        name: Value(item.name),
        targetMinor: Value(item.target.minorUnits),
        savedMinor: Value(item.saved.minorUnits),
        currencyCode: Value(item.target.currency.code),
        currencyDecimalDigits: Value(item.target.currency.decimalDigits),
        currencySymbol: Value(item.target.currency.symbol),
        createdAtMicros: Value(item.createdAt.microsecondsSinceEpoch),
        deadlineMicros: Value(item.deadline?.microsecondsSinceEpoch),
        priority: Value(item.priority),
        active: Value(item.active),
      );

  WealthAssetEntriesCompanion _assetRow(WealthAsset item) =>
      WealthAssetEntriesCompanion(
        id: Value(item.id),
        name: Value(item.name),
        kind: Value(item.kind.name),
        currentValueMinor: Value(item.currentValue.minorUnits),
        currencyCode: Value(item.currentValue.currency.code),
        currencyDecimalDigits: Value(item.currentValue.currency.decimalDigits),
        currencySymbol: Value(item.currentValue.currency.symbol),
        valuedAtMicros: Value(item.valuedAt.microsecondsSinceEpoch),
        active: Value(item.active),
      );

  WealthDebtEntriesCompanion _debtRow(WealthDebt item) =>
      WealthDebtEntriesCompanion(
        id: Value(item.id),
        name: Value(item.name),
        kind: Value(item.kind.name),
        originalAmountMinor: Value(item.originalAmount.minorUnits),
        outstandingAmountMinor: Value(item.outstandingAmount.minorUnits),
        currencyCode: Value(item.originalAmount.currency.code),
        currencyDecimalDigits: Value(
          item.originalAmount.currency.decimalDigits,
        ),
        currencySymbol: Value(item.originalAmount.currency.symbol),
        annualInterestBasisPoints: Value(item.annualInterestBasisPoints),
        dueDateMicros: Value(item.dueDate?.microsecondsSinceEpoch),
        updatedAtMicros: Value(item.updatedAt.microsecondsSinceEpoch),
        active: Value(item.active),
      );

  Money _money(int minor, String code, int digits, String symbol) => Money(
    minorUnits: minor,
    currency: Currency(code: code, decimalDigits: digits, symbol: symbol),
  );
}
