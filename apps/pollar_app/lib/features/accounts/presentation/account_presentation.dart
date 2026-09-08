import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/account.dart';

extension AccountTypePresentation on AccountType {
  String get label => switch (this) {
    AccountType.cash => 'Dinheiro',
    AccountType.checking => 'Conta corrente',
    AccountType.savings => 'Poupança',
    AccountType.investment => 'Investimento',
    AccountType.creditCard => 'Cartão de crédito',
  };

  IconData get icon => switch (this) {
    AccountType.cash => LucideIcons.banknote,
    AccountType.checking => LucideIcons.landmark,
    AccountType.savings => LucideIcons.piggyBank,
    AccountType.investment => LucideIcons.chartNoAxesCombined,
    AccountType.creditCard => LucideIcons.creditCard,
  };
}
