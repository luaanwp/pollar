import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../shared/presentation/pollar_button.dart';
import '../../../../shared/presentation/pollar_card.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../domain/overview_snapshot.dart';

class OverviewAccountPositions extends StatelessWidget {
  const OverviewAccountPositions({
    super.key,
    required this.accounts,
    required this.privacyHidden,
    required this.onOpenAccounts,
  });

  final List<OverviewAccountPosition> accounts;
  final bool privacyHidden;
  final VoidCallback onOpenAccounts;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return PollarCard(
      padding: PollarCardPadding.none,
      child: Column(
        children: [
          _SectionHeader(onOpenAccounts: onOpenAccounts),
          Divider(height: 1, color: pollar.border),
          for (final (index, account) in accounts.indexed) ...[
            if (index > 0) Divider(height: 1, color: pollar.border),
            _AccountPositionRow(account: account, privacyHidden: privacyHidden),
          ],
        ],
      ),
    );
  }
}

class _AccountPositionRow extends StatelessWidget {
  const _AccountPositionRow({
    required this.account,
    required this.privacyHidden,
  });

  final OverviewAccountPosition account;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final identity = Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: account.isCreditCard ? pollar.infoSoft : pollar.primarySoft,
            borderRadius: BorderRadius.circular(PollarRadii.medium),
          ),
          child: Icon(
            account.isCreditCard ? LucideIcons.creditCard : LucideIcons.wallet,
            size: 18,
            color: account.isCreditCard ? pollar.info : pollar.primary,
          ),
        ),
        const SizedBox(width: PollarSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                account.isCreditCard
                    ? 'Dívida confirmada'
                    : 'Confirmado · projetado',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: pollar.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
    final amounts = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PrivacyAmount(
          account.balance.confirmed,
          hidden: privacyHidden,
          maskDigits: 5,
          semantic: account.isCreditCard
              ? MoneySemantic.debt
              : MoneySemantic.balance,
        ),
        if (!account.isCreditCard &&
            account.balance.projected != account.balance.confirmed) ...[
          const SizedBox(height: 2),
          PrivacyAmount(
            account.balance.projected,
            hidden: privacyHidden,
            maskDigits: 5,
            semantic: MoneySemantic.balance,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: pollar.textMuted),
          ),
        ],
      ],
    );
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PollarSpacing.x4,
        vertical: PollarSpacing.x3,
      ),
      child: accessible
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: PollarSpacing.x2),
                Align(alignment: Alignment.centerRight, child: amounts),
              ],
            )
          : Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: PollarSpacing.x3),
                amounts,
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onOpenAccounts});

  final VoidCallback onOpenAccounts;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      'Posições por conta',
      style: Theme.of(context).textTheme.titleMedium,
    );
    final action = PollarButton(
      label: 'Ver contas',
      trailingIcon: LucideIcons.arrowRight,
      variant: PollarButtonVariant.ghost,
      size: PollarControlSize.compact,
      onPressed: onOpenAccounts,
    );
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PollarSpacing.x4,
        PollarSpacing.x3,
        PollarSpacing.x2,
        PollarSpacing.x3,
      ),
      child: accessible
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: PollarSpacing.x2),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            )
          : Row(
              children: [
                Expanded(child: title),
                action,
              ],
            ),
    );
  }
}
