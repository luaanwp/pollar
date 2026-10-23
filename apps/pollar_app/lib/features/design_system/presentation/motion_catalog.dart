import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_kinetic_card.dart';
import '../../../shared/presentation/pollar_motion.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../reports/domain/report_snapshot.dart';
import '../../reports/presentation/widgets/report_charts.dart';

/// Isolated, explicitly demonstrative motion sample; no profile or database.
class MotionCatalog extends StatefulWidget {
  const MotionCatalog({super.key});
  @override
  State<MotionCatalog> createState() => _MotionCatalogState();
}

class _MotionCatalogState extends State<MotionCatalog> {
  int _step = 0;
  bool _hidden = false;
  bool _reduced = false;

  Money amount(int value) => Money(minorUnits: value, currency: Currency.brl);
  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      disableAnimations: _reduced || MediaQuery.disableAnimationsOf(context),
    ),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Movimento Pollar'),
          actions: [
            PollarIconButton(
              label: _hidden ? 'Mostrar valores' : 'Ocultar valores',
              icon: _hidden ? LucideIcons.eyeOff : LucideIcons.eye,
              onPressed: () => setState(() => _hidden = !_hidden),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(PollarSpacing.x4),
              children: [
                Text(
                  'Amostra demonstrativa, sem dados da sua conta.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SwitchListTile(
                  title: const Text('Reduzir movimento'),
                  value: _reduced,
                  onChanged: (value) => setState(() => _reduced = value),
                ),
                PollarCard(
                  variant: PollarCardVariant.financial,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Saldo demonstrativo',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: PollarSpacing.x2),
                      PrivacyAmount(
                        amount(_step.isEven ? 803000 : 817520),
                        hidden: _hidden,
                        animateChanges: true,
                        allowWrap: true,
                        reserveLayout: true,
                        style: PollarTypography.balanceHeroCompact,
                      ),
                      const SizedBox(height: PollarSpacing.x4),
                      PollarButton(
                        label: 'Atualizar amostra',
                        leadingIcon: LucideIcons.refreshCw,
                        onPressed: () => setState(() => _step++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PollarSpacing.x6),
                PollarKineticCard(
                  front: (flip, focus) => PollarCard(
                    child: Row(
                      children: [
                        const Icon(LucideIcons.creditCard),
                        const SizedBox(width: PollarSpacing.x4),
                        const Expanded(child: Text('Cartão demonstrativo')),
                        PollarIconButton(
                          label: 'Virar cartão demonstrativo',
                          icon: LucideIcons.flipHorizontal,
                          focusNode: focus,
                          onPressed: flip,
                        ),
                      ],
                    ),
                  ),
                  back: (flip, focus) => PollarCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Verso demonstrativo. Nenhum dado bancário real.',
                          ),
                        ),
                        PollarIconButton(
                          label: 'Voltar à frente',
                          icon: LucideIcons.flipHorizontal,
                          focusNode: focus,
                          onPressed: flip,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: PollarSpacing.x6),
                Text(
                  'Gráfico demonstrativo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: PollarSpacing.x4),
                BalanceTrendChart(
                  privacyHidden: _hidden,
                  months: [
                    for (var i = 0; i < 6; i++)
                      ReportMonth(
                        month: DateTime(2026, 5 + i),
                        income: amount(150000),
                        expenses: amount(120000),
                        netResult: amount(30000),
                        accountNetBalance: amount(
                          500000 + i * (_step.isEven ? 20000 : 40000),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: PollarSpacing.x6),
                Text(
                  'Meta demonstrativa',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: PollarSpacing.x4),
                PollarGoalProgress(
                  value: _step.isEven ? 0.65 : 1,
                  hidden: _hidden,
                ),
                const SizedBox(height: PollarSpacing.x4),
                PollarButton(
                  label: 'Reproduzir celebração',
                  variant: PollarButtonVariant.secondary,
                  onPressed: () => showPollarGoalCelebration(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
