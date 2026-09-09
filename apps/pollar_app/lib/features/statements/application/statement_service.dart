import '../../../core/ledger/balance_calculator.dart';
import '../../../core/ledger/balance_rules.dart';
import '../../../core/ledger/posting.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/card_statement.dart';
import 'statement_data_source.dart';

class CardStatementNotFoundException implements Exception {
  const CardStatementNotFoundException(this.cardId);
  final String cardId;
}

class InvalidStatementPaymentException implements Exception {
  const InvalidStatementPaymentException(this.message);
  final String message;
}

class StatementService {
  const StatementService(this._source);
  final StatementDataSource _source;

  Future<CardStatementSnapshot> load(String cardId, DateTime today) async {
    final data = await _source.load();
    final card = data.accounts
        .where((item) => item.id == cardId && item.isCreditCard)
        .firstOrNull;
    if (card == null || card.creditLimit == null) {
      throw CardStatementNotFoundException(cardId);
    }
    var closing = _closingForPurchase(today, card.closingDay!);
    final closedCycles =
        data.transactions
            .where(
              (item) =>
                  item.type == TransactionType.cardPurchase &&
                  item.accountId == cardId &&
                  item.status != TransactionStatus.cancelado,
            )
            .map(
              (item) => _closingForPurchase(item.occurredAt, card.closingDay!),
            )
            .where((date) => !date.isAfter(today))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    for (final candidate in closedCycles) {
      final candidateId = _statementId(cardId, candidate);
      final candidateTotal = _sum(
        data.transactions
            .where(
              (item) =>
                  item.type == TransactionType.cardPurchase &&
                  item.accountId == cardId &&
                  item.status != TransactionStatus.cancelado &&
                  _closingForPurchase(item.occurredAt, card.closingDay!) ==
                      candidate,
            )
            .map((item) => item.amount),
        card.currency,
      );
      final candidatePaid = _sum(
        data.transactions
            .where(
              (item) =>
                  item.type == TransactionType.cardStatementPayment &&
                  item.counterAccountId == cardId &&
                  item.statementId == candidateId &&
                  item.status != TransactionStatus.cancelado,
            )
            .map((item) => item.amount),
        card.currency,
      );
      if (candidateTotal.minorUnits > candidatePaid.minorUnits) {
        closing = candidate;
        break;
      }
    }
    final due = _dueForClosing(closing, card.dueDay!);
    final statementId = _statementId(cardId, closing);
    final previousClosing = _addMonths(closing, -1, card.closingDay!);
    final relevant =
        data.transactions
            .where(
              (item) =>
                  item.type == TransactionType.cardPurchase &&
                  item.accountId == cardId &&
                  item.status != TransactionStatus.cancelado &&
                  _closingForPurchase(item.occurredAt, card.closingDay!) ==
                      closing,
            )
            .toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final payments = data.transactions.where(
      (item) =>
          item.type == TransactionType.cardStatementPayment &&
          item.counterAccountId == cardId &&
          item.statementId == statementId &&
          item.status != TransactionStatus.cancelado,
    );
    final total = _sum(relevant.map((item) => item.amount), card.currency);
    final paid = _sum(payments.map((item) => item.amount), card.currency);
    final outstandingMinor = (total.minorUnits - paid.minorUnits).clamp(
      0,
      total.minorUnits,
    );
    final outstanding = Money(
      minorUnits: outstandingMinor,
      currency: card.currency,
    );
    final status = outstanding.isZero && total.isPositive
        ? CardStatementStatus.paid
        : paid.isPositive
        ? CardStatementStatus.partiallyPaid
        : today.isAfter(due)
        ? CardStatementStatus.overdue
        : today.isAfter(closing)
        ? CardStatementStatus.closed
        : CardStatementStatus.open;

    final cardTransactions = data.transactions.where(
      (item) =>
          item.status != TransactionStatus.cancelado &&
          (item.accountId == cardId || item.counterAccountId == cardId),
    );
    final projected = computeAccountBalance(
      openingBalance: card.openingBalance,
      accountId: cardId,
      postings: <Posting>[
        for (final item in cardTransactions)
          ...postingsFor(
            type: item.type,
            status: item.status,
            amount: item.amount,
            accountId: item.accountId,
            counterAccountId: item.counterAccountId,
          ),
      ],
    ).projected;
    final debt = projected.isNegative ? -projected : Money.zero(card.currency);
    final available = card.creditLimit! - debt;
    final future =
        data.transactions
            .where(
              (item) =>
                  item.type == TransactionType.cardPurchase &&
                  item.accountId == cardId &&
                  item.status != TransactionStatus.cancelado &&
                  item.installmentNumber != null &&
                  item.occurredAt.isAfter(closing),
            )
            .map(
              (item) => FutureInstallment(
                description: item.description,
                amount: item.amount,
                date: item.occurredAt,
                number: item.installmentNumber!,
                count: item.installmentCount!,
              ),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return CardStatementSnapshot(
      cardId: card.id,
      cardName: card.name,
      currency: card.currency,
      creditLimit: card.creditLimit!,
      availableLimit: available,
      statement: CardStatement(
        id: statementId,
        periodStart: previousClosing.add(const Duration(days: 1)),
        closingDate: closing,
        dueDate: due,
        status: status,
        total: total,
        paid: paid,
        outstanding: outstanding,
        purchases: [
          for (final item in relevant)
            StatementPurchase(
              id: item.id,
              description: item.description,
              date: item.occurredAt,
              amount: item.amount,
              category: item.category,
              installmentNumber: item.installmentNumber,
              installmentCount: item.installmentCount,
              purchaseTotal: item.purchaseTotal,
            ),
        ],
      ),
      futureInstallments: List.unmodifiable(future),
      paymentAccounts: [
        for (final account in data.accounts)
          if (!account.isCreditCard &&
              !account.isArchived &&
              account.currency == card.currency)
            StatementPaymentAccount(
              id: account.id,
              name: account.name,
              currency: account.currency,
            ),
      ],
    );
  }

  Future<void> pay({
    required CardStatementSnapshot snapshot,
    required StatementPaymentCommand command,
  }) async {
    if (!command.amount.isPositive ||
        command.amount.currency != snapshot.currency) {
      throw const InvalidStatementPaymentException('Pagamento inválido');
    }
    if (command.amount.compareTo(snapshot.statement.outstanding) > 0) {
      throw const InvalidStatementPaymentException(
        'Pagamento maior que o saldo da fatura',
      );
    }
    if (!snapshot.paymentAccounts.any(
      (item) => item.id == command.sourceAccountId,
    )) {
      throw const InvalidStatementPaymentException(
        'Conta de pagamento indisponível',
      );
    }
    await _source.recordPayment(command);
  }

  Money _sum(Iterable<Money> values, Currency currency) =>
      values.fold(Money.zero(currency), (total, value) => total + value);

  DateTime _closingForPurchase(DateTime date, int closingDay) {
    final thisClosing = _dayInMonth(date.year, date.month, closingDay);
    return DateTime(date.year, date.month, date.day).isAfter(thisClosing)
        ? _addMonths(thisClosing, 1, closingDay)
        : thisClosing;
  }

  DateTime _dueForClosing(DateTime closing, int dueDay) {
    final sameMonth = _dayInMonth(closing.year, closing.month, dueDay);
    return sameMonth.isAfter(closing)
        ? sameMonth
        : _addMonths(closing, 1, dueDay);
  }

  DateTime _addMonths(DateTime date, int months, int preferredDay) {
    final raw = date.month - 1 + months;
    final year = date.year + (raw / 12).floor();
    final month = raw % 12 + 1;
    return _dayInMonth(year, month, preferredDay);
  }

  DateTime _dayInMonth(int year, int month, int day) =>
      DateTime(year, month, day.clamp(1, DateTime(year, month + 1, 0).day));

  String _statementId(String cardId, DateTime closing) =>
      '$cardId:${closing.year}-${closing.month.toString().padLeft(2, '0')}-${closing.day.toString().padLeft(2, '0')}';
}
