// THESIS: O mês é uma sequência de faixas reconciliadas; recusa separar orçamento, agenda e lembretes em destinos sem contexto comum.
// OWN-WORLD: Canvas planos, bordas finas, teal só em ações, estados por texto e ícone e valores exatos em algarismos tabulares.
// STORY: A pessoa lê a capacidade do mês, confere limites por categoria, percorre vencimentos e cadastra uma nova regra ou orçamento.
// FIRST VIEWPORT: Mês e disponível no orçamento lideram uma faixa compacta; agenda vem primeiro no celular e divide a largura com limites no desktop.
// FORM: “Faixas de planejamento”, sexta estrutura da lista orientada pelo seed 1f953018.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/money_text.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_motion.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/planning_snapshot.dart';
import '../domain/budget.dart';
import '../domain/recurring_rule.dart';
import 'planning_controller.dart';
import 'planning_forms.dart';

class PlanningScreen extends ConsumerWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planning = ref.watch(planningProvider);
    return planning.when(
      loading: () => const PollarLoadingState(
        message: 'Organizando o planejamento do mês…',
      ),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível carregar o planejamento',
        message: 'Os dados continuam salvos. Tente abrir o mês novamente.',
        actionLabel: 'Carregar planejamento',
        onRetry: ref.read(planningProvider.notifier).retry,
      ),
      data: (state) => _PlanningContent(state: state),
    );
  }
}

class _PlanningContent extends ConsumerWidget {
  const _PlanningContent({required this.state});

