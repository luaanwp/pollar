// THESIS: converging ledger strokes introduce Pollar before the login form.
// OWN-WORLD: canonical P, solid theme teal/mint, Inter, native 10px controls.
// STORY: choose Entrar to sign in/unlock, or Cadastrar to confirm a new email.
// FIRST VIEWPORT: brand above an open ledger stage, large copy and wide action;
// on desktop the ledger moves beside the copy, retaining its visual weight.
// FORM: kinetic ledger, structure 4, seed 8cc36f0b; approved welcome-b-ledger.png.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
// finish review, the verdict, and DESIGN.md
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_brand.dart';
import '../../../shared/presentation/pollar_brand_geometry.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_focus_outline.dart';
import '../../../shared/presentation/pollar_motion.dart';
import 'auth_controller.dart';

/// Public start screen, including when a saved session still needs unlocking.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= PollarBreakpoints.expandedMin &&
              MediaQuery.textScalerOf(context).scale(16) <= 24;
          final gutter = wide ? PollarSpacing.x12 : PollarSpacing.x6;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 0),
                        child: const PollarBrand(),
                      ),
                      if (wide)
                        Padding(
                          padding: EdgeInsets.fromLTRB(gutter, 48, 0, 64),
                          child: Row(
                            children: [
                              const Expanded(child: _WelcomeCopy(wide: true)),
                              const SizedBox(width: 48),
                              Expanded(
                                child: SizedBox(
                                  height: (constraints.maxHeight * .65).clamp(
                                    420.0,
                                    600.0,
                                  ),
                                  child: const _LedgerArtwork(),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          height: (constraints.maxHeight * .38).clamp(
                            220.0,
                            400.0,
                          ),
                          child: const _LedgerArtwork(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 32),
                          child: const _WelcomeCopy(wide: false),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final titleSize = wide
        ? 54.0
        : MediaQuery.sizeOf(context).width < 360
        ? 32.0
        : 36.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Seu dinheiro,\ncom mais clareza.',
            style: text.displayLarge?.copyWith(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: -.7,
            ),
          ),
        ),
        const SizedBox(height: PollarSpacing.x5),
        Text(
          'Organize contas, acompanhe movimentos e planeje os próximos passos.',
          style: text.bodyLarge?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x10),
        const _WelcomeAction(),
        const SizedBox(height: PollarSpacing.x3),
        PollarButton(
          key: const Key('welcome-register'),
          label: 'Cadastrar',
          onPressed: () => context.push('/sign-up'),
          variant: PollarButtonVariant.secondary,
          fullWidth: true,
          adaptiveHeight: true,
          size: PollarControlSize.prominent,
          leadingIcon: LucideIcons.userPlus,
        ),
        const SizedBox(height: PollarSpacing.x8),
        Text(
          'Contas e cartões · Movimentações · Planejamento',
          style: text.bodyMedium?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
    );
  }
}

class _WelcomeAction extends ConsumerWidget {
  const _WelcomeAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) => PollarFocusOutline(
    child: PollarPressMotion(
      child: TextButton(
        key: const Key('welcome-enter'),
        onPressed: () => context.push(
          ref.read(authGatewayProvider).currentSession == null
              ? '/sign-in'
              : '/overview',
        ),
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
          foregroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.onPrimary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? context.pollar.primaryHover
                : context.pollar.primary,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PollarRadii.medium),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        child: const Row(
          children: [
            Expanded(child: Text('Entrar')),
            SizedBox(width: 16),
            ExcludeSemantics(child: Icon(LucideIcons.arrowRight, size: 24)),
          ],
        ),
      ),
    ),
  );
}

class _LedgerArtwork extends StatefulWidget {
  const _LedgerArtwork();

  @override
  State<_LedgerArtwork> createState() => _LedgerArtworkState();
}

class _LedgerArtworkState extends State<_LedgerArtwork>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PollarMotion.reduced(context)) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(
        key: const Key('welcome-ledger'),
        painter: _LedgerPainter(
          animation: _controller,
          primary: context.pollar.primary,
          secondary: context.pollar.primarySoft,
        ),
      ),
    ),
  );
}

class _LedgerPainter extends CustomPainter {
  _LedgerPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;
  final _mark = createPollarMarkPath();

  @override
  void paint(Canvas canvas, Size size) {
    final markHeight = math.min(size.height * .60, size.width * .44);
    final markWidth = markHeight * 603 / 668;
    final left = size.width - markWidth - size.width * .05;
    final top = (size.height - markHeight) / 2;
    final stroke = markHeight * .09;
    final curve = markHeight * .14;
    final colors = [primary, primary.withValues(alpha: .65), secondary];
    final levels = [.10, .45, .83];

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var i = 0; i < 3; i++) {
      final y = top + markHeight * levels[i];
      final path = Path()..moveTo(0, y);
      if (i == 1) {
        path.lineTo(left + stroke / 2, y);
      } else {
        final direction = i == 0 ? 1.0 : -1.0;
        path
          ..lineTo(left - curve, y)
          ..quadraticBezierTo(
            left + stroke / 2,
            y,
            left + stroke / 2,
            y + direction * curve,
          );
      }
      final progress = Curves.easeOutCubic.transform(
        ((animation.value - i * .12) / .76).clamp(0.0, 1.0),
      );
      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Preserve the canonical outline and counter; strokes stop at its edge.
    canvas.save();
    canvas.translate(left, top);
    canvas.scale(markWidth / 603, markHeight / 668);
    canvas.drawPath(_mark, Paint()..color = primary);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LedgerPainter oldDelegate) =>
      animation != oldDelegate.animation ||
      primary != oldDelegate.primary ||
      secondary != oldDelegate.secondary;
}
