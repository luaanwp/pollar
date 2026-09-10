import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';

enum MoneySemantic { automatic, balance, debt, income, expense, neutral }

/// Renders a [Money] value per the design system's financial display rules:
/// tabular figures, true minus for negatives, and — when [colorBySign] — the
/// positive/negative semantic colors. Screen readers hear polarity + currency
/// ("entrada"/"saída"), never color alone.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.money, {
    super.key,
    this.style,
    this.showSign = false,
    this.colorBySign = false,
    this.semantic = MoneySemantic.automatic,
    this.formatter = const MoneyFormatter.ptBr(),
    this.allowWrap = false,
  });

  final Money money;
  final TextStyle? style;

  /// Prefix positive non-zero values with `+` (negatives always show `−`).
  final bool showSign;

  /// Tint the text success/danger by the value's sign. Zero stays neutral.
  final bool colorBySign;

  /// Meaning announced by assistive technology. [automatic] is appropriate
  /// for signed ledger movements; totals must provide their actual context.
  final MoneySemantic semantic;

  final MoneyFormatter formatter;
  final bool allowWrap;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final base = style ?? PollarTypography.amountStandard;

    // Explicit color so amounts never inherit a low-contrast default: neutral
    // primary text unless the sign should tint it.
    var color = pollar.textPrimary;
    if (colorBySign && !money.isZero) {
      color = money.isNegative ? pollar.danger : pollar.success;
    }

    final exactText = formatter.format(money, showSign: showSign);
    final text = allowWrap
        ? exactText.replaceAll(' ', ' \u200B').replaceAll('.', '.\u200B')
        : exactText;

    final meaning = switch (semantic) {
      MoneySemantic.balance => 'saldo',
      MoneySemantic.debt => 'dívida',
      MoneySemantic.income => 'entrada',
      MoneySemantic.expense => 'saída',
      MoneySemantic.neutral => '',
      MoneySemantic.automatic =>
        money.isNegative
            ? 'saída'
            : money.isZero
            ? ''
            : 'entrada',
    };
    final semanticsLabel = meaning.isEmpty
        ? '${money.currency.code} $exactText'
        : '$meaning, ${money.currency.code} $exactText';

    return Text(
      text,
      style: PollarTypography.tabular(base).copyWith(color: color),
      semanticsLabel: semanticsLabel,
      maxLines: allowWrap ? null : 1,
      softWrap: allowWrap,
    );
  }
}