  final PlanningState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final snapshot = state.snapshot;
    final privacyHidden = ref.watch(privacyModeProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
        child: ListView(
          padding: EdgeInsets.all(
            compact ? PollarSpacing.x4 : PollarSpacing.x6,
          ),
          children: [
            _PlanningHeader(
              state: state,
              compact: compact,
              onPrevious: ref.read(planningProvider.notifier).previousMonth,
              onNext: ref.read(planningProvider.notifier).nextMonth,
              onCurrencyChanged: ref
                  .read(planningProvider.notifier)
                  .selectCurrency,
            ),
            const SizedBox(height: PollarSpacing.x5),
            _PositionBand(snapshot: snapshot, privacyHidden: privacyHidden),
            const SizedBox(height: PollarSpacing.x4),
            _PlanningActions(
              onNewBudget: () => _newBudget(context, ref),
              onNewRule: state.accounts.isEmpty
                  ? null
                  : () => _newRule(context, ref),
            ),
            const SizedBox(height: PollarSpacing.x6),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 960 && !reflow;
                final budgets = _BudgetBand(
                  snapshot: snapshot,
                  privacyHidden: privacyHidden,
                  onCreate: () => _newBudget(context, ref),
                );
                final agenda = _AgendaBand(
                  occurrences: snapshot.occurrences,
                  privacyHidden: privacyHidden,
                  onCreate: state.accounts.isEmpty
                      ? null
                      : () => _newRule(context, ref),
                );
                if (!sideBySide) {
                  return Column(
                    children: [
                      agenda,
                      const SizedBox(height: PollarSpacing.x6),
                      budgets,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: agenda),
                    const SizedBox(width: PollarSpacing.x6),
                    Expanded(flex: 2, child: budgets),
                  ],
                );
              },
            ),
            const SizedBox(height: PollarSpacing.x6),
            _SubscriptionBand(
              subscriptions: snapshot.subscriptions,
              privacyHidden: privacyHidden,
            ),
            const SizedBox(height: PollarSpacing.x6),
            _ReminderBand(reminders: snapshot.reminders),
            const SizedBox(height: PollarSpacing.x6),
            _PlanManagementBand(
              budgets: state.budgets
                  .where(
                    (item) =>
                        item.month == snapshot.month &&
                        item.limit.currency == snapshot.currency,
                  )
                  .toList(growable: false),
              rules: state.recurringRules
                  .where((item) => item.amount.currency == snapshot.currency)
                  .toList(growable: false),
              onBudgetChanged: (budget, active) =>
                  _setBudgetActive(context, ref, budget, active),
              onRuleChanged: (rule, active) =>
                  _setRuleActive(context, ref, rule, active),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newBudget(BuildContext context, WidgetRef ref) async {
    final saved = await showBudgetForm(
      context: context,
      month: state.snapshot.month,
      currency: state.snapshot.currency,
      onSave: ref.read(planningProvider.notifier).createBudget,
    );
    if (saved == true && context.mounted) {
      showPollarToast(context, message: 'Orçamento salvo.');
    }
  }

  Future<void> _newRule(BuildContext context, WidgetRef ref) async {
    final saved = await showRecurringRuleForm(
      context: context,
      accounts: state.accounts,
      initialDate: DateTime(
        state.snapshot.month.year,
        state.snapshot.month.month,
        ref
            .read(planningClockProvider)()
            .day
            .clamp(
              1,
              DateTime(
                state.snapshot.month.year,
                state.snapshot.month.month + 1,
                0,
              ).day,
            ),
      ),
      onSave: ref.read(planningProvider.notifier).createRecurringRule,
    );
    if (saved == true && context.mounted) {
      showPollarToast(context, message: 'Compromisso recorrente salvo.');
    }
  }

  Future<void> _setBudgetActive(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
    bool active,
  ) async {
    final confirmed = await _confirmLifecycle(
      context,
      title: active ? 'Retomar orçamento?' : 'Pausar orçamento?',
      description: active
          ? 'O limite de ${budget.category} voltará aos totais deste mês.'
          : 'O limite de ${budget.category} sairá dos totais, mas continuará salvo para ser retomado.',
      action: active ? 'Retomar orçamento' : 'Pausar orçamento',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(planningProvider.notifier).setBudgetActive(budget, active);
      if (context.mounted) {
        showPollarToast(
          context,
          message: active ? 'Orçamento retomado.' : 'Orçamento pausado.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        showPollarToast(
          context,
          message: 'Não foi possível alterar o orçamento. Tente novamente.',
          tone: PollarStatusTone.danger,
        );
      }
    }
  }

  Future<void> _setRuleActive(
    BuildContext context,
    WidgetRef ref,
    RecurringRule rule,
    bool active,
  ) async {
    final confirmed = await _confirmLifecycle(
      context,
      title: active ? 'Retomar compromisso?' : 'Pausar compromisso?',
      description: active
          ? '${rule.description} voltará à agenda e aos lembretes.'
          : '${rule.description} sairá da agenda e dos lembretes, mas continuará salvo para ser retomado.',
      action: active ? 'Retomar compromisso' : 'Pausar compromisso',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(planningProvider.notifier).setRuleActive(rule, active);
      if (context.mounted) {
        showPollarToast(
          context,
          message: active ? 'Compromisso retomado.' : 'Compromisso pausado.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        showPollarToast(
          context,
          message: 'Não foi possível alterar o compromisso. Tente novamente.',
          tone: PollarStatusTone.danger,
        );
      }
    }
  }

  Future<bool> _confirmLifecycle(
    BuildContext context, {
    required String title,
    required String description,
    required String action,
  }) async =>
      await showPollarAdaptiveModal<bool>(
        context: context,
        title: title,
        description: description,
        icon: LucideIcons.pause,
        actions: (modalContext) => [
          PollarButton(
            label: 'Cancelar',
            adaptiveHeight: true,
            variant: PollarButtonVariant.ghost,
            onPressed: () => Navigator.of(modalContext).pop(false),
          ),
          PollarButton(
            label: action,
            adaptiveHeight: true,
            onPressed: () => Navigator.of(modalContext).pop(true),
          ),
        ],
      ) ??
      false;
}

class _PlanningHeader extends StatelessWidget {
  const _PlanningHeader({
    required this.state,
    required this.compact,
    required this.onPrevious,
    required this.onNext,
    required this.onCurrencyChanged,
  });

  final PlanningState state;
  final bool compact;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<Currency> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy', 'pt_BR').format(state.snapshot.month);
    final title = month[0].toUpperCase() + month.substring(1);
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planejamento de $title',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
    final period = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PollarIconButton(
          icon: LucideIcons.chevronLeft,
          label: 'Mês anterior',
          onPressed: onPrevious,
          outlined: true,
        ),
        const SizedBox(width: PollarSpacing.x2),
        PollarIconButton(
          icon: LucideIcons.chevronRight,
          label: 'Próximo mês',
          onPressed: onNext,
          outlined: true,
        ),
      ],
    );
    final currency = state.currencies.length > 1
        ? SizedBox(
            width: compact ? double.infinity : 132,
            child: PollarSelect(
              label: 'Moeda',
              initialValue: state.snapshot.currency,
              options: [
                for (final item in state.currencies)
                  PollarSelectOption(value: item, label: item.code),
              ],
              onChanged: (value) {
                if (value != null) onCurrencyChanged(value);
              },
            ),
          )
        : const SizedBox.shrink();
    if (compact || MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          copy,
          const SizedBox(height: PollarSpacing.x4),
          Row(
            children: [
              period,
              const SizedBox(width: PollarSpacing.x4),
              if (state.currencies.length > 1) Expanded(child: currency),
            ],
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: copy),
            period,
          ],
        ),
        if (state.currencies.length > 1) ...[
          const SizedBox(height: PollarSpacing.x3),
          Align(alignment: AlignmentDirectional.centerStart, child: currency),
        ],
      ],
    );
  }
}

