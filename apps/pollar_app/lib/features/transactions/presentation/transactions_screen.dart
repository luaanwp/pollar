import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/presentation/empty_state.dart';

/// Transactions ("Transações") — placeholder until the data layer and the
/// add-expense flow land. The list, filters and detail panel arrive with the
/// transactions slice.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: LucideIcons.arrowLeftRight,
      title: 'Nenhuma transação ainda',
      message:
          'Quando você registrar receitas e despesas, elas aparecem aqui, '
          'agrupadas por dia.',
    );
  }
}
