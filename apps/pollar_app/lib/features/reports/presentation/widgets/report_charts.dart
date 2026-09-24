import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money_formatter.dart';
import '../../domain/report_snapshot.dart';

class MonthlyComparisonChart extends StatelessWidget {
  const MonthlyComparisonChart({
    super.key,
    required this.months,
    required this.privacyHidden,
  });

  final List<ReportMonth> months;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final formatter = DateFormat.MMM('pt_BR');
    final money = const MoneyFormatter.ptBr();
    final semantics = privacyHidden
        ? 'Comparação mensal com valores ocultos pelo modo privacidade'
        : months
              .map(
                (item) =>
                    '${formatter.format(item.month)}: entradas ${money.format(item.income)}, saídas ${money.format(item.expenses)}',
              )
              .join('; ');
    return Semantics(
      label: semantics,
      image: true,
      excludeSemantics: true,
      child: Column(
        children: [
          Wrap(
            spacing: PollarSpacing.x4,
            runSpacing: PollarSpacing.x2,
            children: [
              _Legend(color: colors.success, label: 'Entradas'),
              _Legend(color: colors.danger, label: 'Saídas'),
            ],
          ),
          const SizedBox(height: PollarSpacing.x4),
          SizedBox(
            height: 156,
            width: double.infinity,
            child: privacyHidden
                ? const _HiddenChart()
                : CustomPaint(
                    painter: _ComparisonPainter(
                      months: months,
                      incomeColor: colors.success,
                      expenseColor: colors.danger,
                      baselineColor: colors.borderStrong,
                    ),
                  ),
          ),
          const SizedBox(height: PollarSpacing.x2),
          Row(
            children: [
              for (final item in months)
                Expanded(
                  child: Text(
                    formatter.format(item.month).replaceAll('.', ''),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BalanceTrendChart extends StatelessWidget {
  const BalanceTrendChart({
    super.key,
    required this.months,
    required this.privacyHidden,
  });

  final List<ReportMonth> months;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final formatter = DateFormat.MMM('pt_BR');
    final money = const MoneyFormatter.ptBr();
    final semantics = privacyHidden
        ? 'Evolução do saldo líquido com valores ocultos pelo modo privacidade'
        : months
              .map(
                (item) =>
                    '${formatter.format(item.month)}: ${money.format(item.accountNetBalance)}',
              )
              .join('; ');
    return Semantics(
      label: semantics,
      image: true,
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: 176,
            width: double.infinity,
            child: privacyHidden
                ? const _HiddenChart()
                : CustomPaint(
                    painter: _TrendPainter(
                      months: months,
                      lineColor: colors.primary,
                      baselineColor: colors.borderStrong,
                    ),
                  ),
          ),
          const SizedBox(height: PollarSpacing.x2),
          Row(
            children: [
              for (final item in months)
                Expanded(
                  child: Text(
                    formatter.format(item.month).replaceAll('.', ''),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HiddenChart extends StatelessWidget {
  const _HiddenChart();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.pollar.surfaceAlt,
      borderRadius: BorderRadius.circular(PollarRadii.medium),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.eyeOff, size: 20, color: context.pollar.textMuted),
          const SizedBox(height: PollarSpacing.x2),
          Text(
            'Valores ocultos',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: PollarSpacing.x2),
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textSecondary),
      ),
    ],
  );
}

class _ComparisonPainter extends CustomPainter {
  const _ComparisonPainter({
    required this.months,
    required this.incomeColor,
    required this.expenseColor,
    required this.baselineColor,
  });

  final List<ReportMonth> months;
  final Color incomeColor;
  final Color expenseColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height - 1;
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );
    if (months.isEmpty) return;
    final maxMinor = months.fold<int>(
      1,
      (value, item) => math.max(
        value,
        math.max(item.income.minorUnits, item.expenses.minorUnits),
      ),
    );
    final groupWidth = size.width / months.length;
    final barWidth = math.min(18.0, groupWidth * 0.25);
    final gap = math.min(4.0, groupWidth * 0.06);
    for (var index = 0; index < months.length; index++) {
      final item = months[index];
      final center = groupWidth * index + groupWidth / 2;
      _bar(
        canvas,
        center - gap / 2 - barWidth,
        baseline,
        barWidth,
        item.income.minorUnits,
        maxMinor,
        incomeColor,
        size.height,
      );
      _bar(
        canvas,
        center + gap / 2,
        baseline,
        barWidth,
        item.expenses.minorUnits,
        maxMinor,
        expenseColor,
        size.height,
      );
    }
  }

  void _bar(
    Canvas canvas,
    double left,
    double baseline,
    double width,
    int value,
    int maxValue,
    Color color,
    double availableHeight,
  ) {
    final height = math.max(2.0, value / maxValue * (availableHeight - 8));
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(left, baseline - height, width, height),
        topLeft: const Radius.circular(PollarRadii.small),
        topRight: const Radius.circular(PollarRadii.small),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ComparisonPainter oldDelegate) =>
      oldDelegate.months != months ||
      oldDelegate.incomeColor != incomeColor ||
      oldDelegate.expenseColor != expenseColor ||
      oldDelegate.baselineColor != baselineColor;
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.months,
    required this.lineColor,
    required this.baselineColor,
  });

  final List<ReportMonth> months;
  final Color lineColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty) return;
    final values = months.map((item) => item.accountNetBalance.minorUnits);
    final minValue = math.min(0, values.reduce(math.min));
    final maxValue = math.max(0, values.reduce(math.max));
    final span = math.max(1, maxValue - minValue);
    const inset = 6.0;
    final graphHeight = size.height - inset * 2;
    double yFor(int value) => inset + (maxValue - value) / span * graphHeight;
    final zeroY = yFor(0);
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );

    final path = Path();
    final points = <Offset>[];
    for (var index = 0; index < months.length; index++) {
      final x = months.length == 1
          ? size.width / 2
          : index / (months.length - 1) * size.width;
      final point = Offset(x, yFor(months[index].accountNetBalance.minorUnits));
      points.add(point);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, zeroY)
      ..lineTo(points.first.dx, zeroY)
      ..close();
    canvas.drawPath(area, Paint()..color = lineColor.withValues(alpha: 0.10));
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(points.last, 4, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.months != months ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.baselineColor != baselineColor;
}
