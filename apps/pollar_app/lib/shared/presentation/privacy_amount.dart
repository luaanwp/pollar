import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import 'money_text.dart';
import 'pollar_rolling_amount.dart';

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
    this.reserveLayout = false,
    this.alignment = AlignmentDirectional.topStart,
    this.animateChanges = false,
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

  /// Opt-in for reflowing hero amounts: reserve both visible/masked metrics.
  /// Original text is measured only, never painted or exposed when hidden.
  final bool reserveLayout;

  /// Alignment within the reserved footprint; defaults preserve existing UI.
  final AlignmentGeometry alignment;
  final bool animateChanges;

  @override
  Widget build(BuildContext context) {
    final base = PollarTypography.tabular(
      style ?? PollarTypography.amountStandard,
    );
    final maskStyle = base.copyWith(
      color: context.pollar.textSecondary,
      letterSpacing: 0.04 * (style?.fontSize ?? 16),
    );
    final mask = List.filled(maskDigits, '•').join();
    final symbol = money.currency.symbol;
    final text = symbol.isEmpty ? mask : '$symbol $mask';
    Widget content({bool allowGroupBreaks = true}) {
      if (!hidden) {
        final value = MoneyText(
          money,
          style: style,
          showSign: showSign,
          colorBySign: colorBySign,
          semantic: semantic,
          formatter: formatter,
          allowWrap: allowWrap,
          allowGroupBreaks: allowGroupBreaks,
        );
        return animateChanges ? PollarRollingAmount(child: value) : value;
      }
      return Semantics(
        label: 'Valor oculto pelo modo privacidade',
        excludeSemantics: true,
        child: Text(
          text,
          maxLines: allowWrap ? null : 1,
          softWrap: allowWrap,
          style: maskStyle,
        ),
      );
    }

    if (!reserveLayout) return content();
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
          locale: Localizations.maybeLocaleOf(context),
        );
        late final Size visibleSize;
        late final Size maskedSize;
        late final bool allowGroupBreaks;
        try {
          final exactText = formatter.format(money, showSign: showSign);
          final prefixLength =
              (money.isNegative || (showSign && money.isPositive) ? 1 : 0) +
              (money.currency.symbol.isEmpty
                  ? 0
                  : money.currency.symbol.length +
                        formatter.symbolSpacing.length);
          // Currency yields first. Split numeric groups only if the complete
          // numeric token itself cannot fit at the requested text size.
          painter.text = TextSpan(
            text: exactText.substring(prefixLength),
            style: base,
          );
          painter.layout(maxWidth: double.infinity);
          allowGroupBreaks = painter.width > constraints.maxWidth;
          painter.maxLines = allowWrap ? null : 1;
          painter.text = TextSpan(
            text: MoneyText.wrapDisplay(
              exactText,
              allowWrap: allowWrap,
              allowGroupBreaks: allowGroupBreaks,
              groupSeparator: formatter.groupSeparator,
            ),
            style: base,
          );
          painter.layout(maxWidth: constraints.maxWidth);
          visibleSize = painter.size;
          painter.text = TextSpan(text: text, style: maskStyle);
          painter.layout(maxWidth: constraints.maxWidth);
          maskedSize = painter.size;
        } finally {
          painter.dispose();
        }
        return SizedBox(
          width: constraints.hasBoundedWidth
              ? constraints.maxWidth
              : math.max(visibleSize.width, maskedSize.width),
          height: math.max(visibleSize.height, maskedSize.height),
          child: Align(
            alignment: alignment,
            child: content(allowGroupBreaks: allowGroupBreaks),
          ),
        );
      },
    );
  }
}
