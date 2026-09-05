import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';

void main() {
  const brl = Currency.brl;
  const usd = Currency.usd;

  group('Money construction', () {
    test('holds minor units and currency', () {
      const m = Money(minorUnits: 12345, currency: brl);
      expect(m.minorUnits, 12345);
      expect(m.currency, brl);
    });

    test('zero has zero minor units', () {
      expect(Money.zero(brl).minorUnits, 0);
    });
  });

  group('Money equality', () {
    test('equal by value and currency', () {
      expect(
        const Money(minorUnits: 100, currency: brl),
        const Money(minorUnits: 100, currency: brl),
      );
    });

    test('differs when currency differs', () {
      expect(
        const Money(minorUnits: 100, currency: brl),
        isNot(const Money(minorUnits: 100, currency: usd)),
      );
    });
  });

  group('Money arithmetic', () {
    test('adds amounts of the same currency', () {
      final sum =
          const Money(minorUnits: 100, currency: brl) +
          const Money(minorUnits: 250, currency: brl);
      expect(sum, const Money(minorUnits: 350, currency: brl));
    });

    test('subtracts amounts of the same currency', () {
      final diff =
          const Money(minorUnits: 100, currency: brl) -
          const Money(minorUnits: 250, currency: brl);
      expect(diff, const Money(minorUnits: -150, currency: brl));
    });

    test('throws when adding different currencies', () {
      expect(
        () =>
            const Money(minorUnits: 100, currency: brl) +
            const Money(minorUnits: 100, currency: usd),
        throwsA(isA<CurrencyMismatchError>()),
      );
    });

    test('negate flips sign', () {
      expect(
        -const Money(minorUnits: 100, currency: brl),
        const Money(minorUnits: -100, currency: brl),
      );
    });

    test('abs returns magnitude', () {
      expect(
        const Money(minorUnits: -100, currency: brl).abs(),
        const Money(minorUnits: 100, currency: brl),
      );
    });
  });

  group('Money predicates', () {
    test('isNegative / isPositive / isZero', () {
      expect(const Money(minorUnits: -1, currency: brl).isNegative, isTrue);
      expect(const Money(minorUnits: 1, currency: brl).isPositive, isTrue);
      expect(Money.zero(brl).isZero, isTrue);
    });

    test('compareTo orders same-currency amounts', () {
      final a = const Money(minorUnits: 100, currency: brl);
      final b = const Money(minorUnits: 250, currency: brl);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
      expect(a.compareTo(a), 0);
    });

    test('compareTo throws across currencies', () {
      expect(
        () => const Money(
          minorUnits: 100,
          currency: brl,
        ).compareTo(const Money(minorUnits: 100, currency: usd)),
        throwsA(isA<CurrencyMismatchError>()),
      );
    });
  });
}
