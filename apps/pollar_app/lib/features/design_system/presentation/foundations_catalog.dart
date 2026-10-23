import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/money_text.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/privacy_amount.dart';

// THESIS: Editorial financial hierarchy, preserving the validated ledger.
// OWN-WORLD: Existing Pollar teal/Inter; one solid tonal focal surface, flat
// groups and structural borders. No new palette, gradients or monetary motion.
// STORY: Developers inspect hierarchy, privacy and keyboard states without
// reading or writing the user's financial data.
// FIRST VIEWPORT: An explicitly labelled specimen leads with confirmed balance,
// projected context and a privacy action; legacy/flat examples follow.
// FORM: User-pinned UI_UX_REDESIGN_POLLAR.md, phase 1; local catalog extension.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
// finish review, the verdict, and DESIGN.md
class FoundationsCatalog extends StatefulWidget {
  const FoundationsCatalog({super.key});

  @override
  State<FoundationsCatalog> createState() => _FoundationsCatalogState();
}

class _FoundationsCatalogState extends State<FoundationsCatalog> {
  var _hidden = false;
  static const _confirmed = Money(minorUnits: 123456, currency: Currency.brl);
  static const _projected = Money(minorUnits: 98456, currency: Currency.brl);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Fundamentos do redesign',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: PollarSpacing.x2),
      Text(
        'Amostras visuais com dados demonstrativos. Nenhuma conta ou transação é criada.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: context.pollar.textSecondary),
      ),
      const SizedBox(height: PollarSpacing.x6),
      PollarCard(
        variant: PollarCardVariant.financial,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Saldo confirmado',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  PollarIconButton(
                    icon: _hidden ? LucideIcons.eyeOff : LucideIcons.eye,
                    label: _hidden
                        ? 'Mostrar valores de exemplo'
                        : 'Ocultar valores de exemplo',
                    onPressed: () => setState(() => _hidden = !_hidden),
                  ),
                ],
              ),
              const SizedBox(height: PollarSpacing.x3),
              PrivacyAmount(
                _confirmed,
                hidden: _hidden,
                semantic: MoneySemantic.balance,
                style: PollarTypography.balanceHeroForWidth(
                  constraints.maxWidth,
                ),
                allowWrap: true,
                reserveLayout: true,
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                'BRL · Exemplo de composição',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
              const SizedBox(height: PollarSpacing.x6),
              Text(
                'Saldo projetado',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: PollarSpacing.x1),
              PrivacyAmount(
                _projected,
                hidden: _hidden,
                semantic: MoneySemantic.balance,
                allowWrap: true,
                reserveLayout: true,
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                'Inclui lançamentos previstos e pendentes.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: PollarSpacing.x6),
      PollarCard(
        variant: PollarCardVariant.flat,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrupamento sem borda',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PollarSpacing.x2),
            const Text(
              'Título, alinhamento e espaço organizam o conteúdo. A superfície não é uma ação.',
            ),
          ],
        ),
      ),
      const SizedBox(height: PollarSpacing.x4),
      PollarCard(
        semanticLabel: 'Inspecionar o padrão interativo',
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contorno para interação',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PollarSpacing.x2),
            const Text(
              'O padrão anterior é preservado. Use Tab e Enter para conferir foco e ativação.',
            ),
          ],
        ),
      ),
    ],
  );
}
