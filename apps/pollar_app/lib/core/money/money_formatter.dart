import 'currency.dart';
import 'money.dart';

/// Formats [Money] for display without ever converting through a floating-point
/// number, so the printed value can never disagree with the stored minor units.
///
/// Localization is deliberately explicit: [MoneyFormatter.ptBr] uses `.` for
/// thousands and `,` for decimals. Other locales get their own const factory.
class MoneyFormatter {
  const MoneyFormatter({
    required this.groupSeparator,
    required this.decimalSeparator,
    this.symbolSpacing = ' ',
  });

  /// Brazilian Portuguese: `R$ 1.234,56`.
  const MoneyFormatter.ptBr()
    : groupSeparator = '.',
      decimalSeparator = ',',
      symbolSpacing = ' ';

  final String groupSeparator;
  final String decimalSeparator;
  final String symbolSpacing;

  static const String _minus = '−'; // true minus, not hyphen
  static const String _maskDots = '••••••';

  /// Formats [money]. When [showSign] is true, positive non-zero values get a
  /// leading `+`; negatives always get a leading true minus sign.
  String format(Money money, {bool showSign = false}) {
    final digits = _absDigits(money.minorUnits, money.currency.decimalDigits);
    final body = '${_symbolPrefix(money.currency)}$digits';

    if (money.isNegative) return '$_minus$body';
    if (showSign && money.isPositive) return '+$body';
    return body;
  }

  /// Privacy mode: hides the amount while keeping the currency symbol.
  String formatMasked(Currency currency) =>
      '${_symbolPrefix(currency)}$_maskDots';

  String _symbolPrefix(Currency currency) =>
      currency.symbol.isEmpty ? '' : '${currency.symbol}$symbolSpacing';

  /// Builds the grouped `1.234,56` body from the absolute minor units, using
  /// only integer math.
  String _absDigits(int minorUnits, int decimalDigits) {
    final abs = minorUnits.abs();
    final scale = _pow10(decimalDigits);
    final major = (abs ~/ scale).toString();
    final grouped = _group(major);

    if (decimalDigits == 0) return grouped;

    final fraction = (abs % scale).toString().padLeft(decimalDigits, '0');
    return '$grouped$decimalSeparator$fraction';
  }

  String _group(String integerDigits) {
    final buffer = StringBuffer();
    final length = integerDigits.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) buffer.write(groupSeparator);
      buffer.write(integerDigits[i]);
    }
    return buffer.toString();
  }

  int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
