import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

class WealthLedgerPosition {
  const WealthLedgerPosition({
    required this.id,
    required this.name,
    required this.balance,
    required this.isCreditCard,
    required this.active,
  });

  final String id;
  final String name;
  final Money balance;
  final bool isCreditCard;
  final bool active;
}

abstract interface class WealthLedgerSource {
  Future<List<WealthLedgerPosition>> listConfirmedPositions();

  Future<List<Currency>> listCurrencies();
}
