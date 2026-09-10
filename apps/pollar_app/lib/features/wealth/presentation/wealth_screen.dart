// THESIS: patrimônio é um dossiê rastreável; recusa números isolados sem composição.
// OWN-WORLD: superfícies planas, teal restrito, linhas finas e valores tabulares exatos.
// STORY: entender o patrimônio líquido, conferir sua origem e agir sobre a meta prioritária.
// FIRST VIEWPORT: cabeçalho e ações, balanço líquido à esquerda e meta prioritária à direita; no compacto, balanço antes da meta.
// FORM: dossiê de metas, quinta estrutura sorteada pela seed bfca2793.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/money_text.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/wealth_asset.dart';
import '../domain/wealth_debt.dart';
import '../domain/wealth_goal.dart';
import '../domain/wealth_snapshot.dart';
import 'wealth_controller.dart';
import 'wealth_forms.dart';

class WealthScreen extends ConsumerWidget {
  const WealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(wealthProvider);
    return data.when(
      loading: () =>
          const PollarLoadingState(message: 'Calculando patrimônio…'),
      error: (error, stack) => PollarErrorState(
        title: 'Não foi possível calcular o patrimônio',
        message: 'Os registros continuam salvos. Tente carregar os valores novamente.',
        actionLabel: 'Recalcular patrimônio',
        onRetry: ref.read(wealthProvider.notifier).retry,
      ),
      data: (state) => _WealthContent(state: state),
    );
  }
}

class _WealthContent extends ConsumerWidget {
  const _WealthContent({required this.state});
  final WealthState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = state.snapshot;
    final hidden = ref.watch(privacyModeProvider);
    final wide =
        MediaQuery.sizeOf(context).width >= 860 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.3;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
        child: ListView(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin
                ? PollarSpacing.x4
                : PollarSpacing.x6,
          ),
          children: [
            _Header(state: state),
            const SizedBox(height: PollarSpacing.x6),
            if (wide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _BalanceDossier(
                        snapshot: snapshot,
                        hidden: hidden,
                      ),
                    ),
                    const SizedBox(width: PollarSpacing.x4),
                    Expanded(
                      child: _PriorityGoalDossier(
                        progress: snapshot.priorityGoal,
                        hidden: hidden,
                        onEdit: snapshot.priorityGoal == null
                            ? null
                            : () => _editGoal(
                                context,
                                ref,
                                snapshot.priorityGoal!.goal,
                              ),
                        onComplete:
                            snapshot.priorityGoal == null ||
                                snapshot.priorityGoal!.goal.completed
                            ? null
                            : () => _completeGoal(
                                context,
                                ref,
                                snapshot.priorityGoal!.goal,
                              ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _BalanceDossier(snapshot: snapshot, hidden: hidden),
              const SizedBox(height: PollarSpacing.x4),
              _PriorityGoalDossier(
                progress: snapshot.priorityGoal,
                hidden: hidden,
                onEdit: snapshot.priorityGoal == null
                    ? null
                    : () =>
                          _editGoal(context, ref, snapshot.priorityGoal!.goal),
                onComplete:
                    snapshot.priorityGoal == null ||
                        snapshot.priorityGoal!.goal.completed
                    ? null
                    : () => _completeGoal(
                        context,
                        ref,
                        snapshot.priorityGoal!.goal,
                      ),
              ),
            ],
            const SizedBox(height: PollarSpacing.x6),
            Text(
              'Composição do patrimônio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PollarSpacing.x3),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _AssetRegister(snapshot: snapshot, hidden: hidden),
                  ),
                  const SizedBox(width: PollarSpacing.x4),
                  Expanded(
                    child: _DebtRegister(snapshot: snapshot, hidden: hidden),
                  ),
                ],
              )
            else ...[
              _AssetRegister(snapshot: snapshot, hidden: hidden),
              const SizedBox(height: PollarSpacing.x4),
              _DebtRegister(snapshot: snapshot, hidden: hidden),
            ],
            const SizedBox(height: PollarSpacing.x6),
            _GoalsRegister(snapshot: snapshot, hidden: hidden),
            const SizedBox(height: PollarSpacing.x6),
            _Management(state: state),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.state});
  final WealthState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final reflow =
        MediaQuery.sizeOf(context).width < 760 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final selector = SizedBox(
      width: reflow ? double.infinity : 150,
      child: PollarSelect<Currency>(
        label: 'Moeda',
        initialValue: state.snapshot.currency,
        options: [
          for (final currency in state.currencies)
            PollarSelectOption(value: currency, label: currency.code),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(wealthProvider.notifier).selectCurrency(value);
          }
        },
      ),
    );
    final actions = Wrap(
      spacing: PollarSpacing.x2,
      runSpacing: PollarSpacing.x2,
      children: [
        PollarButton(
          label: 'Nova meta',
          leadingIcon: LucideIcons.target,
          variant: PollarButtonVariant.secondary,
          onPressed: () => showGoalForm(
            context: context,
            currency: state.snapshot.currency,
            now: ref.read(wealthClockProvider)(),
            onSave: ref.read(wealthProvider.notifier).createGoal,
          ),
        ),
        PollarButton(
          label: 'Novo ativo',
          leadingIcon: LucideIcons.landmark,
          variant: PollarButtonVariant.secondary,
          onPressed: () => showAssetForm(
            context: context,
            currency: state.snapshot.currency,
            now: ref.read(wealthClockProvider)(),
            onSave: ref.read(wealthProvider.notifier).createAsset,
          ),
        ),
        PollarButton(
          label: 'Nova dívida',
          leadingIcon: LucideIcons.receiptText,
          onPressed: () => showDebtForm(
            context: context,
            currency: state.snapshot.currency,
            now: ref.read(wealthClockProvider)(),
            onSave: ref.read(wealthProvider.notifier).createDebt,
          ),
        ),
      ],
    );
    if (reflow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Patrimônio', style: text.headlineLarge),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Posições confirmadas, bens avaliados e obrigações na mesma moeda.',
            style: text.bodyMedium?.copyWith(
              color: context.pollar.textSecondary,
            ),
          ),
          const SizedBox(height: PollarSpacing.x4),
          selector,
          const SizedBox(height: PollarSpacing.x3),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patrimônio', style: text.headlineLarge),
                  const SizedBox(height: PollarSpacing.x1),
                  Text(
                    'Posições confirmadas, bens avaliados e obrigações na mesma moeda.',
                    style: text.bodyMedium?.copyWith(
                      color: context.pollar.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            selector,
          ],
        ),
        const SizedBox(height: PollarSpacing.x4),
        actions,
      ],
    );
  }
}

