// THESIS: O mês é uma sequência de faixas reconciliadas; recusa separar orçamento, agenda e lembretes em destinos sem contexto comum.
// OWN-WORLD: Canvas planos, bordas finas, teal só em ações, estados por texto e ícone e valores exatos em algarismos tabulares.
// STORY: A pessoa lê a capacidade do mês, confere limites por categoria, percorre vencimentos e cadastra uma nova regra ou orçamento.
// FIRST VIEWPORT: Cabeçalho mensal e posição planejada lideram; orçamento e agenda começam logo abaixo, com assinaturas e lembretes na continuidade.
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
              onNewBudget: () => _newBudget(context, ref),
              onNewRule: state.accounts.isEmpty
                  ? null
                  : () => _newRule(context, ref),
            ),
            const SizedBox(height: PollarSpacing.x5),
            _PositionBand(snapshot: snapshot, privacyHidden: privacyHidden),
            const SizedBox(height: PollarSpacing.x4),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 860 && !reflow;
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
                      budgets,
                      const SizedBox(height: PollarSpacing.x4),
                      agenda,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: budgets),
                    const SizedBox(width: PollarSpacing.x4),
                    Expanded(child: agenda),
                  ],
                );
              },
            ),
            const SizedBox(height: PollarSpacing.x4),
            _SubscriptionBand(
              subscriptions: snapshot.subscriptions,
              privacyHidden: privacyHidden,
            ),
            const SizedBox(height: PollarSpacing.x4),
            _ReminderBand(reminders: snapshot.reminders),
            const SizedBox(height: PollarSpacing.x4),
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
        DateTime.now().day.clamp(
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
            variant: PollarButtonVariant.ghost,
            onPressed: () => Navigator.of(modalContext).pop(false),
          ),
          PollarButton(
            label: action,
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
    required this.onNewBudget,
    required this.onNewRule,
  });

  final PlanningState state;
  final bool compact;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<Currency> onCurrencyChanged;
  final VoidCallback onNewBudget;
  final VoidCallback? onNewRule;

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
        const SizedBox(height: PollarSpacing.x1),
        Text(
          'Limites, compromissos e lembretes calculados a partir dos seus dados.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
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
    final actions = Wrap(
      spacing: PollarSpacing.x2,
      runSpacing: PollarSpacing.x2,
      children: [
        PollarButton(
          label: 'Novo orçamento',
          leadingIcon: LucideIcons.plus,
          variant: PollarButtonVariant.secondary,
          onPressed: onNewBudget,
        ),
        PollarButton(
          label: 'Novo compromisso',
          leadingIcon: LucideIcons.repeat2,
          onPressed: onNewRule,
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
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          copy,
          const SizedBox(height: PollarSpacing.x4),
          Row(
            children: [
              period,
              const Spacer(),
              if (state.currencies.length > 1) Expanded(child: currency),
            ],
          ),
          const SizedBox(height: PollarSpacing.x3),
          actions,
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
        const SizedBox(height: PollarSpacing.x3),
        Row(children: [currency, const Spacer(), actions]),
      ],
    );
  }
}

class _PositionBand extends StatelessWidget {
  const _PositionBand({required this.snapshot, required this.privacyHidden});

