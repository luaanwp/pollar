import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/application/financial_data_revision.dart';
import '../application/statement_data_source.dart';
import '../application/statement_service.dart';
import '../domain/card_statement.dart';

final statementDataSourceProvider = Provider<StatementDataSource>((ref) {
  throw StateError('StatementDataSource was not configured');
});

final statementClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final statementServiceProvider = Provider<StatementService>(
  (ref) => StatementService(ref.watch(statementDataSourceProvider)),
);

final cardStatementProvider =
    AsyncNotifierProvider.family<
      CardStatementController,
      CardStatementSnapshot,
      String
    >(CardStatementController.new);

class CardStatementController extends AsyncNotifier<CardStatementSnapshot> {
  CardStatementController(this.cardId);

  final String cardId;

  @override
  Future<CardStatementSnapshot> build() {
    ref.watch(financialDataRevisionProvider);
    return ref
        .watch(statementServiceProvider)
        .load(cardId, ref.watch(statementClockProvider)());
  }

  Future<void> pay(StatementPaymentCommand command) async {
    final snapshot = state.requireValue;
    await ref
        .read(statementServiceProvider)
        .pay(snapshot: snapshot, command: command);
    ref.read(financialDataRevisionProvider.notifier).bump();
  }

  void retry() => ref.invalidateSelf();
}
