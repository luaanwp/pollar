import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/empty_state.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_credit_surface.dart';
import '../../../shared/presentation/pollar_kinetic_card.dart';
import '../../../shared/presentation/pollar_motion.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/money_text.dart';
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
                title: archived.isEmpty
                    ? 'Nenhuma conta cadastrada'
                    : 'Nenhuma conta ativa',
                message: archived.isEmpty
                    ? 'Cadastre uma conta ou cartão para organizar saldos e lançamentos.'
                    : 'Restaure uma conta arquivada abaixo ou cadastre uma nova.',
                action: archived.isNotEmpty
                    ? null
                    : PollarButton(
                        label: 'Cadastrar primeira conta',
                        adaptiveHeight: true,
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
                onOpenCard: (account) =>
                    context.push('/accounts/${account.id}/statement'),
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
          adaptiveHeight: true,
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.pop(modalContext),
        ),
        PollarButton(
          label: 'Arquivar $noun',
          adaptiveHeight: true,
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 760 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Contas e cartões',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Valores iniciais e condições cadastradas.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.textSecondary),
          ),
        ],
      );
      final action = PollarButton(
        label: 'Cadastrar conta ou cartão',
        adaptiveHeight: true,
        leadingIcon: LucideIcons.plus,
        fullWidth: stacked,
        onPressed: onCreate,
      );
      if (stacked) {
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
    },
  );
}

class _ActiveAccountSections extends StatelessWidget {
  const _ActiveAccountSections({
    required this.regular,
    required this.cards,
    required this.privacyHidden,
    required this.onArchive,
    required this.onOpenCard,
  });
  final List<Account> regular;
  final List<Account> cards;
  final bool privacyHidden;
  final ValueChanged<Account> onArchive;
  final ValueChanged<Account> onOpenCard;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
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
        onOpen: onOpenCard,
      );
      final sideBySide =
          constraints.maxWidth >= 980 &&
          MediaQuery.textScalerOf(context).scale(1) <= 1.3 &&
          regular.isNotEmpty &&
          cards.isNotEmpty;
      if (sideBySide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: regularSection),
            const SizedBox(width: PollarSpacing.x6),
            Expanded(flex: 6, child: cardSection),
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
    },
  );
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.title,
    required this.accounts,
    required this.privacyHidden,
    required this.onAction,
    this.description,
    this.archived = false,
    this.onOpen,
  });
  final String title;
  final String? description;
  final List<Account> accounts;
  final bool privacyHidden;
  final ValueChanged<Account> onAction;
  final bool archived;
  final ValueChanged<Account>? onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
      if (description != null) ...[
        const SizedBox(height: PollarSpacing.x2),
        Text(
          description!,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
      const SizedBox(height: PollarSpacing.x3),
      if (onOpen == null)
        PollarCard(
          variant: PollarCardVariant.flat,
          padding: PollarCardPadding.none,
          alt: archived,
          child: Column(
            children: [
              for (final (index, account) in accounts.indexed) ...[
                if (index > 0) Divider(height: 1, color: context.pollar.border),
                _AccountRow(
                  key: ValueKey(account.id),
                  account: account,
                  hidden: privacyHidden,
                  archived: archived,
                  onAction: () => onAction(account),
                ),
              ],
            ],
          ),
        )
      else
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns =
                constraints.maxWidth >= 1000 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.3;
            final width = twoColumns
                ? (constraints.maxWidth - PollarSpacing.x4) / 2
                : constraints.maxWidth.clamp(0.0, 640.0);
            return Wrap(
              spacing: PollarSpacing.x4,
              runSpacing: PollarSpacing.x4,
              children: [
                for (final account in accounts)
                  SizedBox(
                    key: ValueKey(account.id),
                    width: width,
                    child: _AccountCard(
                      account: account,
                      hidden: privacyHidden,
                      onArchive: () => onAction(account),
                      onOpen: () => onOpen!(account),
                    ),
                  ),
              ],
            );
          },
        ),
    ],
  );
}