class _BalanceDossier extends StatelessWidget {
  const _BalanceDossier({required this.snapshot, required this.hidden});
  final WealthSnapshot snapshot;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: LucideIcons.scale,
            title: 'Balanço líquido',
            trailing: const StatusBadge(
              label: 'Confirmado',
              icon: LucideIcons.circleCheck,
              tone: PollarStatusTone.success,
            ),
          ),
          const SizedBox(height: PollarSpacing.x5),
          Text(
            'Patrimônio líquido',
            style: text.bodySmall?.copyWith(
              color: context.pollar.textSecondary,
            ),
          ),
          const SizedBox(height: PollarSpacing.x1),
          PrivacyAmount(
            snapshot.netWorth,
            hidden: hidden,
            allowWrap: true,
            colorBySign: true,
            semantic: MoneySemantic.balance,
            style: text.displaySmall,
          ),
          const SizedBox(height: PollarSpacing.x5),
          _ExactPair(
            icon: LucideIcons.trendingUp,
            label: 'Ativos acompanhados',
            amount: snapshot.totalAssets,
            hidden: hidden,
            tone: context.pollar.success,
            semantic: MoneySemantic.balance,
          ),
          const SizedBox(height: PollarSpacing.x3),
          _ExactPair(
            icon: LucideIcons.trendingDown,
            label: 'Obrigações acompanhadas',
            amount: snapshot.totalLiabilities,
            hidden: hidden,
            tone: context.pollar.danger,
            semantic: MoneySemantic.debt,
          ),
          const SizedBox(height: PollarSpacing.x4),
          Text(
            'Contas usam saldo confirmado. Bens e dívidas manuais usam a última avaliação informada.',
            style: text.bodySmall?.copyWith(color: context.pollar.textMuted),
          ),
        ],
      ),
    );
  }
}

