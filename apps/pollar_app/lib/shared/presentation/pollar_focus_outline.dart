// THESIS: o foco de teclado deve permanecer distinto da cor do botão.
// OWN-WORLD: contorno info de 2px, afastado 2px, sem mudar a geometria Pollar.
// STORY: percorrer ações pelo teclado e reconhecer qual será ativada.
// FIRST VIEWPORT: o controle focado mantém conteúdo e alvo; o contorno ocupa só a pintura externa.
// FORM: acabamento dos controles nativos existentes, sem nova identidade.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';

/// Keyboard-only outline; native descendants still own focus and activation.
class PollarFocusOutline extends StatefulWidget {
  const PollarFocusOutline({
    super.key,
    required this.child,
    this.enabled = true,
  });
  final Widget child;
  final bool enabled;
  @override
  State<PollarFocusOutline> createState() => _PollarFocusOutlineState();
}

class _PollarFocusOutlineState extends State<PollarFocusOutline> {
  final _focus = FocusNode(canRequestFocus: false, skipTraversal: true);
  var _highlight = false;
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    focusNode: _focus,
    enabled: widget.enabled,
    includeFocusSemantics: false,
    onShowFocusHighlight: (value) {
      if (mounted && value != _highlight) setState(() => _highlight = value);
    },
    child: CustomPaint(
      foregroundPainter: widget.enabled && _highlight
          ? _FocusRingPainter(context.pollar.info)
          : null,
      child: widget.child,
    ),
  );
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    // 2px empty gap, then a 2px stroke centered 3px beyond the native edge.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).inflate(3),
        const Radius.circular(PollarRadii.medium + 3),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      color != oldDelegate.color;
}