class _PlanningActions extends StatelessWidget {
  const _PlanningActions({required this.onNewBudget, required this.onNewRule});
  final VoidCallback onNewBudget;
  final VoidCallback? onNewRule;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: PollarSpacing.x2,
    runSpacing: PollarSpacing.x2,
    children: [
      PollarButton(
        label: 'Novo compromisso',
        leadingIcon: LucideIcons.repeat2,
        adaptiveHeight: true,
        onPressed: onNewRule,
      ),
      PollarButton(
        label: 'Novo orçamento',
        leadingIcon: LucideIcons.plus,
        variant: PollarButtonVariant.secondary,
        adaptiveHeight: true,
        onPressed: onNewBudget,
      ),
    ],
  );
}

class _PositionBand extends StatelessWidget {
  const _PositionBand({required this.snapshot, required this.privacyHidden});

  final PlanningSnapshot snapshot;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final remaining = snapshot.totalBudgeted - snapshot.totalSpent;
    return PollarCard(
      variant: PollarCardVariant.financial,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= 820 &&
              MediaQuery.textScalerOf(context).scale(1) <= 1.3;
          final available = _Metric(
            label: 'Disponível no orçamento',
            value: remaining,
            hidden: privacyHidden,
            focal: true,
          );
          final supporting = [
            _Metric(
              label: 'Total orçado',
              value: snapshot.totalBudgeted,
              hidden: privacyHidden,
            ),
            _Metric(
              label: 'Gasto registrado',
              value: snapshot.totalSpent,
              hidden: privacyHidden,
            ),
            _Metric(
              label: 'Compromissos de saída',
              value: snapshot.recurringExpenses,
              hidden: privacyHidden,
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Posição planejada',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: PollarSpacing.x3),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: available),
                    for (final metric in supporting) ...[
                      const SizedBox(width: PollarSpacing.x4),
                      Expanded(child: metric),
                    ],
                  ],
                )
              else ...[
                available,
                const SizedBox(height: PollarSpacing.x4),
                LayoutBuilder(
                  builder: (context, inner) {
                    final pair =
                        inner.maxWidth >= 280 &&
                        MediaQuery.textScalerOf(context).scale(1) <= 1.3;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (pair)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: supporting[0]),
                              const SizedBox(width: PollarSpacing.x3),
                              Expanded(child: supporting[1]),
                            ],
                          )
                        else ...[
                          supporting[0],
                          const SizedBox(height: PollarSpacing.x3),
                          supporting[1],
                        ],
                        const SizedBox(height: PollarSpacing.x3),
                        supporting[2],
                      ],
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.hidden,
    this.focal = false,
  });

  final String label;
  final Money value;
  final bool hidden;
  final bool focal;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textSecondary),
      ),
      const SizedBox(height: PollarSpacing.x1),
      PrivacyAmount(
        value,
        hidden: hidden,
        style: focal
            ? PollarTypography.amountHero
            : PollarTypography.amountStandard,
        semantic: MoneySemantic.neutral,
        allowWrap: true,
        reserveLayout: true,
        animateChanges: focal,
      ),
    ],
  );
}

class _BudgetBand extends StatelessWidget {
  const _BudgetBand({
    required this.snapshot,
    required this.privacyHidden,
    required this.onCreate,
  });