class _PriorityGoalDossier extends StatelessWidget {
  const _PriorityGoalDossier({
    required this.progress,
    required this.hidden,
    required this.onEdit,
    required this.onComplete,
  });
  final WealthGoalProgress? progress;
  final bool hidden;
  final VoidCallback? onEdit;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PollarCard(
      alt: true,
      child: progress == null
          ? const _InlineEmpty(
              icon: LucideIcons.target,
              title: 'Nenhuma meta ativa',
              message: 'Crie uma meta para acompanhar o valor reservado e a distância até o alvo.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeading(
                  icon: LucideIcons.target,
                  title: 'Meta prioritária',
                  trailing: StatusBadge(
                    label: '${progress!.percent}%',
                    icon: LucideIcons.gauge,
                    tone: PollarStatusTone.info,
                  ),
                ),
                const SizedBox(height: PollarSpacing.x5),
                Text(progress!.goal.name, style: text.headlineSmall),
                if (progress!.goal.deadline case final deadline?) ...[
                  const SizedBox(height: PollarSpacing.x1),
                  Text(
                    'Prazo em ${DateFormat('dd MMM yyyy', 'pt_BR').format(deadline)}',
                    style: text.bodySmall?.copyWith(
                      color: context.pollar.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: PollarSpacing.x4),
                Semantics(
                  label: '${progress!.percent}% da meta concluída',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(PollarRadii.pill),
                    child: LinearProgressIndicator(
                      value: progress!.percent / 100,
                      minHeight: 8,
                      backgroundColor: context.pollar.border,
                      color: context.pollar.primary,
                    ),
                  ),
                ),
                const SizedBox(height: PollarSpacing.x4),
                _ExactPair(
                  icon: LucideIcons.piggyBank,
                  label: 'Reservado',
                  amount: progress!.goal.saved,
                  hidden: hidden,
                  tone: context.pollar.primary,
                  semantic: MoneySemantic.neutral,
                ),
                const SizedBox(height: PollarSpacing.x3),
                _ExactPair(
                  icon: LucideIcons.flag,
                  label: 'Falta reservar',
                  amount: progress!.remaining,
                  hidden: hidden,
                  tone: context.pollar.warning,
                  semantic: MoneySemantic.neutral,
                ),
                const SizedBox(height: PollarSpacing.x3),
                _ExactPair(
                  icon: LucideIcons.circleDollarSign,
                  label: 'Valor alvo',
                  amount: progress!.goal.target,
                  hidden: hidden,
                  tone: context.pollar.textSecondary,
                  semantic: MoneySemantic.neutral,
                ),
                const SizedBox(height: PollarSpacing.x4),
                Wrap(
                  spacing: PollarSpacing.x2,
                  runSpacing: PollarSpacing.x2,
                  children: [
                    PollarButton(
                      label: 'Atualizar meta',
                      leadingIcon: LucideIcons.pencil,
                      variant: PollarButtonVariant.secondary,
                      size: PollarControlSize.compact,
                      onPressed: onEdit,
                    ),
                    if (onComplete != null)
                      PollarButton(
                        label: 'Concluir meta',
                        leadingIcon: LucideIcons.circleCheck,
                        size: PollarControlSize.compact,
                        onPressed: onComplete,
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _AssetRegister extends StatelessWidget {
  const _AssetRegister({required this.snapshot, required this.hidden});
  final WealthSnapshot snapshot;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final accounts = snapshot.accountPositions.where((item) => !item.liability);
    final rows = <Widget>[
      for (final account in accounts)
        _RegisterRow(
          icon: LucideIcons.walletCards,
          title: account.name,
          subtitle: 'Saldo confirmado',
          amount: account.amount,
          hidden: hidden,
        ),
      for (final asset in snapshot.assets)
        _RegisterRow(
          icon: _assetIcon(asset.kind),
          title: asset.name,
          subtitle:
              '${_assetKindLabel(asset.kind)} · avaliado em ${DateFormat('dd/MM/yyyy').format(asset.valuedAt)}',
          amount: asset.currentValue,
          hidden: hidden,
        ),
    ];
    return _RegisterCard(
      title: 'Ativos',
      total: snapshot.totalAssets,
      semantic: MoneySemantic.balance,
      hidden: hidden,
      rows: rows,
      empty: const _InlineEmpty(
        icon: LucideIcons.landmark,
        title: 'Nenhum ativo acompanhado',
        message:
            'Adicione uma conta ou registre um bem com avaliação conhecida.',
      ),
    );
  }
}

class _DebtRegister extends StatelessWidget {
  const _DebtRegister({required this.snapshot, required this.hidden});
  final WealthSnapshot snapshot;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final accountDebts = snapshot.accountPositions.where(
      (item) => item.liability,
    );
    final rows = <Widget>[
      for (final debt in accountDebts)
        _RegisterRow(
          icon: LucideIcons.creditCard,
          title: debt.name,
          subtitle: 'Saldo devedor confirmado',
          amount: debt.amount,
          hidden: hidden,
          danger: true,
        ),
      for (final debt in snapshot.debts)
        _RegisterRow(
          icon: LucideIcons.receiptText,
          title: debt.name,
          subtitle: _debtSubtitle(debt),
          amount: debt.outstandingAmount,
          hidden: hidden,
          danger: true,
        ),
    ];
    return _RegisterCard(
      title: 'Dívidas',
      total: snapshot.totalLiabilities,
      semantic: MoneySemantic.debt,
      hidden: hidden,
      rows: rows,
      empty: const _InlineEmpty(
        icon: LucideIcons.receiptText,
        title: 'Nenhuma obrigação acompanhada',
        message: 'Saldos negativos e dívidas manuais aparecerão aqui.',
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.title,
    required this.total,
    required this.semantic,
    required this.hidden,
    required this.rows,
    required this.empty,
  });
  final String title;
  final Money total;
  final MoneySemantic semantic;
  final bool hidden;
  final List<Widget> rows;
  final Widget empty;

  @override
  Widget build(BuildContext context) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeading(
          title: title,
          trailing: PrivacyAmount(total, hidden: hidden, semantic: semantic),
        ),
        const SizedBox(height: PollarSpacing.x3),
        if (rows.isEmpty)
          empty
        else
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index != rows.length - 1) Divider(height: PollarSpacing.x5),
          ],
      ],
    ),
  );
}