class _AccountIdentity extends StatelessWidget {
  const _AccountIdentity({
    required this.account,
    this.actions,
    this.compact = false,
  });
  final Account account;
  final Widget? actions;
  final bool compact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final identity = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 24 : 32,
            height: compact ? 24 : 32,
            decoration: BoxDecoration(
              color: account.isCreditCard
                  ? context.pollar.infoSoft
                  : context.pollar.primarySoft,
              borderRadius: BorderRadius.circular(PollarRadii.medium),
            ),
            child: Icon(
              account.type.icon,
              size: compact ? 16 : 20,
              color: account.isCreditCard
                  ? context.pollar.info
                  : context.pollar.primary,
            ),
          ),
          SizedBox(width: compact ? PollarSpacing.x2 : PollarSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.bodyMedium
                              : Theme.of(context).textTheme.bodyLarge)
                          ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: PollarSpacing.x1),
                Text(
                  '${account.type.label} · ${account.currency.code}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.pollar.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
      if (actions == null) return identity;
      if (constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            identity,
            const SizedBox(height: PollarSpacing.x2),
            Align(alignment: Alignment.centerRight, child: actions!),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: identity),
          const SizedBox(width: PollarSpacing.x2),
          actions!,
        ],
      );
    },
  );
}

class _InitialAmount extends StatelessWidget {
  const _InitialAmount({required this.account, required this.hidden});
  final Account account;
  final bool hidden;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final label = Text(
        account.isCreditCard ? 'Dívida inicial' : 'Saldo inicial',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textSecondary),
      );
      final amount = PrivacyAmount(
        account.openingBalance,
        hidden: hidden,
        colorBySign: account.isCreditCard,
        allowWrap: true,
        reserveLayout: true,
        alignment: AlignmentDirectional.topEnd,
        semantic: account.isCreditCard
            ? MoneySemantic.debt
            : MoneySemantic.balance,
      );
      if (constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label,
            const SizedBox(height: PollarSpacing.x1),
            amount,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: label),
          const SizedBox(width: PollarSpacing.x3),
          Expanded(flex: 2, child: amount),
        ],
      );
    },
  );
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    super.key,
    required this.account,
    required this.hidden,
    required this.archived,
    required this.onAction,
  });
  final Account account;
  final bool hidden;
  final bool archived;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(PollarSpacing.x3),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final action = PollarIconButton(
          icon: archived ? LucideIcons.archiveRestore : LucideIcons.archive,
          label: archived
              ? 'Restaurar ${account.name}'
              : 'Arquivar ${account.name}',
          size: PollarControlSize.compact,
          onPressed: onAction,
        );
        final dense =
            constraints.maxWidth >= 320 &&
            MediaQuery.textScalerOf(context).scale(1) <= 1;
        final position = dense
            ? Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _AccountIdentity(account: account, compact: true),
                  ),
                  const SizedBox(width: PollarSpacing.x3),
                  Expanded(
                    flex: 4,
                    child: _InitialAmount(account: account, hidden: hidden),
                  ),
                  const SizedBox(width: PollarSpacing.x2),
                  action,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AccountIdentity(account: account, actions: action),
                  const SizedBox(height: PollarSpacing.x1),
                  _InitialAmount(account: account, hidden: hidden),
                ],
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            position,
            if (account.creditCardTerms case final terms?) ...[
              const SizedBox(height: PollarSpacing.x3),
              _CreditTerms(terms: terms, hidden: hidden),
            ],
          ],
        );
      },
    ),
  );
}

