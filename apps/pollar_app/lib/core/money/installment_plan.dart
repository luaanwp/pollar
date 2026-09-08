import 'money.dart';

/// Amount-only schedule, without billing dates or interest. Earliest
/// installments receive one extra minor unit until the remainder is exhausted.
abstract final class InstallmentPlan {
  static List<Money> split(Money total, int count) {
    if (count < 1 || count > 360) {
      throw RangeError.range(count, 1, 360, 'count');
    }
    if (total.isNegative) {
      throw ArgumentError.value(total, 'total', 'Must be non-negative');
    }
    final base = total.minorUnits ~/ count;
    final remainder = total.minorUnits % count;
    return List.unmodifiable([
      for (var i = 0; i < count; i++)
        Money(
          minorUnits: base + (i < remainder ? 1 : 0),
          currency: total.currency,
        ),
    ]);
  }
}
