import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/core/money/money_formatter.dart';

void main() {
  const brl = Currency.brl;
  const formatter = MoneyFormatter.ptBr();
  Money brlOf(int minor) => Money(minorUnits: minor, currency: brl);

  test('formats a plain BRL amount with grouping and comma decimals', () {
    expect(formatter.format(brlOf(123456)), r'R$ 1.234,56');
  });

  test('formats thousands and millions', () {
    expect(formatter.format(brlOf(100000000)), r'R$ 1.000.000,00');
  });

  test('formats small amounts below one unit', () {
    expect(formatter.format(brlOf(5)), r'R$ 0,05');
  });

  test('negative uses a true minus sign', () {
    expect(formatter.format(brlOf(-12345)), '−R\$ 123,45');
  });

  test('showSign adds an explicit plus for positive values', () {
    expect(formatter.format(brlOf(12345), showSign: true), r'+R$ 123,45');
  });

  test('showSign does not add a plus to zero', () {
    expect(formatter.format(brlOf(0), showSign: true), r'R$ 0,00');
  });

  test('masked value hides digits but keeps the currency symbol', () {
    expect(formatter.formatMasked(brl), r'R$ ••••••');
  });

  test('exactness holds for very large amounts beyond double precision', () {
    // 90.071.992.547.409,95 — would lose precision if divided as a double.
    expect(
      formatter.format(brlOf(9007199254740995)),
      r'R$ 90.071.992.547.409,95',
    );
  });
}