  final PlanningSnapshot snapshot;
  final bool privacyHidden;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Orçamentos por categoria',
          action: 'Adicionar',
          onAction: onCreate,
        ),
        const SizedBox(height: PollarSpacing.x4),
        if (snapshot.budgets.isEmpty)
          const _InlineEmpty(
            icon: LucideIcons.gauge,
            title: 'Nenhum orçamento neste mês',
            message: 'Crie um limite para comparar com as despesas registradas por categoria.',
          )
        else
          for (var index = 0; index < snapshot.budgets.length; index++) ...[
            _BudgetRow(
              progress: snapshot.budgets[index],
              hidden: privacyHidden,
            ),
            if (index != snapshot.budgets.length - 1)
              const SizedBox(height: PollarSpacing.x5),
          ],
      ],
    ),
  );
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.progress, required this.hidden});

  final BudgetProgress progress;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final color = progress.exceeded
        ? context.pollar.danger
        : progress.alerting
        ? context.pollar.warning
        : context.pollar.primary;
    return Semantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            progress.budget.category,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: PollarSpacing.x2),
          LayoutBuilder(
            builder: (context, constraints) {
              final spent = _Metric(
                label: 'Gasto registrado',
                value: progress.spent,
                hidden: hidden,
              );
              final limit = _Metric(
                label: 'Limite',
                value: progress.budget.limit,
                hidden: hidden,
              );
              if (constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    spent,
                    const SizedBox(height: PollarSpacing.x2),
                    limit,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: spent),
                  const SizedBox(width: PollarSpacing.x3),
                  Expanded(child: limit),
                ],
              );
            },
          ),
          const SizedBox(height: PollarSpacing.x2),
          _BudgetUsage(value: progress.percent, hidden: hidden, color: color),
          const SizedBox(height: PollarSpacing.x2),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: PollarSpacing.x2,
            runSpacing: PollarSpacing.x2,
            children: [
              StatusBadge(
                label: hidden
                    ? 'Uso oculto'
                    : progress.exceeded
                    ? 'Limite excedido'
                    : progress.alerting
                    ? 'Próximo do limite'
                    : 'Dentro do limite',
                icon: hidden
                    ? LucideIcons.eyeOff
                    : progress.exceeded || progress.alerting
                    ? LucideIcons.triangleAlert
                    : LucideIcons.circleCheck,
                tone: hidden
                    ? PollarStatusTone.neutral
                    : progress.exceeded
                    ? PollarStatusTone.danger
                    : progress.alerting
                    ? PollarStatusTone.warning
                    : PollarStatusTone.success,
                compact: true,
              ),
              Text(
                hidden ? '—' : '${progress.percent}%',
                style: PollarTypography.tabular(
                  Theme.of(context).textTheme.labelMedium!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Only geometry interpolates. Privacy discards the tween and its proportion.
class _BudgetUsage extends StatelessWidget {
  const _BudgetUsage({
    required this.value,
    required this.hidden,
    required this.color,
  });
  final int value;
  final bool hidden;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget track(double fraction) => ClipRRect(
      borderRadius: BorderRadius.circular(PollarRadii.small),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: fraction,
        color: color,
        backgroundColor: context.pollar.border,
      ),
    );
    if (hidden) {
      return Semantics(
        label: 'Uso do orçamento oculto pelo modo privacidade',
        excludeSemantics: true,
        child: track(0),
      );
    }
    final fraction = (value / 100).clamp(0.0, 1.0);
    return Semantics(
      label: 'Uso do orçamento',
      value: '$value%',
      excludeSemantics: true,
      child: PollarMotion.reduced(context)
          ? track(fraction)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: PollarMotion.focal,
              curve: PollarMotion.curve,
              builder: (context, value, _) => track(value),
            ),
    );
  }
}

class _AgendaBand extends StatelessWidget {
  const _AgendaBand({
    required this.occurrences,
    required this.privacyHidden,
    required this.onCreate,
  });

  final List<PlannedOccurrence> occurrences;
  final bool privacyHidden;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Agenda do mês',
          action: 'Adicionar',
          onAction: onCreate,
        ),
        Text(
          '${occurrences.length} compromissos',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x4),
        if (occurrences.isEmpty)
          const _InlineEmpty(
            icon: LucideIcons.calendarDays,
            title: 'Nenhum compromisso previsto',
            message:
                'Cadastre uma recorrência para montar o calendário deste mês.',
          )
        else
          for (var index = 0; index < occurrences.length; index++) ...[
            _OccurrenceRow(
              occurrence: occurrences[index],
              hidden: privacyHidden,
            ),
            if (index != occurrences.length - 1)
              Divider(height: PollarSpacing.x5, color: context.pollar.border),
          ],
      ],
    ),
  );
}

class _OccurrenceRow extends StatelessWidget {
  const _OccurrenceRow({required this.occurrence, required this.hidden});

