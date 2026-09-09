import 'package:flutter_riverpod/flutter_riverpod.dart';

final financialDataRevisionProvider =
    NotifierProvider<FinancialDataRevision, int>(FinancialDataRevision.new);

/// Small invalidation signal shared by financial features.
///
/// It carries no business data: repositories remain authoritative, while
/// derived read models can reload after an account or transaction mutation.
class FinancialDataRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
