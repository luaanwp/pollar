import 'package:meta/meta.dart';

/// An ISO 4217 currency together with the number of decimal digits it uses.
///
/// [decimalDigits] is the exponent that maps a minor-unit integer to its major
/// value (BRL/USD use 2, so 12345 minor units == 123.45).
@immutable
class Currency {
  const Currency({
    required this.code,
    required this.decimalDigits,
    this.symbol = '',
  }) : assert(code.length == 3, 'ISO 4217 code must have 3 letters'),
       assert(decimalDigits >= 0, 'decimalDigits must be non-negative');

  final String code;
  final int decimalDigits;

  /// Display symbol (e.g. `R$`, `$`). Empty when only the ISO code is shown.
  final String symbol;

  static const Currency brl = Currency(
    code: 'BRL',
    decimalDigits: 2,
    symbol: r'R$',
  );
  static const Currency usd = Currency(
    code: 'USD',
    decimalDigits: 2,
    symbol: r'$',
  );

  @override
  bool operator ==(Object other) =>
      other is Currency &&
      other.code == code &&
      other.decimalDigits == decimalDigits &&
      other.symbol == symbol;

  @override
  int get hashCode => Object.hash(code, decimalDigits, symbol);

  @override
  String toString() => code;
}
