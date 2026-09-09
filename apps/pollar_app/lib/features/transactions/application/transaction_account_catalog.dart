import 'package:meta/meta.dart';

import '../../../core/money/currency.dart';

@immutable
class TransactionAccountReference {
  const TransactionAccountReference({
    required this.id,
    required this.name,
    required this.currency,
    required this.isCreditCard,
    required this.isArchived,
  });

  final String id;
  final String name;
  final Currency currency;
  final bool isCreditCard;
  final bool isArchived;
}

/// Read-only boundary that keeps transactions independent from account storage.
abstract interface class TransactionAccountCatalog {
  Future<List<TransactionAccountReference>> findAll();
}
