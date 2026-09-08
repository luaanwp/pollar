import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/core/money/money_parser.dart';
import 'package:pollar_app/core/money/installment_plan.dart';

void main() {
  test('pt-BR decimal input and pasted currency preserve exact cents', () {
    for (final entry in {
      '100': 10000,
      '100,5': 10050,
      r'R$ 1.234,56': 123456,
      '−R\$ 0,01': -1,
      'BRL 0,00': 0,
      '90.071.992.547.409,91': MoneyParser.maxMinorUnits,
    }.entries) {
      expect(
        MoneyParser.parse(entry.key, Currency.brl).minorUnits,
        entry.value,
      );
    }
  });
  test('malformed, ambiguous, foreign and overflowing input is rejected', () {
    for (final input in [
      '',
      '1.23',
      '1,234.56',
      '1,234',
      '1e3',
      '12abc',
      'USD 1,00',
      '1 234,56',
      '90.071.992.547.409,92',
      '--1',
      '1,',
    ]) {
      expect(
        () => MoneyParser.parse(input, Currency.brl),
        throwsFormatException,
        reason: input,
      );
    }
  });
  test('currency exponent controls precision', () {
    const yen = Currency(code: 'JPY', decimalDigits: 0);
    const dinar = Currency(code: 'KWD', decimalDigits: 3);
    expect(MoneyParser.parse('123', yen).minorUnits, 123);
    expect(() => MoneyParser.parse('123,1', yen), throwsFormatException);
    expect(MoneyParser.parse('123,456', dinar).minorUnits, 123456);
  });
  test(
    'installments sum exactly and distribute remainder to earliest entries',
    () {
      for (final total in [0, 1, 2, 10000, 123456, MoneyParser.maxMinorUnits]) {
        for (final count in [1, 2, 3, 12, 360]) {
          final parts = InstallmentPlan.split(
            Money(minorUnits: total, currency: Currency.brl),
            count,
          );
          expect(
            parts.fold<int>(0, (sum, part) => sum + part.minorUnits),
            total,
          );
          expect(
            parts.first.minorUnits - parts.last.minorUnits,
            inInclusiveRange(0, 1),
          );
        }
      }
      expect(
        InstallmentPlan.split(
          const Money(minorUnits: 10000, currency: Currency.brl),
          3,
        ).map((part) => part.minorUnits),
        [3334, 3333, 3333],
      );
    },
  );
  test('invalid installment parameters fail explicitly', () {
    const total = Money(minorUnits: 10000, currency: Currency.brl);
    expect(() => InstallmentPlan.split(total, 0), throwsRangeError);
    expect(() => InstallmentPlan.split(total, 361), throwsRangeError);
    expect(() => InstallmentPlan.split(-total, 3), throwsArgumentError);
  });
}
