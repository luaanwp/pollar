import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/presentation/pollar_motion.dart';
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
                : _ChartMorph(
                    values: _comparisonGeometry(months),
                    builder: (values, reveal) => CustomPaint(
                      painter: _ComparisonPainter(
                        heights: values.map((v) => v * reveal).toList(),
                        incomeColor: colors.success,
                        expenseColor: colors.danger,
                        baselineColor: colors.borderStrong,
                      ),
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
                : _ChartMorph(
                    values: _trendGeometry(months),
                    builder: (values, reveal) => CustomPaint(
                      painter: _TrendPainter(
                        positions: values,
                        reveal: reveal,
                        lineColor: colors.primary,
                        baselineColor: colors.borderStrong,
                      ),
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

// These are drawing coordinates, never interpolated financial records.
List<double> _comparisonGeometry(List<ReportMonth> months) {
  final maxValue = months.fold<int>(
    1,
    (v, m) => math.max(v, math.max(m.income.minorUnits, m.expenses.minorUnits)),
  );
  return [
    for (final month in months) ...[
      month.income.minorUnits / maxValue,
      month.expenses.minorUnits / maxValue,
    ],
  ];
}

List<double> _trendGeometry(List<ReportMonth> months) {
  if (months.isEmpty) return [];
  final values = months.map((m) => m.accountNetBalance.minorUnits).toList();
  final minValue = math.min(0, values.reduce(math.min));
  final maxValue = math.max(0, values.reduce(math.max));
  final span = math.max(1, maxValue - minValue);
  return [
    maxValue / span,
    for (final value in values) (maxValue - value) / span,
  ];
}

class _ChartMorph extends StatefulWidget {
  const _ChartMorph({required this.values, required this.builder});
  final List<double> values;
  final Widget Function(List<double> positions, double reveal) builder;
  @override
  State<_ChartMorph> createState() => _ChartMorphState();
}

class _ChartMorphState extends State<_ChartMorph>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: PollarMotion.focal,
  );
  late List<double> _from = widget.values;
  bool _reveal = true;
  List<double> get _positions {
    final t = PollarMotion.curve.transform(_controller.value);
    return [
      for (var i = 0; i < widget.values.length; i++)
        _from[i] + (widget.values[i] - _from[i]) * t,
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _ChartMorph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.values, widget.values)) return;
    final t = PollarMotion.curve.transform(_controller.value);
    final current = [
      for (var i = 0; i < oldWidget.values.length; i++)
        _from[i] + (oldWidget.values[i] - _from[i]) * t,
    ];
    _reveal = current.length != widget.values.length;
    _from = _reveal ? widget.values : current;
    if (PollarMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(
        _positions,
        _reveal ? PollarMotion.curve.transform(_controller.value) : 1,
      ),
    ),
  );
}

class _ComparisonPainter extends CustomPainter {
  const _ComparisonPainter({
    required this.heights,
    required this.incomeColor,
    required this.expenseColor,
    required this.baselineColor,
  });
  final List<double> heights;
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
    if (heights.isEmpty) return;
    final groupWidth = size.width / (heights.length / 2);
    final barWidth = math.min(18.0, groupWidth * 0.25);
    final gap = math.min(4.0, groupWidth * 0.06);
    for (var i = 0; i < heights.length; i++) {
      final center = groupWidth * (i ~/ 2) + groupWidth / 2;
      final height = math.max(2.0, heights[i] * (size.height - 8));
      final left = i.isEven ? center - gap / 2 - barWidth : center + gap / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, baseline - height, barWidth, height),
          topLeft: const Radius.circular(PollarRadii.small),
          topRight: const Radius.circular(PollarRadii.small),
        ),
        Paint()..color = i.isEven ? incomeColor : expenseColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ComparisonPainter old) =>
      !listEquals(old.heights, heights) ||
      old.incomeColor != incomeColor ||
      old.expenseColor != expenseColor ||
      old.baselineColor != baselineColor;
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.positions,
    required this.reveal,
    required this.lineColor,
    required this.baselineColor,
  });
  final List<double> positions;
  final double reveal;
  final Color lineColor;
  final Color baselineColor;
  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;
    const inset = 6.0;
    double y(double value) => inset + value * (size.height - inset * 2);
    final zeroY = y(positions.first);
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );
    final points = [
      for (var i = 1; i < positions.length; i++)
        Offset(
          positions.length == 2
              ? size.width / 2
              : (i - 1) / (positions.length - 2) * size.width,
          y(positions[i]),
        ),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, zeroY)
      ..lineTo(points.first.dx, zeroY)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = lineColor.withValues(alpha: 0.10 * reveal),
    );
    final visible = reveal == 1 ? path : Path();
    if (reveal < 1) {
      for (final metric in path.computeMetrics()) {
        visible.addPath(
          metric.extractPath(0, metric.length * reveal),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(
      visible,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (reveal == 1) {
      canvas.drawCircle(points.last, 4, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      !listEquals(old.positions, positions) ||
      old.reveal != reveal ||
      old.lineColor != lineColor ||
      old.baselineColor != baselineColor;
}
