import '../../../core/money/money.dart';

class WealthGoal {
  WealthGoal({
    required this.id,
    required String name,
    required this.target,
    required this.saved,
    required this.createdAt,
    this.deadline,
    this.priority = false,
    this.active = true,
  }) : name = name.trim() {
    if (id.trim().isEmpty || this.name.isEmpty) {
      throw ArgumentError('Goal identity cannot be empty.');
    }
    if (!target.isPositive || saved.isNegative) {
      throw ArgumentError('Goal amounts must be positive magnitudes.');
    }
    if (target.currency != saved.currency) {
      throw ArgumentError('Goal amounts must use the same currency.');
    }
  }

  final String id;
  final String name;
  final Money target;
  final Money saved;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool priority;
  final bool active;

  bool get completed => saved.compareTo(target) >= 0;

  WealthGoal copyWith({
    String? name,
    Money? target,
    Money? saved,
    DateTime? deadline,
    bool clearDeadline = false,
    bool? priority,
    bool? active,
  }) => WealthGoal(
    id: id,
    name: name ?? this.name,
    target: target ?? this.target,
    saved: saved ?? this.saved,
    createdAt: createdAt,
    deadline: clearDeadline ? null : deadline ?? this.deadline,
    priority: priority ?? this.priority,
    active: active ?? this.active,
  );
}