class _GoalsRegister extends StatelessWidget {
  const _GoalsRegister({required this.snapshot, required this.hidden});
  final WealthSnapshot snapshot;
  final bool hidden;

  @override
  Widget build(BuildContext context) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas acompanhadas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: PollarSpacing.x1),
        Text(
          'O valor reservado é informativo e não reduz o saldo de nenhuma conta.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x4),
        if (snapshot.goals.isEmpty)
          const _InlineEmpty(
            icon: LucideIcons.target,
            title: 'Nenhuma meta nesta moeda',
            message:
                'Crie um alvo com valor exato para acompanhar o progresso.',
          )
        else
          for (var index = 0; index < snapshot.goals.length; index++) ...[
            _GoalRow(progress: snapshot.goals[index], hidden: hidden),
            if (index != snapshot.goals.length - 1)
              Divider(height: PollarSpacing.x5),
          ],
      ],
    ),
  );
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.progress, required this.hidden});
  final WealthGoalProgress progress;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final reflow =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin ||
        MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final identity = Row(
      children: [
        Icon(LucideIcons.target, size: 20, color: context.pollar.primary),
        const SizedBox(width: PollarSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                progress.goal.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                progress.goal.completed
                    ? 'Alvo alcançado'
                    : '${progress.percent}% reservado',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
    final value = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress.goal.priority) ...[
          const StatusBadge(
            label: 'Prioritária',
            icon: LucideIcons.star,
            tone: PollarStatusTone.info,
          ),
          const SizedBox(width: PollarSpacing.x2),
        ],
        Flexible(
          child: PrivacyAmount(
            progress.goal.target,
            hidden: hidden,
            semantic: MoneySemantic.neutral,
          ),
        ),
      ],
    );
    return reflow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: PollarSpacing.x2),
              value,
            ],
          )
        : Row(
            children: [
              Expanded(child: identity),
              value,
            ],
          );
  }
}

