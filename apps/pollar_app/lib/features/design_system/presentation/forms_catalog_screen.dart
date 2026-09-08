import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../app/theme/theme_mode_provider.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/currency_input.dart';
import '../../../shared/presentation/empty_state.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_text_field.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/status_badge.dart';

/// Development-only component catalog. Examples never create financial data.
class FormsCatalogScreen extends ConsumerStatefulWidget {
  const FormsCatalogScreen({super.key});

  @override
  ConsumerState<FormsCatalogScreen> createState() => _FormsCatalogScreenState();
}

class _FormsCatalogScreenState extends ConsumerState<FormsCatalogScreen> {
  final _form = GlobalKey<FormState>();
  var _installments = 3;
  var _reminder = false;
  bool? _confirmed = false;
  var _validated = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Design system'),
          actions: [
            PollarIconButton(
              icon: LucideIcons.sunMoon,
              label: 'Alternar tema',
              onPressed: () => ref
                  .read(themeModeProvider.notifier)
                  .toggle(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
            ),
            const SizedBox(width: PollarSpacing.x2),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Formulários'),
              Tab(text: 'Componentes'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CatalogPage(child: _buildForms()),
            const _CatalogPage(child: _ComponentsCatalog()),
            _CatalogPage(child: _FeedbackCatalog(onRetry: () {})),
          ],
        ),
      ),
    );
  }

  Widget _buildForms() {
    return Form(
      key: _form,
      onChanged: () {
        if (_validated) setState(() => _validated = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CatalogHeading(
            title: 'Formulários',
            description: 'Campos, seleção e controles com validação nativa. Os dados deste exemplo não são salvos.',
          ),
          const SizedBox(height: PollarSpacing.x6),
          PollarTextField(
            label: 'Descrição',
            hint: 'Mercado do bairro',
            leadingIcon: LucideIcons.receiptText,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Informe uma descrição para identificar a compra.'
                : null,
          ),
          const SizedBox(height: PollarSpacing.x6),
          CurrencyInput(
            label: 'Valor da compra',
            currency: Currency.brl,
            initialValue: const Money(
              minorUnits: 10000,
              currency: Currency.brl,
            ),
            installments: _installments,
            onChanged: (_) {},
            validator: (value) => value == null || !value.isPositive
                ? 'Informe um valor maior que zero.'
                : null,
          ),
          const SizedBox(height: PollarSpacing.x6),
          PollarSelect<int>(
            label: 'Parcelas',
            initialValue: 3,
            options: [
              for (final count in [1, 2, 3, 6, 12])
                PollarSelectOption(
                  value: count,
                  label: '$count ${count == 1 ? 'parcela' : 'parcelas'}',
                ),
            ],
            onChanged: (count) => setState(() => _installments = count!),
          ),
          const SizedBox(height: PollarSpacing.x3),
          PollarSwitch(
            label: 'Lembrar do vencimento',
            description: 'Mostra um aviso antes da data de pagamento.',
            value: _reminder,
            onChanged: (value) => setState(() => _reminder = value),
          ),
          PollarCheckbox(
            label: 'Conferi os valores',
            value: _confirmed,
            tristate: true,
            onChanged: (value) => setState(() => _confirmed = value),
          ),
          const SizedBox(height: PollarSpacing.x4),
          PollarButton(
            label: 'Validar exemplo',
            fullWidth: true,
            onPressed: () {
              final valid = _form.currentState!.validate();
              setState(() => _validated = valid);
            },
          ),
          if (_validated) ...[
            const SizedBox(height: PollarSpacing.x3),
            Semantics(
              liveRegion: true,
              child: Text('Campos válidos. Nenhuma transação foi criada.'),
            ),
          ],
          const SizedBox(height: PollarSpacing.x8),
          const PollarTextField(label: 'Campo desabilitado', enabled: false),
          const SizedBox(height: PollarSpacing.x6),
          CurrencyInput(
            label: 'Valor somente leitura',
            currency: Currency.brl,
            initialValue: const Money(
              minorUnits: 23415,
              currency: Currency.brl,
            ),
            readOnly: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

class _ComponentsCatalog extends StatelessWidget {
  const _ComponentsCatalog();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CatalogHeading(
          title: 'Ações e superfícies',
          description: 'Variantes compartilham tamanho, foco, estados desabilitados e alvos de toque.',
        ),
        const SizedBox(height: PollarSpacing.x6),
        Wrap(
          spacing: PollarSpacing.x3,
          runSpacing: PollarSpacing.x3,
          children: [
            PollarButton(
              label: 'Nova transação',
              leadingIcon: LucideIcons.plus,
              onPressed: () {},
            ),
            PollarButton(
              label: 'Filtrar transações',
              variant: PollarButtonVariant.secondary,
              size: PollarControlSize.compact,
              leadingIcon: LucideIcons.listFilter,
              onPressed: () {},
            ),
            PollarButton(
              label: 'Ver detalhes',
              variant: PollarButtonVariant.ghost,
              onPressed: () {},
            ),
            PollarButton(
              label: 'Excluir cartão',
              variant: PollarButtonVariant.danger,
              leadingIcon: LucideIcons.trash2,
              onPressed: () {},
            ),
            const PollarButton(
              label: 'Salvando transação',
              loading: true,
              onPressed: null,
            ),
            const PollarButton(label: 'Ação indisponível', onPressed: null),
          ],
        ),
        const SizedBox(height: PollarSpacing.x6),
        Wrap(
          spacing: PollarSpacing.x2,
          runSpacing: PollarSpacing.x2,
          children: [
            PollarIconButton(
              icon: LucideIcons.eye,
              label: 'Mostrar valores',
              selected: true,
              onPressed: () {},
            ),
            PollarIconButton(
              icon: LucideIcons.slidersHorizontal,
              label: 'Configurar colunas',
              outlined: true,
              onPressed: () {},
            ),
            const PollarIconButton(
              icon: LucideIcons.bell,
              label: 'Notificações indisponíveis',
              onPressed: null,
            ),
          ],
        ),
        const SizedBox(height: PollarSpacing.x8),
        PollarCard(
          semanticLabel: 'Resumo de orçamento interativo',
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orçamento de alimentação',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                'Abra para conferir lançamentos e ajustar o limite mensal.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: PollarSpacing.x5),
        const Wrap(
          spacing: PollarSpacing.x2,
          runSpacing: PollarSpacing.x2,
          children: [
            StatusBadge(
              label: 'Paga',
              tone: PollarStatusTone.success,
              icon: LucideIcons.check,
            ),
            StatusBadge(
              label: 'Parcialmente paga',
              tone: PollarStatusTone.warning,
              icon: LucideIcons.clock,
            ),
            StatusBadge(
              label: 'Conflito',
              tone: PollarStatusTone.danger,
              icon: LucideIcons.triangleAlert,
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackCatalog extends StatelessWidget {
  const _FeedbackCatalog({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CatalogHeading(
          title: 'Feedback e estados',
          description: 'Avisos persistentes, confirmações transitórias e recuperação explícita.',
        ),
        const SizedBox(height: PollarSpacing.x6),
        const PollarBanner(
          tone: PollarStatusTone.warning,
          icon: LucideIcons.wifiOff,
          title: 'Você está offline',
          message: 'As alterações ficam salvas neste dispositivo e serão sincronizadas quando a conexão voltar.',
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarBanner(
          tone: PollarStatusTone.danger,
          title: 'A sincronização não terminou',
          message: 'Verifique a conexão e tente sincronizar novamente.',
          actions: [
            PollarButton(
              label: 'Tentar novamente',
              size: PollarControlSize.compact,
              variant: PollarButtonVariant.secondary,
              onPressed: onRetry,
            ),
          ],
        ),
        const SizedBox(height: PollarSpacing.x5),
        Wrap(
          spacing: PollarSpacing.x3,
          runSpacing: PollarSpacing.x3,
          children: [
            PollarButton(
              label: 'Excluir cartão',
              variant: PollarButtonVariant.danger,
              onPressed: () => showPollarAdaptiveModal<void>(
                context: context,
                title: 'Excluir o cartão Ouro?',
                description: 'As 47 transações vinculadas continuarão no histórico, mas a fatura em aberto deixará de ser acompanhada.',
                tone: PollarModalTone.danger,
                actions: (modalContext) => [
                  PollarButton(
                    label: 'Cancelar exclusão',
                    variant: PollarButtonVariant.secondary,
                    onPressed: () => Navigator.of(modalContext).pop(),
                  ),
                  PollarButton(
                    label: 'Excluir cartão',
                    variant: PollarButtonVariant.danger,
                    onPressed: () => Navigator.of(modalContext).pop(),
                  ),
                ],
              ),
            ),
            PollarButton(
              label: 'Confirmar exclusão reversível',
              variant: PollarButtonVariant.secondary,
              onPressed: () => showPollarToast(
                context,
                message: 'Transação excluída.',
                actionLabel: 'Desfazer',
              ),
            ),
          ],
        ),
        const SizedBox(height: PollarSpacing.x6),
        PollarCard(
          padding: PollarCardPadding.none,
          child: SizedBox(
            height: 270,
            child: PollarErrorState(
              title: 'Não foi possível carregar as transações',
              message: 'Verifique a conexão e tente carregar novamente.',
              actionLabel: 'Carregar novamente',
              onRetry: onRetry,
            ),
          ),
        ),
        const SizedBox(height: PollarSpacing.x4),
        const PollarCard(
          padding: PollarCardPadding.none,
          child: SizedBox(height: 150, child: PollarLoadingState()),
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarCard(
          padding: PollarCardPadding.none,
          child: SizedBox(
            height: 250,
            child: EmptyState(
              icon: LucideIcons.arrowLeftRight,
              title: 'Nenhuma transação ainda',
              message:
                  'Registre uma receita ou despesa para começar o histórico.',
              action: PollarButton(
                label: 'Registrar transação',
                onPressed: onRetry,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CatalogPage extends StatelessWidget {
  const _CatalogPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: ListView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin
              ? PollarSpacing.x4
              : PollarSpacing.x6,
        ),
        children: [
          child,
          const SizedBox(height: PollarSpacing.x8),
        ],
      ),
    ),
  );
}

class _CatalogHeading extends StatelessWidget {
  const _CatalogHeading({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: PollarSpacing.x2),
      Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: context.pollar.textSecondary),
      ),
    ],
  );
}
