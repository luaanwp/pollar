import 'package:meta/meta.dart';

import '../money/money.dart';
import 'balance_rules.dart';

/// Raised when a transaction amount is not a strictly positive magnitude.
class NonPositiveAmountError extends Error {
  NonPositiveAmountError(this.amount);
  final Money amount;
  @override
  String toString() =>
      'NonPositiveAmountError: amount must be > 0, got $amount';
}

/// Raised when a two-legged transaction lacks a distinct counter account.
class MissingCounterAccountError extends Error {
  MissingCounterAccountError(this.type);
  final TransactionType type;
  @override
  String toString() =>
      'MissingCounterAccountError: $type requires a distinct counter account';
}

/// Raised when a single-legged transaction is given a counter account.
class UnexpectedCounterAccountError extends Error {
  UnexpectedCounterAccountError(this.type);
  final TransactionType type;
  @override
  String toString() =>
      'UnexpectedCounterAccountError: $type must not have a counter account';
}

/// A single signed movement against one account — one leg of a transaction.
///
/// Double-entry style: income/expense/card-purchase produce one posting;
/// transfer and card-statement-payment produce two that net to zero.
@immutable
class Posting {
  const Posting({
    required this.accountId,
    required this.signedAmount,
    required this.status,
  });

  final String accountId;
  final Money signedAmount;
  final TransactionStatus status;

  @override
  bool operator ==(Object other) =>
      other is Posting &&
      other.accountId == accountId &&
      other.signedAmount == signedAmount &&
      other.status == status;

  @override
  int get hashCode => Object.hash(accountId, signedAmount, status);

  @override
  String toString() => 'Posting($accountId $signedAmount $status)';
}

/// Builds the account postings for a transaction, enforcing the centralized
/// financial invariants for amount sign, account arity, and per-type direction.
///
/// [amount] must be a positive magnitude; direction is derived from [type].
List<Posting> postingsFor({
  required TransactionType type,
  required TransactionStatus status,
  required Money amount,
  required String accountId,
  String? counterAccountId,
}) {
  if (!amount.isPositive) {
    throw NonPositiveAmountError(amount);
  }

  Posting leg(String account, Money value) =>
      Posting(accountId: account, signedAmount: value, status: status);

  final twoLegged =
      type == TransactionType.transfer ||
      type == TransactionType.cardStatementPayment;

  if (twoLegged) {
    if (counterAccountId == null || counterAccountId == accountId) {
      throw MissingCounterAccountError(type);
    }
    // transfer: money leaves accountId, arrives at counterAccountId.
    // statement payment: money leaves the bank (accountId), reduces the card
    // debt at counterAccountId (a positive posting toward zero).
    return [leg(accountId, -amount), leg(counterAccountId, amount)];
  }

  if (counterAccountId != null) {
    throw UnexpectedCounterAccountError(type);
  }

  switch (type) {
    case TransactionType.income:
      return [leg(accountId, amount)];
    case TransactionType.expense:
    case TransactionType.cardPurchase:
      return [leg(accountId, -amount)];
    case TransactionType.transfer:
    case TransactionType.cardStatementPayment:
      throw StateError('unreachable: two-legged handled above');
  }
}
