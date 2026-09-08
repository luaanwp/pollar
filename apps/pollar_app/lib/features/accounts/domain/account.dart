import 'package:meta/meta.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

enum AccountType { cash, checking, savings, investment, creditCard }

enum AccountStatus { active, archived }

/// Billing rules owned by a credit-card account.
@immutable
class CreditCardTerms {
  factory CreditCardTerms({
    required Money creditLimit,
    required int closingDay,
    required int dueDay,
  }) {
    if (!creditLimit.isPositive) {
      throw ArgumentError.value(
        creditLimit,
        'creditLimit',
        'Credit limit must be positive',
      );
    }
    _validateDay(closingDay, 'closingDay');
    _validateDay(dueDay, 'dueDay');
    return CreditCardTerms._(
      creditLimit: creditLimit,
      closingDay: closingDay,
      dueDay: dueDay,
    );
  }

  const CreditCardTerms._({
    required this.creditLimit,
    required this.closingDay,
    required this.dueDay,
  });

  final Money creditLimit;
  final int closingDay;
  final int dueDay;

  static void _validateDay(int day, String parameter) {
    if (day < 1 || day > 31) {
      throw RangeError.range(day, 1, 31, parameter);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CreditCardTerms &&
      other.creditLimit == creditLimit &&
      other.closingDay == closingDay &&
      other.dueDay == dueDay;

  @override
  int get hashCode => Object.hash(creditLimit, closingDay, dueDay);
}

/// A balance-bearing financial account.
///
/// Credit cards are liability accounts: purchases make their ledger balance
/// more negative and statement payments move it back towards zero.
@immutable
class Account {
  factory Account({
    required String id,
    required String name,
    required AccountType type,
    required Currency currency,
    required Money openingBalance,
    CreditCardTerms? creditCardTerms,
    AccountStatus status = AccountStatus.active,
  }) {
    final normalizedId = id.trim();
    final normalizedName = name.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Account id cannot be empty');
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Account name cannot be empty');
    }
    if (openingBalance.currency != currency) {
      throw CurrencyMismatchError(currency, openingBalance.currency);
    }
    final isCreditCard = type == AccountType.creditCard;
    if (isCreditCard && creditCardTerms == null) {
      throw ArgumentError(
        'Credit-card accounts require creditCardTerms',
        'creditCardTerms',
      );
    }
    if (!isCreditCard && creditCardTerms != null) {
      throw ArgumentError(
        'Only credit-card accounts accept creditCardTerms',
        'creditCardTerms',
      );
    }
    if (creditCardTerms != null &&
        creditCardTerms.creditLimit.currency != currency) {
      throw CurrencyMismatchError(
        currency,
        creditCardTerms.creditLimit.currency,
      );
    }

    return Account._(
      id: normalizedId,
      name: normalizedName,
      type: type,
      currency: currency,
      openingBalance: openingBalance,
      creditCardTerms: creditCardTerms,
      status: status,
    );
  }

  const Account._({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalance,
    required this.status,
    this.creditCardTerms,
  });

  final String id;
  final String name;
  final AccountType type;
  final Currency currency;
  final Money openingBalance;
  final CreditCardTerms? creditCardTerms;
  final AccountStatus status;

  bool get isArchived => status == AccountStatus.archived;
  bool get isCreditCard => type == AccountType.creditCard;

  Account rename(String name) => Account(
    id: id,
    name: name,
    type: type,
    currency: currency,
    openingBalance: openingBalance,
    creditCardTerms: creditCardTerms,
    status: status,
  );

  Account archive() => _withStatus(AccountStatus.archived);

  Account restore() => _withStatus(AccountStatus.active);

  Account _withStatus(AccountStatus value) => Account(
    id: id,
    name: name,
    type: type,
    currency: currency,
    openingBalance: openingBalance,
    creditCardTerms: creditCardTerms,
    status: value,
  );

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.currency == currency &&
      other.openingBalance == openingBalance &&
      other.creditCardTerms == creditCardTerms &&
      other.status == status;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    currency,
    openingBalance,
    creditCardTerms,
    status,
  );
}
