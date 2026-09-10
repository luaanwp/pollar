import 'package:meta/meta.dart';

import '../../../core/money/money.dart';

@immutable
class Budget {
  factory Budget({
    required String id,
    required String category,
    required DateTime month,
    required Money limit,
    int alertThreshold = 85,
    bool active = true,
  }) {
    final normalizedId = id.trim();
    final normalizedCategory = category.trim();
    if (normalizedId.isEmpty) throw ArgumentError('Budget id cannot be empty');
    if (normalizedCategory.isEmpty) {
      throw ArgumentError('Budget category cannot be empty');
    }
    if (!limit.isPositive) throw ArgumentError('Budget limit must be positive');
    if (alertThreshold < 1 || alertThreshold > 100) {
      throw RangeError.range(alertThreshold, 1, 100, 'alertThreshold');
    }
    return Budget._(
      id: normalizedId,
      category: normalizedCategory,
      month: DateTime(month.year, month.month),
      limit: limit,
      alertThreshold: alertThreshold,
      active: active,
    );
  }

  const Budget._({
    required this.id,
    required this.category,
    required this.month,
    required this.limit,
    required this.alertThreshold,
    required this.active,
  });

  final String id;
  final String category;
  final DateTime month;
  final Money limit;
  final int alertThreshold;
  final bool active;

  Budget copyWith({bool? active}) => Budget(
    id: id,
    category: category,
    month: month,
    limit: limit,
    alertThreshold: alertThreshold,
    active: active ?? this.active,
  );
}
