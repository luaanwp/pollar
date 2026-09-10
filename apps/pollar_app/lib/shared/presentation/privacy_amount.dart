import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import 'money_text.dart';

/// A [MoneyText] that preserves its visual footprint while privacy mode hides
/// the amount. Screen readers announce the hidden state instead of the value.
class PrivacyAmount extends StatelessWidget {
  const PrivacyAmount(
    this.money, {
    super.key,
    required this.hidden,
    this.style,
    this.showSign = false,
    this.colorBySign = false,
    this.semantic = MoneySemantic.automatic,
    this.maskDigits = 6,
    this.formatter = const MoneyFormatter.ptBr(),
    this.allowWrap = false,
  }) : assert(maskDigits > 0);

  final Money money;
  final bool hidden;
  final TextStyle? style;
  final bool showSign;
  final bool colorBySign;
  final MoneySemantic semantic;
  final int maskDigits;
  final MoneyFormatter formatter;
  final bool allowWrap;

  @override
  Widget build(BuildContext context) {
    if (!hidden) {
      return MoneyText(
        money,
        style: style,
        showSign: showSign,
        colorBySign: colorBySign,
        semantic: semantic,
        formatter: formatter,
        allowWrap: allowWrap,
      );
    }

    final mask = List.filled(maskDigits, '•').join();
    final symbol = money.currency.symbol;
    final text = symbol.isEmpty ? mask : '$symbol $mask';

    return Semantics(
      label: 'Valor oculto pelo modo privacidade',
      excludeSemantics: true,
      child: Text(
        text,
        maxLines: allowWrap ? null : 1,
        softWrap: allowWrap,
        style:
            PollarTypography.tabular(style ?? PollarTypography.amountStandard)
                .copyWith(
                  color: context.pollar.textSecondary,
                  letterSpacing: 0.04 * (style?.fontSize ?? 16),
                ),
      ),
    );
  }
}