class _CreditTerms extends StatelessWidget {
  const _CreditTerms({required this.terms, required this.hidden});
  final CreditCardTerms terms;
  final bool hidden;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final limit = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Limite',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x1),
          PrivacyAmount(
            terms.creditLimit,
            hidden: hidden,
            allowWrap: true,
            reserveLayout: true,
            semantic: MoneySemantic.neutral,
          ),
        ],
      );
      final cycle = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ciclo',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Fecha dia ${terms.closingDay} · vence dia ${terms.dueDay}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
      if (constraints.maxWidth < 420 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            limit,
            const SizedBox(height: PollarSpacing.x3),
            cycle,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: limit),
          const SizedBox(width: PollarSpacing.x4),
          Expanded(child: cycle),
        ],
      );
    },
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.hidden,
    required this.onArchive,
    required this.onOpen,
  });
  final Account account;
  final bool hidden;
  final VoidCallback onArchive;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => PollarCardMorph(
    tag: 'card-statement-${account.id}',
    creditIdentity: true,
    child: PollarKineticCard(
      front: (flip, focus) => PollarCard(
        padding: PollarCardPadding.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PollarCreditSurface(
              borderRadius: BorderRadius.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.creditCard, size: 24),
                      const SizedBox(width: PollarSpacing.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.pollar.creditForeground,
                                  ),
                            ),
                            const SizedBox(height: PollarSpacing.x1),
                            Text(
                              '${account.type.label} · ${account.currency.code}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.pollar.creditSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: PollarSpacing.x2),
                      PollarIconButton(
                        icon: LucideIcons.archive,
                        label: 'Arquivar ${account.name}',
                        size: PollarControlSize.compact,
                        onPressed: onArchive,
                      ),
                    ],
                  ),
                  const SizedBox(height: PollarSpacing.x4),
                  Text(
                    'Limite',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.creditSecondary),
                  ),
                  const SizedBox(height: PollarSpacing.x1),
                  PrivacyAmount(
                    account.creditCardTerms!.creditLimit,
                    hidden: hidden,
                    allowWrap: true,
                    reserveLayout: true,
                    semantic: MoneySemantic.neutral,
                    style: PollarTypography.balanceHeroCompact,
                  ),
                  const SizedBox(height: PollarSpacing.x3),
                  _InitialAmount(account: account, hidden: hidden),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(PollarSpacing.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Fecha dia ${account.creditCardTerms!.closingDay} · vence dia ${account.creditCardTerms!.dueDay}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                  const SizedBox(height: PollarSpacing.x3),
                  _CreditActions(
                    flip: flip,
                    focus: focus,
                    onOpen: onOpen,
                    flipLabel: 'Virar cartão',
                    tooltip: 'Virar ${account.name}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      back: (flip, focus) => PollarCard(
        padding: PollarCardPadding.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PollarCreditSurface(
              borderRadius: BorderRadius.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Condições do cartão',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: context.pollar.creditForeground),
                  ),
                  const SizedBox(height: PollarSpacing.x3),
                  _InitialAmount(account: account, hidden: hidden),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(PollarSpacing.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CreditTerms(terms: account.creditCardTerms!, hidden: hidden),
                  const SizedBox(height: PollarSpacing.x4),
                  _CreditActions(
                    flip: flip,
                    focus: focus,
                    onOpen: onOpen,
                    flipLabel: 'Voltar à frente',
                    tooltip: 'Voltar à frente do cartão',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CreditActions extends StatelessWidget {
  const _CreditActions({
    required this.flip,
    required this.focus,
    required this.onOpen,
    required this.flipLabel,
    required this.tooltip,
  });
  final VoidCallback flip;
  final FocusNode focus;
  final VoidCallback onOpen;
  final String flipLabel;
  final String tooltip;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final open = PollarButton(
        label: 'Ver fatura',
        trailingIcon: LucideIcons.arrowRight,
        adaptiveHeight: true,
        onPressed: onOpen,
      );
      final turn = Tooltip(
        message: tooltip,
        child: PollarButton(
          label: flipLabel,
          leadingIcon: LucideIcons.flipHorizontal,
          focusNode: focus,
          variant: PollarButtonVariant.secondary,
          adaptiveHeight: true,
          onPressed: flip,
        ),
      );
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            open,
            const SizedBox(height: PollarSpacing.x2),
            turn,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: open),
          const SizedBox(width: PollarSpacing.x2),
          Expanded(child: turn),
        ],
      );
    },
  );
}