class _Management extends ConsumerWidget {
  const _Management({required this.state});
  final WealthState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = <Widget>[
      for (final item in state.goals)
        _ManagementRow(
          icon: LucideIcons.target,
          title: item.name,
          description: 'Meta',
          active: item.active,
          actions: [
            PollarButton(
              label: 'Atualizar',
              variant: PollarButtonVariant.ghost,
              size: PollarControlSize.compact,
              onPressed: () => _editGoal(context, ref, item),
            ),
            if (item.active && !item.completed)
              PollarButton(
                label: 'Concluir',
                variant: PollarButtonVariant.ghost,
                size: PollarControlSize.compact,
                onPressed: () => _completeGoal(context, ref, item),
              ),
          ],
          onChanged: (active) => _confirmLifecycle(
            context,
            item.name,
            'meta',
            active,
            () => ref.read(wealthProvider.notifier).setGoalActive(item, active),
          ),
        ),
      for (final item in state.assets)
        _ManagementRow(
          icon: _assetIcon(item.kind),
          title: item.name,
          description: 'Ativo manual',
          active: item.active,
          actions: [
            PollarButton(
              label: 'Atualizar',
              variant: PollarButtonVariant.ghost,
              size: PollarControlSize.compact,
              onPressed: () => _editAsset(context, ref, item),
            ),
          ],
          onChanged: (active) => _confirmLifecycle(
            context,
            item.name,
            'ativo',
            active,
            () =>
                ref.read(wealthProvider.notifier).setAssetActive(item, active),
          ),
        ),
      for (final item in state.debts)
        _ManagementRow(
          icon: LucideIcons.receiptText,
          title: item.name,
          description: item.settled ? 'Dívida liquidada' : 'Dívida manual',
          active: item.active,
          actions: [
            PollarButton(
              label: 'Atualizar',
              variant: PollarButtonVariant.ghost,
              size: PollarControlSize.compact,
              onPressed: () => _editDebt(context, ref, item),
            ),
            if (item.active && !item.settled)
              PollarButton(
                label: 'Liquidar',
                variant: PollarButtonVariant.ghost,
                size: PollarControlSize.compact,
                onPressed: () => _settleDebt(context, ref, item),
              ),
          ],
          onChanged: (active) => _confirmLifecycle(
            context,
            item.name,
            'dívida',
            active,
            () => ref.read(wealthProvider.notifier).setDebtActive(item, active),
          ),
        ),
    ];
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gerenciar registros',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Pause sem apagar. Registros pausados deixam os totais e podem ser retomados aqui.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x4),
          if (rows.isEmpty)
            const _InlineEmpty(
              icon: LucideIcons.archive,
              title: 'Nenhum registro manual',
              message: 'Metas, ativos e dívidas cadastrados aparecerão aqui.',
            )
          else
            for (var index = 0; index < rows.length; index++) ...[
              rows[index],
              if (index != rows.length - 1) Divider(height: PollarSpacing.x5),
            ],
        ],
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.title, required this.trailing, this.icon});
  final String title;
  final Widget trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final titleWidget = Row(
      children: [
        if (icon case final icon?) ...[
          Icon(icon, size: 20, color: context.pollar.primary),
          const SizedBox(width: PollarSpacing.x2),
        ],
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
    return reflow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleWidget,
              const SizedBox(height: PollarSpacing.x2),
              Align(alignment: Alignment.centerRight, child: trailing),
            ],
          )
        : Row(
            children: [
              Expanded(child: titleWidget),
              trailing,
            ],
          );
  }
}

