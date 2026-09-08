import 'currency.dart';
import 'money.dart';

/// Strict pt-BR decimal entry. Uses BigInt before conversion to prevent silent
/// overflow on native platforms and rounding on the web.
abstract final class MoneyParser {
  static const maxMinorUnits = 9007199254740991;

  static Money parse(String input, Currency currency) {
    var text = input.trim().replaceAll('\u00a0', ' ');
    var negative = false;
    if (text.startsWith('-') || text.startsWith('−')) {
      negative = true;
      text = text.substring(1).trim();
    }
    for (final prefix in [currency.symbol, currency.code]) {
      if (prefix.isNotEmpty && text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }
    if (!RegExp(r'^(?:[0-9]+|[1-9][0-9]{0,2}(?:\.[0-9]{3})+)(?:,[0-9]+)?$')
        .hasMatch(text)) {
      throw const FormatException('Use o formato 1.234,56.');
    }
    final parts = text.replaceAll('.', '').split(',');
    final fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > currency.decimalDigits) {
      throw FormatException(
        'Use até ${currency.decimalDigits} casas decimais.',
      );
    }
    final value = BigInt.parse(
      '${parts.first}${fraction.padRight(currency.decimalDigits, '0')}',
    );
    if (value > BigInt.from(maxMinorUnits)) {
      throw const FormatException('Valor acima do limite de precisão.');
    }
    return Money(
      minorUnits: negative ? -value.toInt() : value.toInt(),
      currency: currency,
    );
  }
}
