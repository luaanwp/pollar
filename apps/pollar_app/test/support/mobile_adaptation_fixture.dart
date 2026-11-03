import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/features/planning/application/planning_ledger_source.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';
import 'package:pollar_app/features/planning/presentation/planning_forms.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_forms.dart';
import 'package:pollar_app/shared/presentation/pollar_button.dart';
import 'package:pollar_app/shared/presentation/pollar_modal.dart';

const mobileFormActions = {
  'Orçamento': 'Salvar orçamento',
  'Compromisso': 'Salvar compromisso',
  'Meta': 'Salvar meta',
  'Ativo': 'Salvar ativo',
  'Dívida': 'Salvar dívida',
};

class MobileFormHarness extends StatelessWidget {
  const MobileFormHarness({
    super.key,
    this.dark = false,
    this.reduced = false,
    this.onBudgetSaved,
  });
  final bool dark;
  final bool reduced;
  final Future<void> Function(Budget)? onBudgetSaved;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? PollarTheme.dark() : PollarTheme.light(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child!,
          if (MediaQuery.viewInsetsOf(context).bottom > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.viewInsetsOf(context).bottom,
              child: IgnorePointer(
                child: ColoredBox(
                  color: context.pollar.surfaceAlt,
                  child: Center(
                    child: Text(
                      'Área do teclado simulada',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final name in mobileFormActions.keys)
                PollarButton(
                  label: name,
                  onPressed: () => _open(context, name),
                ),
              PollarButton(
                label: 'Confirmar',
                onPressed: () => showPollarAdaptiveModal<void>(
                  context: context,
                  title: 'Manter o registro?',
                  description: 'Os dados continuam salvos neste dispositivo.',
                  actions: (modalContext) => [
                    PollarButton(
                      label: 'Voltar ao registro',
                      adaptiveHeight: true,
                      onPressed: () => Navigator.of(modalContext).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _open(BuildContext context, String form) {
    final now = DateTime(2026, 9, 9);
    switch (form) {
      case 'Orçamento':
        showBudgetForm(
          context: context,
          month: now,
          currency: Currency.brl,
          onSave: onBudgetSaved ?? (_) async {},
        );
      case 'Compromisso':
        showRecurringRuleForm(
          context: context,
          accounts: const [
            PlanningAccountReference(
              id: 'bank',
              name: 'Conta principal',
              currency: Currency.brl,
              active: true,
            ),
          ],
          initialDate: now,
          onSave: (_) async {},
        );
      case 'Meta':
        showGoalForm(
          context: context,
          currency: Currency.brl,
          now: now,
          onSave: (_) async {},
        );
      case 'Ativo':
        showAssetForm(
          context: context,
          currency: Currency.brl,
          now: now,
          onSave: (_) async {},
        );
      case 'Dívida':
        showDebtForm(
          context: context,
          currency: Currency.brl,
          now: now,
          onSave: (_) async {},
        );
    }
  }
}