  final PlannedOccurrence occurrence;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final income = occurrence.rule.kind == RecurringKind.income;
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final reflow = constraints.maxWidth < 520 || largeText;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: largeText ? 64 : 48,
              padding: const EdgeInsets.symmetric(vertical: PollarSpacing.x2),
              decoration: BoxDecoration(
                color: context.pollar.surfaceAlt,
                borderRadius: BorderRadius.circular(PollarRadii.medium),
              ),
              child: Column(
                children: [
                  Text(
                    '${occurrence.dueDate.day}',
                    style: PollarTypography.tabular(
                      Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'pt_BR').format(occurrence.dueDate),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PollarSpacing.x3),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occurrence.rule.description,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    _kindLabel(occurrence.rule.kind),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                  if (reflow) ...[
                    const SizedBox(height: PollarSpacing.x2),
                    PrivacyAmount(
                      income ? occurrence.rule.amount : -occurrence.rule.amount,
                      hidden: hidden,
                      showSign: true,
                      colorBySign: true,
                      allowWrap: true,
                      reserveLayout: true,
                    ),
                  ],
                ],
              ),
            ),
            if (!reflow) ...[
              const SizedBox(width: PollarSpacing.x2),
              Expanded(
                flex: 2,
                child: PrivacyAmount(
                  income ? occurrence.rule.amount : -occurrence.rule.amount,
                  hidden: hidden,
                  showSign: true,
                  colorBySign: true,
                  allowWrap: true,
                  reserveLayout: true,
                  alignment: AlignmentDirectional.topEnd,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SubscriptionBand extends StatelessWidget {
  const _SubscriptionBand({
    required this.subscriptions,
    required this.privacyHidden,
  });

  final List<PlannedOccurrence> subscriptions;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final total = subscriptions.fold<Money?>(
      null,
      (sum, item) => sum == null ? item.rule.amount : sum + item.rule.amount,
    );
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Assinaturas',
            trailing: total == null
                ? null
                : PrivacyAmount(
                    total,
                    hidden: privacyHidden,
                    semantic: MoneySemantic.expense,
                    allowWrap: true,
                    reserveLayout: true,
                  ),
          ),
          const SizedBox(height: PollarSpacing.x4),
          if (subscriptions.isEmpty)
            const _InlineEmpty(
              icon: LucideIcons.badgeDollarSign,
              title: 'Nenhuma assinatura recorrente',
              message: 'Assinaturas ficam separadas para revelar o compromisso mensal contínuo.',
            )
          else
            for (var index = 0; index < subscriptions.length; index++) ...[
              _OccurrenceRow(
                occurrence: subscriptions[index],
                hidden: privacyHidden,
              ),
              if (index != subscriptions.length - 1)
                Divider(height: PollarSpacing.x5),
            ],
        ],
      ),
    );
  }
}

class _ReminderBand extends StatelessWidget {
  const _ReminderBand({required this.reminders});

  final List<PlanningReminder> reminders;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final reflow =
            constraints.maxWidth < 600 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        return Semantics(
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader(title: 'Lembretes locais'),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                'As datas aparecem neste dispositivo. Nenhuma movimentação é criada sem sua confirmação.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
              const SizedBox(height: PollarSpacing.x4),
              if (reminders.isEmpty)
                const _InlineEmpty(
                  icon: LucideIcons.bell,
                  title: 'Nenhuma data exige atenção',
                  message: 'Os lembretes aparecem aqui ao entrar no prazo configurado.',
                )
              else
                for (var index = 0; index < reminders.length; index++) ...[
                  Flex(
                    direction: reflow ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        reminders[index].overdue
                            ? LucideIcons.circleAlert
                            : LucideIcons.bellRing,
                        size: 20,
                        color: reminders[index].overdue
                            ? context.pollar.danger
                            : context.pollar.warning,
                      ),
                      SizedBox(
                        width: reflow ? 0 : PollarSpacing.x3,
                        height: reflow ? PollarSpacing.x2 : 0,
                      ),
                      if (reflow)
                        Text(reminders[index].occurrence.rule.description)
                      else
                        Expanded(
                          child: Text(
                            reminders[index].occurrence.rule.description,
                          ),
                        ),
                      if (reflow) const SizedBox(height: PollarSpacing.x2),
                      StatusBadge(
                        label: reminders[index].overdue
                            ? 'Data passou há ${-reminders[index].daysUntilDue} dia(s)'
                            : reminders[index].daysUntilDue == 0
                            ? 'Data prevista hoje'
                            : 'Em ${reminders[index].daysUntilDue} dia(s)',
                        icon: reminders[index].overdue
                            ? LucideIcons.circleAlert
                            : LucideIcons.clock,
                        tone: reminders[index].overdue
                            ? PollarStatusTone.danger
                            : PollarStatusTone.warning,
                      ),
                    ],
                  ),
                  if (index != reminders.length - 1)
                    Divider(height: PollarSpacing.x5),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final reflow =
            constraints.maxWidth < 280 ||
            (trailing != null && constraints.maxWidth < 480) ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final titleWidget = Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        );
        final actionWidget = action == null || onAction == null
            ? null
            : PollarButton(
                label: action!,
                variant: PollarButtonVariant.ghost,
                size: PollarControlSize.compact,
                adaptiveHeight: true,
                onPressed: onAction,
              );
        if (reflow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleWidget,
              if (trailing != null || actionWidget != null)
                const SizedBox(height: PollarSpacing.x2),
              ?trailing,
              if (actionWidget != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: actionWidget,
                ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: titleWidget),
            if (trailing != null) Expanded(child: trailing!),
            ?actionWidget,
          ],
        );
      },
    );
  }
}

