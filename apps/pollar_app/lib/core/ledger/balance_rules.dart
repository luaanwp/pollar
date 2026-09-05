/// Centralized financial invariants for how transaction status and type affect
/// balances and reports. These rules are the single source of truth; no feature
/// may re-derive them locally.
///
/// Approved balance rules:
/// - Previsto / Pendente: do not affect the confirmed balance; affect projected.
/// - Compensado / Conciliado: affect both confirmed and projected.
/// - Cancelado (and deleted/archived records): affect no balance.
///
///   confirmedBalance = openingBalance + cleared/reconciled postings
///   projectedBalance = confirmedBalance + planned/pending postings
///
/// Transfers move both linked accounts and never count as income or expense.
/// Card purchases move the card (debt) account, not the funding bank account,
/// and DO count as an expense for reports. Paying a card statement moves the
/// bank account and the card debt without counting as a new expense.
library;

/// Lifecycle status of a transaction, in the fixed pt-BR vocabulary.
enum TransactionStatus {
  previsto,
  pendente,
  compensado,
  conciliado,
  cancelado;

  /// Whether postings with this status contribute to the confirmed balance.
  bool get affectsConfirmed =>
      this == TransactionStatus.compensado ||
      this == TransactionStatus.conciliado;

  /// Whether postings with this status contribute to the projected balance.
  /// Everything that affects the confirmed balance also affects the projected
  /// one; planned and pending additionally affect only the projected balance.
  bool get affectsProjected =>
      affectsConfirmed ||
      this == TransactionStatus.previsto ||
      this == TransactionStatus.pendente;
}

/// The kind of a transaction, which determines its account postings and whether
/// it appears in income/expense reports.
enum TransactionType {
  income,
  expense,
  transfer,
  cardPurchase,
  cardStatementPayment;

  /// Whether this type is counted in income/expense report totals.
  ///
  /// Transfers and card-statement payments are movements between the user's own
  /// accounts and must be excluded to avoid double counting; a card purchase is
  /// the real expense and is included.
  bool get countsAsIncomeOrExpense =>
      this == TransactionType.income ||
      this == TransactionType.expense ||
      this == TransactionType.cardPurchase;
}
