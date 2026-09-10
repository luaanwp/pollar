import '../../../core/money/money.dart';

enum WealthAssetKind { property, vehicle, investment, valuable, other }

class WealthAsset {
  WealthAsset({
    required this.id,
    required String name,
    required this.kind,
    required this.currentValue,
    required this.valuedAt,
    this.active = true,
  }) : name = name.trim() {
    if (id.trim().isEmpty || this.name.isEmpty) {
      throw ArgumentError('Asset identity cannot be empty.');
    }
    if (!currentValue.isPositive) {
      throw ArgumentError('Asset value must be positive.');
    }
  }

  final String id;
  final String name;
  final WealthAssetKind kind;
  final Money currentValue;
  final DateTime valuedAt;
  final bool active;

  WealthAsset copyWith({
    Money? currentValue,
    DateTime? valuedAt,
    bool? active,
  }) => WealthAsset(
    id: id,
    name: name,
    kind: kind,
    currentValue: currentValue ?? this.currentValue,
    valuedAt: valuedAt ?? this.valuedAt,
    active: active ?? this.active,
  );
}
