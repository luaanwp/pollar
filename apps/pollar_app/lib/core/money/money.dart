import 'package:meta/meta.dart';

import 'currency.dart';

/// Raised when an operation combines two [Money] values of different currencies.
///
/// Financial arithmetic must never silently coerce currencies, so every
/// mixed-currency operation fails loudly instead of producing a wrong amount.
class CurrencyMismatchError extends Error {
  CurrencyMismatchError(this.left, this.right);

  final Currency left;
  final Currency right;

  @override
  String toString() =>
      'CurrencyMismatchError: cannot combine $left with $right';
}

/// An exact monetary amount stored as signed integer minor units.
///
/// Money is never represented with a binary floating-point type. A value's sign
/// is meaningful (balances can go negative); transaction amounts, by contrast,
/// are kept as positive magnitudes and given direction by their type elsewhere.
@immutable
class Money implements Comparable<Money> {
  const Money({required this.minorUnits, required this.currency});

  const Money.zero(this.currency) : minorUnits = 0;

  final int minorUnits;
  final Currency currency;

  bool get isNegative => minorUnits < 0;
  bool get isPositive => minorUnits > 0;
  bool get isZero => minorUnits == 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits: minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits: minorUnits - other.minorUnits, currency: currency);
  }

  Money operator -() => Money(minorUnits: -minorUnits, currency: currency);

  Money abs() => Money(minorUnits: minorUnits.abs(), currency: currency);

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw CurrencyMismatchError(currency, other.currency);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => 'Money($minorUnits $currency)';
}
