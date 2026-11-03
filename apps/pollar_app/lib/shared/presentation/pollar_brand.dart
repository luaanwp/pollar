// THESIS: the approved P monogram is the single identifying mark for Pollar.
// OWN-WORLD: solid teal/mint, open diagonal counter and bundled Inter SemiBold.
// STORY: identify the application before signing in or navigating.
// FIRST VIEWPORT: one quiet brand signature; no extra panels or decoration.
// FORM: the same vector geometry as assets/brand and native launcher icons.
// FINISH: independent review and documentation close the implementation.
import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';
import 'pollar_brand_geometry.dart';

/// Vector monogram; decorative when the adjacent wordmark supplies the name.
class PollarBrandMark extends StatelessWidget {
  const PollarBrandMark({super.key, this.height = 28});
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: height * 603 / 668,
      height: height,
      child: CustomPaint(painter: _MarkPainter(context.pollar.primary)),
    ),
  );
}

class PollarBrand extends StatelessWidget {
  const PollarBrand({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const PollarBrandMark(),
      const SizedBox(width: PollarSpacing.x3),
      Flexible(
        child: Text(
          'Pollar',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.pollar.primary,
          ),
        ),
      ),
    ],
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 603, size.height / 668);
    canvas.drawPath(createPollarMarkPath(), Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => color != oldDelegate.color;
}
