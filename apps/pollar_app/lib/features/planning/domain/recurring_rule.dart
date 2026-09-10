import 'package:meta/meta.dart';

import '../../../core/money/money.dart';

enum RecurringKind { income, expense, subscription }

enum RecurrenceFrequency { weekly, monthly, yearly }

@immutable
class RecurringRule {
  factory RecurringRule({
    required String id,
    required String description,
    required RecurringKind kind,
    required RecurrenceFrequency frequency,
    required Money amount,
    required String accountId,
    required DateTime firstDueDate,
    String? category,
    int remindDaysBefore = 3,
    bool active = true,
  }) {
    final normalizedId = id.trim();
    final normalizedDescription = description.trim();
    final normalizedAccount = accountId.trim();
    if (normalizedId.isEmpty) throw ArgumentError('Rule id cannot be empty');
    if (normalizedDescription.isEmpty) {
      throw ArgumentError('Rule description cannot be empty');
    }
    if (normalizedAccount.isEmpty) {
      throw ArgumentError('Rule account cannot be empty');
    }
    if (!amount.isPositive) throw ArgumentError('Rule amount must be positive');
    if (remindDaysBefore < 0 || remindDaysBefore > 30) {
      throw RangeError.range(remindDaysBefore, 0, 30, 'remindDaysBefore');
    }
    return RecurringRule._(
      id: normalizedId,
      description: normalizedDescription,
      kind: kind,
      frequency: frequency,
      amount: amount,
      accountId: normalizedAccount,
      category: _optional(category),
      firstDueDate: DateTime(
        firstDueDate.year,
        firstDueDate.month,
        firstDueDate.day,
      ),
      remindDaysBefore: remindDaysBefore,
      active: active,
    );
  }

  const RecurringRule._({
    required this.id,
    required this.description,
    required this.kind,
    required this.frequency,
    required this.amount,
    required this.accountId,
    required this.category,
    required this.firstDueDate,
    required this.remindDaysBefore,
    required this.active,
  });

  final String id;
  final String description;
  final RecurringKind kind;
  final RecurrenceFrequency frequency;
  final Money amount;
  final String accountId;
  final String? category;
  final DateTime firstDueDate;
  final int remindDaysBefore;
  final bool active;

  bool get isSubscription => kind == RecurringKind.subscription;

  RecurringRule copyWith({bool? active}) => RecurringRule(
    id: id,
    description: description,
    kind: kind,
    frequency: frequency,
    amount: amount,
    accountId: accountId,
    category: category,
    firstDueDate: firstDueDate,
    remindDaysBefore: remindDaysBefore,
    active: active ?? this.active,
  );

  static String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
