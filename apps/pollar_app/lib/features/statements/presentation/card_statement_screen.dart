// THESIS: a fatura reconciles what is owed with the purchases and future installments that explain it, refusing a generic metric dashboard.
// OWN-WORLD: flat canvas cards, one-pixel green-grey borders, restrained teal actions, blue card identity, exact tabular figures and Lucide outlines.
// STORY: identify the cycle and status, verify total/paid/outstanding, inspect dated purchases and future commitments, then record a payment safely.
// FIRST VIEWPORT: operational header above an asymmetric summary-and-future pair; the outstanding balance and due date lead, payment sits inside the summary.
// FORM: canonical Pollar statement hierarchy inherited from the shipped desktop/mobile UI kits; established-world extension, no new-world seed.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/currency_input.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/status_badge.dart';
import '../application/statement_data_source.dart';
import '../domain/card_statement.dart';
import 'statement_controller.dart';
import 'widgets/future_installments.dart';
import 'widgets/statement_purchases.dart';
import 'widgets/statement_summary.dart';

class CardStatementScreen extends ConsumerWidget {
  const CardStatementScreen({super.key, required this.cardId});
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardStatementProvider(cardId));
    final privacyHidden = ref.watch(privacyModeProvider);
    return state.when(
      loading: () => const PollarLoadingState(message: 'Calculando fatura…'),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível calcular a fatura',
        message: 'Os lançamentos continuam salvos. Tente calcular novamente.',
        actionLabel: 'Calcular fatura novamente',
        onRetry: () => ref.read(cardStatementProvider(cardId).notifier).retry(),
      ),
      data: (snapshot) =>
          _StatementContent(snapshot: snapshot, privacyHidden: privacyHidden),
    );
  }
}

class _StatementContent extends ConsumerWidget {
  const _StatementContent({
    required this.snapshot,
    required this.privacyHidden,
  });
  final CardStatementSnapshot snapshot;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final canPay =
        snapshot.statement.outstanding.isPositive &&
        snapshot.paymentAccounts.isNotEmpty;
    final summary = StatementSummary(
      snapshot: snapshot,
      privacyHidden: privacyHidden,
      onPay: canPay ? () => _pay(context, ref) : null,
    );
    final future = FutureInstallmentsCard(
      items: snapshot.futureInstallments,
      privacyHidden: privacyHidden,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: ListView(
          padding: EdgeInsets.all(
            compact ? PollarSpacing.x4 : PollarSpacing.x6,
          ),
          children: [
            _StatementHeader(snapshot: snapshot),
            const SizedBox(height: PollarSpacing.x6),
            if (snapshot.statement.outstanding.isPositive &&
                snapshot.paymentAccounts.isEmpty) ...[
              const PollarBanner(
                tone: PollarStatusTone.info,
                title: 'Cadastre uma conta para pagar a fatura',
                message: 'O pagamento precisa sair de uma conta ativa na mesma moeda do cartão.',
              ),
              const SizedBox(height: PollarSpacing.x4),
            ],
            if (compact) ...[
              summary,
              const SizedBox(height: PollarSpacing.x4),
              StatementPurchases(
                items: snapshot.statement.purchases,
                privacyHidden: privacyHidden,
              ),
              const SizedBox(height: PollarSpacing.x4),
              future,
            ] else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide =
                      constraints.maxWidth >= 820 &&
                      MediaQuery.textScalerOf(context).scale(1) <= 1.3;
                  if (!sideBySide) {
                    return Column(
                      children: [
                        summary,
                        const SizedBox(height: PollarSpacing.x4),
                        future,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 8, child: summary),
                      const SizedBox(width: PollarSpacing.x4),
                      Expanded(flex: 5, child: future),
                    ],
                  );
                },
              ),
              const SizedBox(height: PollarSpacing.x4),
              StatementPurchases(
                items: snapshot.statement.purchases,
                privacyHidden: privacyHidden,
              ),
            ],
            const SizedBox(height: PollarSpacing.x8),
          ],
        ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    var accountId = snapshot.paymentAccounts.first.id;
    Money? amount = snapshot.statement.outstanding;
    final formKey = GlobalKey<FormState>();
    final confirmed = await showPollarAdaptiveModal<bool>(
      context: context,
      title: 'Registrar pagamento da fatura?',
      description: 'O valor sairá da conta escolhida e reduzirá a dívida do cartão. Não será contado como uma nova despesa.',
      icon: LucideIcons.creditCard,
      content: (modalContext) => Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PollarSelect<String>(
              key: const Key('statement-payment-account'),
              label: 'Conta de pagamento',
              initialValue: accountId,
              options: [
                for (final account in snapshot.paymentAccounts)
                  PollarSelectOption(value: account.id, label: account.name),
              ],
              onChanged: (value) => accountId = value ?? accountId,
            ),
            const SizedBox(height: PollarSpacing.x4),
            CurrencyInput(
              key: const Key('statement-payment-amount'),
              label: 'Valor do pagamento',
              currency: snapshot.currency,
              initialValue: snapshot.statement.outstanding,
              onChanged: (value) => amount = value,
              validator: (value) {
                if (value == null || !value.isPositive) {
                  return 'Informe um valor maior que zero.';
                }
                if (value.compareTo(snapshot.statement.outstanding) > 0) {
                  return 'O pagamento não pode superar o saldo da fatura.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: (modalContext) => [
        PollarButton(
          label: 'Voltar à fatura',
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.pop(modalContext, false),
        ),
        PollarButton(
          key: const Key('confirm-statement-payment'),
          label: 'Confirmar pagamento',
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(modalContext, true);
          },
        ),
      ],
    );
    if (confirmed != true || amount == null || !context.mounted) return;
    try {
      await ref
          .read(cardStatementProvider(snapshot.cardId).notifier)
          .pay(
            StatementPaymentCommand(
              id: const Uuid().v4(),
              statementId: snapshot.statement.id,
              cardId: snapshot.cardId,
              sourceAccountId: accountId,
              amount: amount!,
              occurredAt: ref.read(statementClockProvider)(),
            ),
          );
      if (context.mounted) {
        showPollarToast(context, message: 'Pagamento da fatura registrado.');
      }
    } catch (_) {
      if (context.mounted) {
        showPollarToast(
          context,
          tone: PollarStatusTone.danger,
          message: 'Não foi possível registrar o pagamento. Revise a conta e o valor.',
        );
      }
    }
  }
}

class _StatementHeader extends StatelessWidget {
  const _StatementHeader({required this.snapshot});
  final CardStatementSnapshot snapshot;
  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PollarIconButton(
          icon: LucideIcons.arrowLeft,
          label: 'Voltar para contas',
          outlined: true,
          onPressed: () => context.go('/accounts'),
        ),
        const SizedBox(width: PollarSpacing.x4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.cardName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                'Fatura de ${DateFormat('MMMM', 'pt_BR').format(snapshot.statement.dueDate)} · fecha dia ${snapshot.statement.closingDate.day}',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
    final action = PollarButton(
      label: 'Adicionar compra',
      leadingIcon: LucideIcons.plus,
      variant: PollarButtonVariant.secondary,
      fullWidth: compact,
      onPressed: () => context.push(
        '/transactions/new?cardId=${Uri.encodeComponent(snapshot.cardId)}',
      ),
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: PollarSpacing.x4),
          action,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: PollarSpacing.x6),
        action,
      ],
    );
  }
}