class _ExactPair extends StatelessWidget {
  const _ExactPair({
    required this.icon,
    required this.label,
    required this.amount,
    required this.hidden,
    required this.tone,
    required this.semantic,
  });
  final IconData icon;
  final String label;
  final Money amount;
  final bool hidden;
  final Color tone;
  final MoneySemantic semantic;

  @override
  Widget build(BuildContext context) {
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final labelWidget = Row(
      children: [
        Icon(icon, size: 18, color: tone),
        const SizedBox(width: PollarSpacing.x2),
        Expanded(child: Text(label)),
      ],
    );
    final amountWidget = PrivacyAmount(
      amount,
      hidden: hidden,
      semantic: semantic,
    );
    return reflow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelWidget,
              const SizedBox(height: PollarSpacing.x1),
              Align(alignment: Alignment.centerRight, child: amountWidget),
            ],
          )
        : Row(
            children: [
              Expanded(child: labelWidget),
              amountWidget,
            ],
          );
  }
}

class _RegisterRow extends StatelessWidget {
  const _RegisterRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.hidden,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Money amount;
  final bool hidden;
  final bool danger;

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
                subtitle,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
    final value = PrivacyAmount(
      amount,
      hidden: hidden,
      semantic: danger ? MoneySemantic.debt : MoneySemantic.balance,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: danger ? context.pollar.danger : context.pollar.textPrimary,
      ),
    );
    return reflow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: PollarSpacing.x2),
              Align(alignment: Alignment.centerRight, child: value),
            ],
          )
        : Row(
            children: [
              Expanded(child: identity),
              value,
            ],
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
    this.actions = const [],
  });
  final IconData icon;
  final String title;
  final String description;
  final bool active;
  final ValueChanged<bool> onChanged;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final reflow =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin ||
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
          tone: active ? PollarStatusTone.success : PollarStatusTone.neutral,
        ),
        PollarButton(
          label: active ? 'Pausar' : 'Retomar',
          variant: PollarButtonVariant.ghost,
          size: PollarControlSize.compact,
          onPressed: () => onChanged(!active),
        ),
        ...actions,
      ],
    );
    return reflow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: PollarSpacing.x2),
              controls,
            ],
          )
        : Row(
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

Future<void> _editGoal(
  BuildContext context,
  WidgetRef ref,
  WealthGoal goal,
) async {
  await showGoalForm(
    context: context,
    currency: goal.target.currency,
    now: ref.read(wealthClockProvider)(),
    initial: goal,
    onSave: ref.read(wealthProvider.notifier).updateGoal,
  );
}

Future<void> _editAsset(
  BuildContext context,
  WidgetRef ref,
  WealthAsset asset,
) async {
  await showAssetForm(
    context: context,
    currency: asset.currentValue.currency,
    now: ref.read(wealthClockProvider)(),
    initial: asset,
    onSave: ref.read(wealthProvider.notifier).updateAsset,
  );
}

Future<void> _editDebt(
  BuildContext context,
  WidgetRef ref,
  WealthDebt debt,
) async {
  await showDebtForm(
    context: context,
    currency: debt.outstandingAmount.currency,
    now: ref.read(wealthClockProvider)(),
    initial: debt,
    onSave: ref.read(wealthProvider.notifier).updateDebt,
  );
}

Future<void> _completeGoal(
  BuildContext context,
  WidgetRef ref,
  WealthGoal goal,
) async {
  await _confirmFinalState(
    context: context,
    title: 'Concluir meta?',
    description:
        'O valor reservado de ${goal.name} será igualado ao valor alvo.',
    confirmLabel: 'Concluir meta',
    successMessage: '${goal.name} concluída.',
    failureMessage: 'Não foi possível concluir ${goal.name}.',
    action: () => ref.read(wealthProvider.notifier).completeGoal(goal),
  );
}

Future<void> _settleDebt(
  BuildContext context,
  WidgetRef ref,
  WealthDebt debt,
) async {
  await _confirmFinalState(
    context: context,
    title: 'Liquidar dívida?',
    description:
        'O saldo devedor de ${debt.name} será zerado. Este registro continuará disponível no gerenciamento.',
    confirmLabel: 'Liquidar dívida',
    successMessage: '${debt.name} liquidada.',
    failureMessage: 'Não foi possível liquidar ${debt.name}.',
    action: () => ref.read(wealthProvider.notifier).settleDebt(debt),
  );
}

Future<void> _confirmFinalState({
  required BuildContext context,
  required String title,
  required String description,
  required String confirmLabel,
  required String successMessage,
  required String failureMessage,
  required Future<void> Function() action,
}) async {
  final confirmed = await showPollarAdaptiveModal<bool>(
    context: context,
    title: title,
    description: description,
    icon: LucideIcons.circleCheck,
    actions: (modalContext) => [
      PollarButton(
        label: 'Cancelar',
        variant: PollarButtonVariant.ghost,
        onPressed: () => Navigator.of(modalContext).pop(false),
      ),
      PollarButton(
        label: confirmLabel,
        onPressed: () => Navigator.of(modalContext).pop(true),
      ),
    ],
  );
  if (confirmed != true) return;
  try {
    await action();
    if (context.mounted) _feedback(context, successMessage);
  } catch (_) {
    if (context.mounted) _feedback(context, failureMessage);
  }
}

Future<void> _confirmLifecycle(
  BuildContext context,
  String name,
  String kind,
  bool active,
  Future<void> Function() change,
) async {
  if (active) {
    try {
      await change();
      if (context.mounted) {
        _feedback(context, '$name retomado.');
      }
    } catch (_) {
      if (context.mounted) {
        _feedback(context, 'Não foi possível retomar $name.');
      }
    }
    return;
  }
  final confirmed = await showPollarAdaptiveModal<bool>(
    context: context,
    title: 'Pausar $kind?',
    description:
        '$name deixará de participar dos totais, mas continuará salvo para ser retomado.',
    icon: LucideIcons.pause,
    actions: (modalContext) => [
      PollarButton(
        label: 'Manter $kind',
        variant: PollarButtonVariant.ghost,
        onPressed: () => Navigator.of(modalContext).pop(false),
      ),
      PollarButton(
        label: 'Pausar $kind',
        onPressed: () => Navigator.of(modalContext).pop(true),
      ),
    ],
  );
  if (confirmed != true) return;
  try {
    await change();
    if (context.mounted) _feedback(context, '$name pausado.');
  } catch (_) {
    if (context.mounted) _feedback(context, 'Não foi possível pausar $name.');
  }
}

void _feedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

IconData _assetIcon(WealthAssetKind kind) => switch (kind) {
  WealthAssetKind.property => LucideIcons.house,
  WealthAssetKind.vehicle => LucideIcons.car,
  WealthAssetKind.investment => LucideIcons.chartNoAxesCombined,
  WealthAssetKind.valuable => LucideIcons.gem,
  WealthAssetKind.other => LucideIcons.packageOpen,
};

String _assetKindLabel(WealthAssetKind kind) => switch (kind) {
  WealthAssetKind.property => 'Imóvel',
  WealthAssetKind.vehicle => 'Veículo',
  WealthAssetKind.investment => 'Investimento manual',
  WealthAssetKind.valuable => 'Bem de valor',
  WealthAssetKind.other => 'Outro ativo',
};

String _debtSubtitle(WealthDebt debt) {
  final interest = NumberFormat(
    '0.##',
    'pt_BR',
  ).format(debt.annualInterestBasisPoints / 100);
  final due = debt.dueDate == null
      ? ''
      : ' · até ${DateFormat('MM/yyyy').format(debt.dueDate!)}';
  final updated = DateFormat('dd/MM/yyyy').format(debt.updatedAt);
  return '${_debtKindLabel(debt.kind)} · $interest% a.a.$due · atualizado em $updated';
}

String _debtKindLabel(WealthDebtKind kind) => switch (kind) {
  WealthDebtKind.loan => 'Empréstimo',
  WealthDebtKind.financing => 'Financiamento',
  WealthDebtKind.personal => 'Dívida pessoal',
  WealthDebtKind.other => 'Outra dívida',
};
