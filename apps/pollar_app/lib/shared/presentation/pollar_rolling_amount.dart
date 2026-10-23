import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';
import 'money_text.dart';
import 'pollar_motion.dart';

/// Rolls between actual formatted states, never through calculated money.
/// The canonical MoneyText remains the sole semantics source at every frame.
class PollarRollingAmount extends StatefulWidget {
  const PollarRollingAmount({super.key, required this.child});
  final MoneyText child;
  @override
  State<PollarRollingAmount> createState() => _PollarRollingAmountState();
}

class _PollarRollingAmountState extends State<PollarRollingAmount>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: PollarMotion.focal,
    value: 1,
  );
  String? _previous;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) {
      _controller.value = 1;
      _previous = null;
    }
  }

  @override
  void didUpdateWidget(covariant PollarRollingAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.child;
    final current = widget.child;
    if (old.money.currency != current.money.currency ||
        PollarMotion.reduced(context)) {
      _previous = null;
      _controller.value = 1;
    } else if (old.money != current.money) {
      _previous = old.formatter.format(old.money, showSign: old.showSign);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final current = widget.child;
      final text = current.formatter.format(
        current.money,
        showSign: current.showSign,
      );
      var color = context.pollar.textPrimary;
      if (current.colorBySign && !current.money.isZero) {
        color = current.money.isNegative
            ? context.pollar.danger
            : context.pollar.success;
      }
      final style = PollarTypography.tabular(
        current.style ?? PollarTypography.amountStandard,
      ).copyWith(color: color);
      final painter = TextPainter(
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      );
      double width(String value) {
        painter.text = TextSpan(text: value, style: style);
        painter.layout();
        return painter.width;
      }

      final fits =
          width(text) <= constraints.maxWidth &&
          (_previous == null || width(_previous!) <= constraints.maxWidth);
      painter.dispose();
      if (!fits || PollarMotion.reduced(context)) return current;
      return AnimatedBuilder(
        animation: _controller,
        child: current,
        builder: (context, child) {
          if (_controller.isCompleted || _previous == null) return child!;
          return Stack(
            children: [
              Opacity(opacity: 0, alwaysIncludeSemantics: true, child: child),
              Positioned.fill(
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: ClipRect(
                      child: CustomPaint(
                        painter: _RollingPainter(
                          from: _previous!,
                          to: text,
                          style: style,
                          scaler: MediaQuery.textScalerOf(context),
                          direction: Directionality.of(context),
                          progress: PollarMotion.curve.transform(
                            _controller.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _RollingPainter extends CustomPainter {
  const _RollingPainter({
    required this.from,
    required this.to,
    required this.style,
    required this.scaler,
    required this.direction,
    required this.progress,
  });
  final String from;
  final String to;
  final TextStyle style;
  final TextScaler scaler;
  final TextDirection direction;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(textDirection: direction, textScaler: scaler);
    void draw(String text, Offset at, double opacity) {
      painter.text = TextSpan(
        text: text,
        style: style.copyWith(color: style.color!.withValues(alpha: opacity)),
      );
      painter.layout();
      painter.paint(canvas, at);
    }

    if (from.length != to.length) {
      draw(from, Offset(0, -progress * size.height * 0.65), 1 - progress);
      draw(to, Offset(0, (1 - progress) * size.height * 0.65), progress);
    } else {
      var x = 0.0;
      for (var i = 0; i < to.length; i++) {
        painter.text = TextSpan(text: to.substring(0, i), style: style);
        painter.layout();
        x = painter.width;
        if (from[i] == to[i]) {
          draw(to[i], Offset(x, 0), 1);
        } else {
          draw(
            from[i],
            Offset(x, -progress * size.height * 0.65),
            1 - progress,
          );
          draw(to[i], Offset(x, (1 - progress) * size.height * 0.65), progress);
        }
      }
    }
    painter.dispose();
  }

  @override
  bool shouldRepaint(covariant _RollingPainter old) =>
      old.progress != progress ||
      old.from != from ||
      old.to != to ||
      old.style != style ||
      old.scaler != scaler ||
      old.direction != direction;
}
