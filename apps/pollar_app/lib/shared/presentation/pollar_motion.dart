import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';

/// One motion vocabulary; no animation waits in a persistence callback.
abstract final class PollarMotion {
  static const feedback = Duration(milliseconds: 140);
  static const change = Duration(milliseconds: 240);
  static const focal = Duration(milliseconds: 360);
  static const celebration = Duration(milliseconds: 700);
  static const curve = Curves.easeOutCubic;
  static const branchTravel = PollarSpacing.x6;

  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context) ||
      !TickerMode.valuesOf(context).enabled;
}

/// Paint-only press feedback keeps the native hit target and semantics intact.
class PollarPressMotion extends StatefulWidget {
  const PollarPressMotion({
    super.key,
    required this.child,
    this.enabled = true,
  });
  final Widget child;
  final bool enabled;
  @override
  State<PollarPressMotion> createState() => _PollarPressMotionState();
}

class _PollarPressMotionState extends State<PollarPressMotion> {
  bool _pressed = false;
  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = PollarMotion.reduced(context);
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          _set(event is KeyDownEvent && widget.enabled);
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (focused) {
        if (!focused) _set(false);
      },
      child: Listener(
        onPointerDown: widget.enabled ? (_) => _set(true) : null,
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _pressed && widget.enabled && !reduced ? 0.98 : 1),
          duration: reduced ? Duration.zero : PollarMotion.feedback,
          curve: Curves.easeOutBack,
          child: widget.child,
          builder: (_, scale, child) => Transform.scale(
            scale: scale,
            transformHitTests: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Plays only for a new identity; ordinary privacy/theme rebuilds do not replay.
class PollarReveal extends StatefulWidget {
  const PollarReveal({
    super.key,
    required this.identity,
    required this.child,
    this.index = 0,
    this.onArrival = false,
  });
  final Object identity;
  final Widget child;
  final int index;
  final bool onArrival;
  @override
  State<PollarReveal> createState() => _PollarRevealState();
}

class _PollarRevealState extends State<PollarReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 240 + widget.index.clamp(0, 5) * 20),
    value: widget.onArrival ? 0 : 1,
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) {
      _controller.value = 1;
    } else if (widget.onArrival && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PollarReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity) {
      if (PollarMotion.reduced(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (_, child) {
      final delay = widget.index.clamp(0, 5) * 0.04;
      final t = PollarMotion.curve.transform(
        ((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0),
      );
      return Transform.translate(
        offset: Offset(0, PollarMotion.reduced(context) ? 0 : (1 - t) * 8),
        child: Opacity(opacity: 0.85 + t * 0.15, child: child),
      );
    },
  );
}

/// IndexedStack remains mounted across branch selection: forms keep their state.
class PollarBranchStack extends StatefulWidget {
  const PollarBranchStack({
    super.key,
    required this.index,
    required this.children,
  });
  final int index;
  final List<Widget> children;
  @override
  State<PollarBranchStack> createState() => _PollarBranchStackState();
}

class _PollarBranchStackState extends State<PollarBranchStack>
    with SingleTickerProviderStateMixin {
  late final _arrival = AnimationController(
    vsync: this,
    duration: PollarMotion.change,
    value: 1,
  );
  var _direction = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) {
      _arrival.stop();
      _arrival.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant PollarBranchStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    _direction = widget.index > oldWidget.index ? 1 : -1;
    if (PollarMotion.reduced(context)) {
      _arrival.stop();
      _arrival.value = 1;
    } else {
      _arrival.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _arrival.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRect(
    child: AnimatedBuilder(
      animation: _arrival,
      child: IndexedStack(
        index: widget.index,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            Offstage(
              key: ValueKey('pollar-branch-$i'),
              offstage: i != widget.index,
              child: ExcludeFocus(
                excluding: i != widget.index,
                child: ExcludeSemantics(
                  excluding: i != widget.index,
                  child: TickerMode(
                    enabled: i == widget.index,
                    child: widget.children[i],
                  ),
                ),
              ),
            ),
        ],
      ),
      builder: (context, child) {
        final t = PollarMotion.reduced(context)
            ? 1.0
            : PollarMotion.curve.transform(_arrival.value);
        final readingDirection = Directionality.of(context) == TextDirection.rtl
            ? -1
            : 1;
        return Transform.translate(
          key: const Key('pollar-branch-position'),
          offset: Offset(
            (1 - t) * PollarMotion.branchTravel * _direction * readingDirection,
            0,
          ),
          child: child,
        );
      },
    ),
  );
}

Page<T> pollarMotionPage<T>({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) {
  // Keep the native interactive edge-back gesture on Apple platforms.
  if (Theme.of(context).platform == TargetPlatform.iOS ||
      Theme.of(context).platform == TargetPlatform.macOS) {
    return MaterialPage<T>(key: key, child: child);
  }
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: PollarMotion.reduced(context)
        ? Duration.zero
        : PollarMotion.change,
    reverseTransitionDuration: PollarMotion.reduced(context)
        ? Duration.zero
        : PollarMotion.feedback,
    transitionsBuilder: (context, animation, secondary, child) {
      if (PollarMotion.reduced(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: PollarMotion.curve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// A neutral shuttle avoids copying a financial value into a retained flight.
class PollarCardMorph extends StatelessWidget {
  const PollarCardMorph({
    super.key,
    required this.tag,
    required this.child,
    this.creditIdentity = false,
  });
  final String tag;
  final Widget child;
  final bool creditIdentity;
  @override
  Widget build(BuildContext context) {
    if (PollarMotion.reduced(context)) return child;
    return Hero(
      tag: tag,
      flightShuttleBuilder: (context, animation, direction, from, to) =>
          ExcludeSemantics(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) => Material(
                color: creditIdentity
                    ? context.pollar.creditSurface
                    : context.pollar.financialSurface,
                borderRadius: BorderRadius.circular(
                  PollarRadii.large * (1 - animation.value),
                ),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Icon(
                    LucideIcons.creditCard,
                    size: 24,
                    color: creditIdentity
                        ? context.pollar.creditForeground
                        : context.pollar.primary,
                  ),
                ),
              ),
            ),
          ),
      child: child,
    );
  }
}

class PollarGoalProgress extends StatelessWidget {
  const PollarGoalProgress({
    super.key,
    required this.value,
    required this.hidden,
  });
  final double value;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Semantics(
        label: 'Progresso oculto pelo modo privacidade',
        child: Container(height: 8, color: context.pollar.border),
      );
    }
    return Semantics(
      value: '${(value * 100).round()}%',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: PollarMotion.reduced(context)
            ? Duration.zero
            : PollarMotion.focal,
        curve: PollarMotion.curve,
        builder: (context, progress, _) => ClipRRect(
          borderRadius: BorderRadius.circular(PollarRadii.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.pollar.border,
            color: context.pollar.primary,
          ),
        ),
      ),
    );
  }
}

/// Success feedback is finite, nonblocking and scheduled only after saving.
void showPollarGoalCelebration(BuildContext context) {
  if (PollarMotion.reduced(context)) return;
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: PollarGoalCelebration(
            onDone: () {
              if (entry.mounted) {
                entry.remove();
                entry.dispose();
              }
            },
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
}

class PollarGoalCelebration extends StatefulWidget {
  const PollarGoalCelebration({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<PollarGoalCelebration> createState() => _GoalBurstState();
}

class _GoalBurstState extends State<PollarGoalCelebration>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: PollarMotion.celebration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        });
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) {
      _controller.forward(from: 0.99);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => CustomPaint(
      painter: _GoalBurstPainter(
        progress: PollarMotion.reduced(context) ? 1 : _controller.value,
        color: context.pollar.primary,
      ),
    ),
  );
}

class _GoalBurstPainter extends CustomPainter {
  const _GoalBurstPainter({required this.progress, required this.color});
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final t = PollarMotion.curve.transform(progress);
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 20 + 60 * t, paint);
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final offset = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + offset * (32 + 40 * t),
        center + offset * (38 + 52 * t),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoalBurstPainter old) =>
      old.progress != progress || old.color != color;
}