class _PlanManagementBand extends StatelessWidget {
  const _PlanManagementBand({
    required this.budgets,
    required this.rules,
    required this.onBudgetChanged,
    required this.onRuleChanged,
  });

  final List<Budget> budgets;
  final List<RecurringRule> rules;
  final void Function(Budget budget, bool active) onBudgetChanged;
  final void Function(RecurringRule rule, bool active) onRuleChanged;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final budget in budgets)
        _ManagementRow(
          icon: LucideIcons.gauge,
          title: budget.category,
          description: 'Orçamento mensal',
          active: budget.active,
          onChanged: (active) => onBudgetChanged(budget, active),
        ),
      for (final rule in rules)
        _ManagementRow(
          icon: rule.isSubscription
              ? LucideIcons.badgeDollarSign
              : LucideIcons.repeat2,
          title: rule.description,
          description: _kindLabel(rule.kind),
          active: rule.active,
          onChanged: (active) => onRuleChanged(rule, active),
        ),
    ];
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(title: 'Gerenciar planejamento'),
          const SizedBox(height: PollarSpacing.x2),
          Text(
            'Pause um item sem apagar sua configuração. Itens pausados permanecem aqui para serem retomados.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x4),
          if (items.isEmpty)
            const _InlineEmpty(
              icon: LucideIcons.slidersHorizontal,
              title: 'Nenhum item para gerenciar',
              message:
                  'Orçamentos e compromissos salvos aparecerão nesta lista.',
            )
          else
            for (var index = 0; index < items.length; index++) ...[
              items[index],
              if (index != items.length - 1) Divider(height: PollarSpacing.x5),
            ],
        ],
      ),
    );
  }
}

class _ManagementRow extends StatelessWidget {
  const _ManagementRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.active,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final reflow =
            constraints.maxWidth < 560 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final identity = Row(
          children: [
            Icon(icon, size: 20, color: context.pollar.textSecondary),
            const SizedBox(width: PollarSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
        final controls = Wrap(
          spacing: PollarSpacing.x2,
          runSpacing: PollarSpacing.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusBadge(
              label: active ? 'Ativo' : 'Pausado',
              icon: active ? LucideIcons.circleCheck : LucideIcons.pause,
              tone: active
                  ? PollarStatusTone.success
                  : PollarStatusTone.neutral,
            ),
            PollarButton(
              label: active ? 'Pausar' : 'Retomar',
              variant: PollarButtonVariant.ghost,
              size: PollarControlSize.compact,
              adaptiveHeight: true,
              onPressed: () => onChanged(!active),
            ),
          ],
        );
        if (reflow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: PollarSpacing.x2),
              controls,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: identity),
            controls,
          ],
        );
      },
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: PollarSpacing.x3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.pollar.textMuted),
        const SizedBox(width: PollarSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: PollarSpacing.x1),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _kindLabel(RecurringKind kind) => switch (kind) {
  RecurringKind.income => 'Entrada recorrente',
  RecurringKind.expense => 'Pagamento recorrente',
  RecurringKind.subscription => 'Assinatura',
};
