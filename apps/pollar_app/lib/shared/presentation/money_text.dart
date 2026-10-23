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
  /// Line-break opportunities only; exact formatting and semantics stay intact.
  static String wrapDisplay(
    String exactText, {
    required bool allowWrap,
    bool allowGroupBreaks = true,
    String groupSeparator = '.',
  }) {
    if (!allowWrap) return exactText;
    final spaced = exactText.replaceAll(' ', ' \u200B');
    return allowGroupBreaks && groupSeparator.isNotEmpty
        ? spaced.replaceAll(groupSeparator, '$groupSeparator\u200B')
        : spaced;
  }

  const MoneyText(
    this.money, {
    super.key,
    this.style,
    this.showSign = false,
    this.colorBySign = false,
    this.semantic = MoneySemantic.automatic,
    this.formatter = const MoneyFormatter.ptBr(),
    this.allowWrap = false,
    this.allowGroupBreaks = true,
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

  /// A size-aware parent can prefer a whole numeric token on its own line.
  /// The default preserves legacy wrapping until that parent is migrated.
  final bool allowGroupBreaks;

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
    final text = wrapDisplay(
      exactText,
      allowWrap: allowWrap,
      allowGroupBreaks: allowGroupBreaks,
      groupSeparator: formatter.groupSeparator,
    );

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
