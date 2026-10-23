import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pollar_motion.dart';

typedef PollarCardFace = Widget Function(VoidCallback flip, FocusNode focus);

/// Bounded pointer tilt plus an explicit, keyboard-accessible flip.
/// No drag recognizer competes with the surrounding scroll view.
class PollarKineticCard extends StatefulWidget {
  const PollarKineticCard({super.key, required this.front, required this.back});
  final PollarCardFace front;
  final PollarCardFace back;
  @override
  State<PollarKineticCard> createState() => _PollarKineticCardState();
}

class _PollarKineticCardState extends State<PollarKineticCard>
    with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(
    vsync: this,
    duration: PollarMotion.focal,
  );
  final _frontFocus = FocusNode();
  final _backFocus = FocusNode();
  Offset _tilt = Offset.zero;
  bool _back = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) _flip.value = _back ? 1 : 0;
  }

  Future<void> _toggle() async {
    final restoreFocus = _frontFocus.hasFocus || _backFocus.hasFocus;
    setState(() {
      _back = !_back;
      _tilt = Offset.zero;
    });
    if (PollarMotion.reduced(context)) {
      _flip.value = _back ? 1 : 0;
    } else {
      await _flip.animateTo(_back ? 1 : 0).orCancel.catchError((Object _) {});
    }
    if (mounted && restoreFocus) {
      (_back ? _backFocus : _frontFocus).requestFocus();
    }
  }

  void _move(Offset local, Size size) {
    if (PollarMotion.reduced(context)) return;
    setState(
      () => _tilt = Offset(
        (local.dx / size.width * 2 - 1).clamp(-1, 1),
        (local.dy / size.height * 2 - 1).clamp(-1, 1),
      ),
    );
  }

  void _reset() {
    if (_tilt != Offset.zero) setState(() => _tilt = Offset.zero);
  }

  @override
  void dispose() {
    _flip.dispose();
    _frontFocus.dispose();
    _backFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final reduced = PollarMotion.reduced(context);
      final front = RepaintBoundary(child: widget.front(_toggle, _frontFocus));
      final back = RepaintBoundary(child: widget.back(_toggle, _backFocus));
      return MouseRegion(
        onExit: (_) => _reset(),
        onHover: (event) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) _move(event.localPosition, box.size);
        },
        child: Listener(
          onPointerMove: (event) {
            final box = context.findRenderObject() as RenderBox?;
            if (box != null) _move(event.localPosition, box.size);
          },
          onPointerUp: (_) => _reset(),
          onPointerCancel: (_) => _reset(),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: reduced ? Offset.zero : _tilt),
            duration: reduced ? Duration.zero : PollarMotion.feedback,
            curve: PollarMotion.curve,
            builder: (context, tilt, _) => AnimatedBuilder(
              animation: _flip,
              builder: (context, _) {
                final t = reduced
                    ? (_back ? 1.0 : 0.0)
                    : PollarMotion.curve.transform(_flip.value);
                final showBack = t >= 0.5;
                Widget face({required bool back, required Widget child}) {
                  final visible = back == showBack;
                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.0008)
                    ..rotateX(reduced ? 0 : -tilt.dy * 0.035)
                    ..rotateY(
                      reduced
                          ? 0
                          : tilt.dx * 0.035 +
                                math.pi * t +
                                (back ? math.pi : 0),
                    );
                  return IgnorePointer(
                    ignoring: !visible,
                    child: ExcludeFocus(
                      excluding: !visible,
                      child: ExcludeSemantics(
                        excluding: !visible,
                        child: Visibility(
                          visible: visible,
                          maintainState: true,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: matrix,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final stack = Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    face(back: false, child: front),
                    face(back: true, child: back),
                  ],
                );
                if (reduced) return stack;
                return AnimatedSize(
                  duration: PollarMotion.change,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  child: stack,
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
