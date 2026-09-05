import 'package:meta/meta.dart';

import '../money/money.dart';
import 'posting.dart';

/// The two balances Pollar tracks for an account.
///
/// [confirmed] counts only cleared/reconciled postings; [projected] additionally
/// includes planned/pending postings. See `balance_rules.dart` for the rules.
@immutable
class AccountBalance {
  const AccountBalance({required this.confirmed, required this.projected});

  final Money confirmed;
  final Money projected;

  @override
  bool operator ==(Object other) =>
      other is AccountBalance &&
      other.confirmed == confirmed &&
      other.projected == projected;

  @override
  int get hashCode => Object.hash(confirmed, projected);

  @override
  String toString() =>
      'AccountBalance(confirmed: $confirmed, projected: $projected)';
}

/// Derives an account's confirmed and projected balances from its opening
/// balance and the postings that touch it. Balances are always derived here,
/// never stored as an independent authoritative field.
AccountBalance computeAccountBalance({
  required String accountId,
  required Money openingBalance,
  required Iterable<Posting> postings,
}) {
  var confirmed = openingBalance;
  var projected = openingBalance;

  for (final posting in postings) {
    if (posting.accountId != accountId) continue;
    if (posting.status.affectsConfirmed) {
      confirmed += posting.signedAmount;
    }
    if (posting.status.affectsProjected) {
      projected += posting.signedAmount;
    }
  }

  return AccountBalance(confirmed: confirmed, projected: projected);
}
