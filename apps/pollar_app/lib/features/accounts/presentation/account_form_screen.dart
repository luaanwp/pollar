import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/currency_input.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_text_field.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/account.dart';
import 'account_presentation.dart';
import 'accounts_controller.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key});

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _closingDayController = TextEditingController();
  final _dueDayController = TextEditingController();
  var _type = AccountType.checking;
  Money? _openingBalance;
  Money? _creditLimit;
  var _saving = false;
  String? _error;

  bool get _isCard => _type == AccountType.creditCard;

  @override
  void dispose() {
    _nameController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: EdgeInsets.all(
            compact ? PollarSpacing.x4 : PollarSpacing.x6,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PollarIconButton(
                  icon: LucideIcons.arrowLeft,
                  label: 'Voltar para contas',
                  outlined: true,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: PollarSpacing.x4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCard ? 'Cadastrar cartão' : 'Cadastrar conta',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: PollarSpacing.x2),
                      Text(
                        _isCard
                            ? 'Informe a dívida, o limite e o ciclo atuais do cartão.'
                            : 'Informe o saldo de partida. Novos lançamentos serão calculados a partir dele.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: context.pollar.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: PollarSpacing.x6),
            PollarCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Identificação',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: PollarSpacing.x5),
                    PollarTextField(
                      key: const Key('account-name'),
                      label: 'Nome da conta',
                      hint: _isCard ? 'Cartão principal' : 'Conta principal',
                      controller: _nameController,
                      leadingIcon: _type.icon,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Informe um nome para identificar a conta.'
                          : null,
                    ),
                    const SizedBox(height: PollarSpacing.x5),
                    PollarSelect<AccountType>(
                      key: const Key('account-type'),
                      label: 'Tipo de conta',
                      initialValue: _type,
                      options: [
                        for (final type in AccountType.values)
                          PollarSelectOption(value: type, label: type.label),
                      ],
                      onChanged: (type) {
                        if (type == null) return;
                        setState(() {
                          _type = type;
                          _openingBalance = null;
                          _creditLimit = null;
                          _closingDayController.clear();
                          _dueDayController.clear();
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: PollarSpacing.x8),
                    Text(
                      _isCard ? 'Fatura e limite' : 'Saldo de partida',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: PollarSpacing.x5),
                    KeyedSubtree(
                      key: const Key('opening-balance'),
                      child: CurrencyInput(
                        key: ValueKey(_isCard),
                        label: _isCard ? 'Dívida atual' : 'Saldo inicial',
                        currency: Currency.brl,
                        allowNegative: !_isCard,
                        onChanged: (value) => _openingBalance = value,
                        validator: _isCard
                            ? (value) => value != null && value.isNegative
                                  ? 'Informe a dívida como valor positivo.'
                                  : null
                            : null,
                      ),
                    ),
                    if (_isCard) ...[
                      const SizedBox(height: PollarSpacing.x5),
                      CurrencyInput(
                        key: const Key('credit-limit'),
                        label: 'Limite de crédito',
                        currency: Currency.brl,
                        onChanged: (value) => _creditLimit = value,
                        validator: (value) => value == null || !value.isPositive
                            ? 'Informe um limite maior que zero.'
                            : null,
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      _BillingDays(
                        closingController: _closingDayController,
                        dueController: _dueDayController,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: PollarSpacing.x5),
                      PollarBanner(
                        tone: PollarStatusTone.danger,
                        title: _isCard
                            ? 'O cartão não foi cadastrado'
                            : 'A conta não foi cadastrada',
                        message: _error!,
                      ),
                    ],
                    const SizedBox(height: PollarSpacing.x6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PollarButton(
                        label: _isCard ? 'Salvar cartão' : 'Salvar conta',
                        leadingIcon: LucideIcons.save,
                        loading: _saving,
                        fullWidth: compact,
                        onPressed: _saving ? null : _save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PollarSpacing.x8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final opening = _openingBalance;
    if (opening == null || (_isCard && _creditLimit == null)) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final account = Account(
        id: const Uuid().v4(),
        name: _nameController.text,
        type: _type,
        currency: Currency.brl,
        openingBalance: _isCard ? -opening.abs() : opening,
        creditCardTerms: _isCard
            ? CreditCardTerms(
                creditLimit: _creditLimit!,
                closingDay: int.parse(_closingDayController.text),
                dueDay: int.parse(_dueDayController.text),
              )
            : null,
      );
      await ref.read(accountsProvider.notifier).create(account);
      if (mounted) {
        context.pop(_isCard ? 'Cartão cadastrado.' : 'Conta cadastrada.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _isCard
            ? 'Revise os dados e tente salvar o cartão novamente.'
            : 'Revise os dados e tente salvar a conta novamente.';
      });
    }
  }
}

class _BillingDays extends StatelessWidget {
  const _BillingDays({
    required this.closingController,
    required this.dueController,
  });

  final TextEditingController closingController;
  final TextEditingController dueController;

  @override
  Widget build(BuildContext context) {
    final closing = PollarTextField(
      key: const Key('closing-day'),
      label: 'Dia de fechamento',
      hint: '20',
      controller: closingController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: _validateBillingDay,
    );
    final due = PollarTextField(
      key: const Key('due-day'),
      label: 'Dia de vencimento',
      hint: '28',
      controller: dueController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: _validateBillingDay,
    );

    if (MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          closing,
          const SizedBox(height: PollarSpacing.x5),
          due,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: closing),
        const SizedBox(width: PollarSpacing.x4),
        Expanded(child: due),
      ],
    );
  }

  static String? _validateBillingDay(String? value) {
    final day = int.tryParse(value ?? '');
    if (day == null || day < 1 || day > 31) {
      return 'Informe um dia entre 1 e 31.';
    }
    return null;
  }
}