  final PlanningSnapshot snapshot;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final remaining = snapshot.totalBudgeted - snapshot.totalSpent;
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final heading = Text(
      'Posição planejada',
      style: Theme.of(context).textTheme.headlineSmall,
    );
    final status = StatusBadge(
      label: '${snapshot.occurrences.length} compromissos',
      icon: LucideIcons.calendarClock,
      tone: PollarStatusTone.info,
    );
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reflow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: PollarSpacing.x2),
                status,
              ],
            )
          else
            Row(
              children: [
                Expanded(child: heading),
                status,
              ],
            ),
          const SizedBox(height: PollarSpacing.x4),
          Wrap(
            spacing: PollarSpacing.x8,
            runSpacing: PollarSpacing.x4,
            children: [
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
                label: 'Disponível no orçamento',
                value: remaining,
                hidden: privacyHidden,
              ),
              _Metric(
                label: 'Compromissos de saída',
                value: snapshot.recurringExpenses,
                hidden: privacyHidden,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.hidden,
  });

  final String label;
  final Money value;
  final bool hidden;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 260 : 170,
    ),
    child: Column(
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
          style: PollarTypography.amountHero,
          semantic: MoneySemantic.neutral,
          allowWrap: MediaQuery.textScalerOf(context).scale(1) > 1.3,
        ),
      ],
    ),
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
  Widget build(BuildContext context) => PollarCard(
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
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Semantics(
      label:
          '${progress.budget.category}, ${progress.percent} por cento utilizado',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (reflow) ...[
            Text(
              progress.budget.category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: PollarSpacing.x2),
            PrivacyAmount(
              progress.spent,
              hidden: hidden,
              semantic: MoneySemantic.expense,
            ),
            const SizedBox(height: PollarSpacing.x1),
            PrivacyAmount(
              progress.budget.limit,
              hidden: hidden,
              semantic: MoneySemantic.neutral,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.budget.category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PrivacyAmount(
                  progress.spent,
                  hidden: hidden,
                  semantic: MoneySemantic.expense,
                ),
                Text(' / ', style: TextStyle(color: context.pollar.textMuted)),
                PrivacyAmount(
                  progress.budget.limit,
                  hidden: hidden,
                  semantic: MoneySemantic.neutral,
                ),
              ],
            ),
          const SizedBox(height: PollarSpacing.x2),
          ClipRRect(
            borderRadius: BorderRadius.circular(PollarRadii.small),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (progress.percent / 100).clamp(0, 1),
              color: color,
              backgroundColor: context.pollar.surfaceAlt,
              semanticsLabel: 'Uso do orçamento',
              semanticsValue: '${progress.percent}%',
            ),
          ),
          const SizedBox(height: PollarSpacing.x2),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: PollarSpacing.x2,
            runSpacing: PollarSpacing.x2,
            children: [
              StatusBadge(
                label: progress.exceeded
                    ? 'Limite excedido'
                    : progress.alerting
                    ? 'Próximo do limite'
                    : 'Dentro do limite',
                icon: progress.exceeded || progress.alerting
                    ? LucideIcons.triangleAlert
                    : LucideIcons.circleCheck,
                tone: progress.exceeded
                    ? PollarStatusTone.danger
                    : progress.alerting
                    ? PollarStatusTone.warning
                    : PollarStatusTone.success,
                compact: true,
              ),
              Text(
                '${progress.percent}%',
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
  Widget build(BuildContext context) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Agenda do mês',
          action: 'Adicionar',
          onAction: onCreate,
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
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
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
                ),
              ],
            ],
          ),
        ),
        if (!reflow) ...[
          const SizedBox(width: PollarSpacing.x2),
          PrivacyAmount(
            income ? occurrence.rule.amount : -occurrence.rule.amount,
            hidden: hidden,
            showSign: true,
            colorBySign: true,
          ),
        ],
      ],
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
    return PollarCard(
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
            Wrap(
              spacing: PollarSpacing.x3,
              runSpacing: PollarSpacing.x3,
              children: [
                for (final item in subscriptions)
                  Container(
                    constraints: const BoxConstraints(minWidth: 210),
                    padding: const EdgeInsets.all(PollarSpacing.x3),
                    decoration: BoxDecoration(
                      color: context.pollar.surfaceAlt,
                      borderRadius: BorderRadius.circular(PollarRadii.medium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.repeat2,
                              size: 18,
                              color: context.pollar.primary,
                            ),
                            const SizedBox(width: PollarSpacing.x2),
                            Expanded(
                              child: Text(
                                item.rule.description,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PollarSpacing.x2),
                        PrivacyAmount(
                          item.rule.amount,
                          hidden: privacyHidden,
                          semantic: MoneySemantic.expense,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return PollarCard(
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
              message:
                  'Os lembretes aparecem aqui ao entrar no prazo configurado.',
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
                      child: Text(reminders[index].occurrence.rule.description),
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
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final titleWidget = Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
    final actionWidget = action == null
        ? null
        : PollarButton(
            label: action!,
            variant: PollarButtonVariant.ghost,
            size: PollarControlSize.compact,
            onPressed: onAction,
          );
    if (reflow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          if (trailing != null || actionWidget != null)
            const SizedBox(height: PollarSpacing.x2),
          ?trailing,
          ?actionWidget,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: titleWidget),
        ?trailing,
        ?actionWidget,
      ],
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
    return PollarCard(
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
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
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
          tone: active ? PollarStatusTone.success : PollarStatusTone.neutral,
        ),
        PollarButton(
          label: active ? 'Pausar' : 'Retomar',
          variant: PollarButtonVariant.ghost,
          size: PollarControlSize.compact,
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
