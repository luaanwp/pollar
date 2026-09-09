import 'package:meta/meta.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

enum CardStatementStatus { open, closed, partiallyPaid, paid, overdue }

@immutable
class StatementPurchase {
  const StatementPurchase({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    this.category,
    this.installmentNumber,
    this.installmentCount,
    this.purchaseTotal,
  });

  final String id;
  final String description;
  final DateTime date;
  final Money amount;
  final String? category;
  final int? installmentNumber;
  final int? installmentCount;
  final Money? purchaseTotal;

  bool get isInstallment => installmentNumber != null;
}

@immutable
class FutureInstallment {
  const FutureInstallment({
    required this.description,
    required this.amount,
    required this.date,
    required this.number,
    required this.count,
  });

  final String description;
  final Money amount;
  final DateTime date;
  final int number;
  final int count;
}

@immutable
class CardStatement {
  const CardStatement({
    required this.id,
    required this.periodStart,
    required this.closingDate,
    required this.dueDate,
    required this.status,
    required this.total,
    required this.paid,
    required this.outstanding,
    required this.purchases,
  });

  final String id;
  final DateTime periodStart;
  final DateTime closingDate;
  final DateTime dueDate;
  final CardStatementStatus status;
  final Money total;
  final Money paid;
  final Money outstanding;
  final List<StatementPurchase> purchases;
}

@immutable
class StatementPaymentAccount {
  const StatementPaymentAccount({
    required this.id,
    required this.name,
    required this.currency,
  });

  final String id;
  final String name;
  final Currency currency;
}

@immutable
class CardStatementSnapshot {
  const CardStatementSnapshot({
    required this.cardId,
    required this.cardName,
    required this.currency,
    required this.creditLimit,
    required this.availableLimit,
    required this.statement,
    required this.futureInstallments,
    required this.paymentAccounts,
  });

  final String cardId;
  final String cardName;
  final Currency currency;
  final Money creditLimit;
  final Money availableLimit;
  final CardStatement statement;
  final List<FutureInstallment> futureInstallments;
  final List<StatementPaymentAccount> paymentAccounts;

  int get utilizationPercent {
    if (!creditLimit.isPositive) return 0;
    final used = creditLimit.minorUnits - availableLimit.minorUnits;
    return ((used * 100 + creditLimit.minorUnits ~/ 2) ~/
            creditLimit.minorUnits)
        .clamp(0, 999);
  }
}
