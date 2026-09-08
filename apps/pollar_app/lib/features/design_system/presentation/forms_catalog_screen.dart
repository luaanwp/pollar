import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../app/theme/theme_mode_provider.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/currency_input.dart';
import '../../../shared/presentation/pollar_text_field.dart';

/// Development-only playground. Validation never creates financial records.
class FormsCatalogScreen extends ConsumerStatefulWidget {
  const FormsCatalogScreen({super.key});

  @override
  ConsumerState<FormsCatalogScreen> createState() => _FormsCatalogScreenState();
}

class _FormsCatalogScreenState extends ConsumerState<FormsCatalogScreen> {
  final _form = GlobalKey<FormState>();
  var _installments = 3;
  var _reminder = false;
  var _confirmed = false;
  var _validated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulários'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            icon: const Icon(LucideIcons.sunMoon),
            onPressed: () => ref
                .read(themeModeProvider.notifier)
                .toggle(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _form,
            onChanged: () {
              if (_validated) setState(() => _validated = false);
            },
            child: ListView(
              padding: const EdgeInsets.all(PollarSpacing.x4),
              children: [
                Text(
                  'Catálogo de desenvolvimento',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: PollarSpacing.x2),
                const Text(
                  'Experimente os campos e a validação. Os dados deste exemplo não são salvos.',
                ),
                const SizedBox(height: PollarSpacing.x6),
                PollarTextField(
                  label: 'Descrição',
                  hint: 'Mercado do bairro',
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
                DropdownButtonFormField<int>(
                  icon: const Icon(LucideIcons.chevronDown, size: 20),
                  initialValue: 3,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Parcelas'),
                  items: [
                    for (final count in [1, 2, 3, 6, 12])
                      DropdownMenuItem(
                        value: count,
                        child: Text(
                          '$count ${count == 1 ? 'parcela' : 'parcelas'}',
                        ),
                      ),
                  ],
                  onChanged: (count) => setState(() => _installments = count!),
                ),
                const SizedBox(height: PollarSpacing.x4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lembrar do vencimento'),
                  value: _reminder,
                  onChanged: (value) => setState(() => _reminder = value),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Conferi os valores'),
                  value: _confirmed,
                  onChanged: (value) => setState(() => _confirmed = value!),
                ),
                const SizedBox(height: PollarSpacing.x4),
                FilledButton(
                  onPressed: () {
                    final valid = _form.currentState!.validate();
                    setState(() => _validated = valid);
                  },
                  child: const Text('Validar exemplo'),
                ),
                if (_validated) ...[
                  const SizedBox(height: PollarSpacing.x3),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'Campos válidos. Nenhuma transação foi criada.',
                    ),
                  ),
                ],
                const SizedBox(height: PollarSpacing.x8),
                const PollarTextField(
                  label: 'Campo desabilitado',
                  enabled: false,
                ),
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
          ),
        ),
      ),
    );
  }
}
