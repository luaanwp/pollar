import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/empty_state.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/account.dart';
import 'account_presentation.dart';
import 'accounts_controller.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final privacyHidden = ref.watch(privacyModeProvider);

    return accounts.when(
      loading: () => const PollarLoadingState(message: 'Carregando contas…'),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível carregar as contas',
        message: 'Tente carregar novamente. Nenhum dado foi alterado.',
        actionLabel: 'Carregar contas novamente',
        onRetry: () => ref.invalidate(accountsProvider),
      ),
      data: (items) =>
          _AccountsContent(accounts: items, privacyHidden: privacyHidden),
    );
  }
}

class _AccountsContent extends ConsumerWidget {
  const _AccountsContent({required this.accounts, required this.privacyHidden});

  final List<Account> accounts;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = accounts.where((account) => !account.isArchived).toList();
    final regular = active.where((account) => !account.isCreditCard).toList();
    final cards = active.where((account) => account.isCreditCard).toList();
    final archived = accounts.where((account) => account.isArchived).toList();

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
            _AccountsHeader(onCreate: () => _openCreate(context)),
            const SizedBox(height: PollarSpacing.x6),
            if (active.isEmpty)
              EmptyState(
                icon: LucideIcons.walletCards,
                title: 'Nenhuma conta cadastrada',
                message: 'Cadastre uma conta ou cartão para organizar saldos e lançamentos.',
                action: PollarButton(
                  label: 'Cadastrar primeira conta',
                  leadingIcon: LucideIcons.plus,
                  onPressed: () => _openCreate(context),
                ),
              )
            else
              _ActiveAccountSections(
                regular: regular,
                cards: cards,
                privacyHidden: privacyHidden,
                onArchive: (account) => _archive(context, ref, account),
              ),
            if (archived.isNotEmpty) ...[
              const SizedBox(height: PollarSpacing.x8),
              _AccountSection(
                title: 'Arquivadas',
                description: 'Não entram em novos lançamentos, mas continuam no histórico.',
                accounts: archived,
                privacyHidden: privacyHidden,
                archived: true,
                onAction: (account) => _restore(context, ref, account),
              ),
            ],
            const SizedBox(height: PollarSpacing.x8),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final message = await context.push<String>('/accounts/new');
    if (message != null && context.mounted) {
      showPollarToast(context, message: message);
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final noun = account.isCreditCard ? 'cartão' : 'conta';
    await showPollarAdaptiveModal<void>(
      context: context,
      title: 'Arquivar ${account.name}?',
      description:
          '${account.isCreditCard ? 'O cartão' : 'A conta'} deixará de aparecer em novos lançamentos. O histórico será preservado e ${account.isCreditCard ? 'ele' : 'ela'} poderá ser restaurad${account.isCreditCard ? 'o' : 'a'}.',
      icon: LucideIcons.archive,
      actions: (modalContext) => [
        PollarButton(
          label: 'Cancelar arquivamento',
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.pop(modalContext),
        ),
        PollarButton(
          label: 'Arquivar $noun',
          onPressed: () async {
            try {
              await ref.read(accountsProvider.notifier).archive(account.id);
              if (!modalContext.mounted) return;
              Navigator.pop(modalContext);
              showPollarToast(
                context,
                message: account.isCreditCard
                    ? 'Cartão arquivado.'
                    : 'Conta arquivada.',
              );
            } catch (_) {
              if (!context.mounted) return;
              showPollarToast(
                context,
                tone: PollarStatusTone.danger,
                message:
                    'Não foi possível arquivar ${account.isCreditCard ? 'o cartão' : 'a conta'}. Tente novamente.',
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    try {
      await ref.read(accountsProvider.notifier).restore(account.id);
      if (context.mounted) {
        showPollarToast(
          context,
          message: account.isCreditCard
              ? 'Cartão restaurado.'
              : 'Conta restaurada.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        showPollarToast(
          context,
          tone: PollarStatusTone.danger,
          message:
              'Não foi possível restaurar ${account.isCreditCard ? 'o cartão' : 'a conta'}. Tente novamente.',
        );
      }
    }
  }
}

class _AccountsHeader extends StatelessWidget {
  const _AccountsHeader({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contas e cartões',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: PollarSpacing.x2),
        Text(
          'Saldos iniciais, limites e ciclos financeiros em um só lugar.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
    );
    final action = PollarButton(
      label: 'Cadastrar conta ou cartão',
      leadingIcon: LucideIcons.plus,
      fullWidth: compact,
      onPressed: onCreate,
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          copy,
          const SizedBox(height: PollarSpacing.x4),
          action,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: copy),
        const SizedBox(width: PollarSpacing.x6),
        action,
      ],
    );
  }
}

class _ActiveAccountSections extends StatelessWidget {
  const _ActiveAccountSections({
    required this.regular,
    required this.cards,
    required this.privacyHidden,
    required this.onArchive,
  });

  final List<Account> regular;
  final List<Account> cards;
  final bool privacyHidden;
  final ValueChanged<Account> onArchive;

  @override
  Widget build(BuildContext context) {
    final regularSection = _AccountSection(
      title: 'Contas',
      accounts: regular,
      privacyHidden: privacyHidden,
      onAction: onArchive,
    );
    final cardSection = _AccountSection(
      title: 'Cartões de crédito',
      accounts: cards,
      privacyHidden: privacyHidden,
      onAction: onArchive,
    );
    final sideBySide =
        MediaQuery.sizeOf(context).width >= 1040 &&
        regular.isNotEmpty &&
        cards.isNotEmpty;

    if (sideBySide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: regularSection),
          const SizedBox(width: PollarSpacing.x6),
          Expanded(child: cardSection),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (regular.isNotEmpty) regularSection,
        if (regular.isNotEmpty && cards.isNotEmpty)
          const SizedBox(height: PollarSpacing.x8),
        if (cards.isNotEmpty) cardSection,
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.title,
    required this.accounts,
    required this.privacyHidden,
    required this.onAction,
    this.description,
    this.archived = false,
  });

  final String title;
  final String? description;
  final List<Account> accounts;
  final bool privacyHidden;
  final ValueChanged<Account> onAction;
  final bool archived;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      if (description != null) ...[
        const SizedBox(height: PollarSpacing.x2),
        Text(
          description!,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
      const SizedBox(height: PollarSpacing.x4),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 880 ? 2 : 1;
          final width = columns == 2
              ? (constraints.maxWidth - PollarSpacing.x4) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: PollarSpacing.x4,
            runSpacing: PollarSpacing.x4,
            children: [
              for (final account in accounts)
                SizedBox(
                  width: width,
                  child: _AccountCard(
                    account: account,
                    privacyHidden: privacyHidden,
                    archived: archived,
                    onAction: () => onAction(account),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.privacyHidden,
    required this.archived,
    required this.onAction,
  });

  final Account account;
  final bool privacyHidden;
  final bool archived;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final terms = account.creditCardTerms;
    return PollarCard(
      alt: archived,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: account.isCreditCard
                      ? colors.infoSoft
                      : colors.primarySoft,
                  borderRadius: BorderRadius.circular(PollarRadii.medium),
                ),
                child: Icon(
                  account.type.icon,
                  size: 20,
                  color: account.isCreditCard ? colors.info : colors.primary,
                ),
              ),
              const SizedBox(width: PollarSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: PollarSpacing.x1),
                    Text(
                      account.type.label,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              PollarIconButton(
                icon: archived
                    ? LucideIcons.archiveRestore
                    : LucideIcons.archive,
                label: archived
                    ? 'Restaurar ${account.name}'
                    : 'Arquivar ${account.name}',
                size: PollarControlSize.compact,
                onPressed: onAction,
              ),
            ],
          ),
          const SizedBox(height: PollarSpacing.x5),
          Text(
            account.isCreditCard ? 'Dívida inicial' : 'Saldo inicial',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: PollarSpacing.x1),
          PrivacyAmount(
            account.openingBalance,
            hidden: privacyHidden,
            colorBySign: account.isCreditCard,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (terms != null) ...[
            const SizedBox(height: PollarSpacing.x4),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: PollarSpacing.x3),
            Row(
              children: [
                Expanded(
                  child: _CardMetadata(
                    label: 'Limite',
                    child: PrivacyAmount(
                      terms.creditLimit,
                      hidden: privacyHidden,
                      style: PollarTypography.amountStandard,
                    ),
                  ),
                ),
                Expanded(
                  child: _CardMetadata(
                    label: 'Ciclo',
                    child: Text(
                      'Fecha dia ${terms.closingDay} · vence dia ${terms.dueDay}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CardMetadata extends StatelessWidget {
  const _CardMetadata({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textMuted),
      ),
      const SizedBox(height: PollarSpacing.x1),
      child,
    ],
  );
}
