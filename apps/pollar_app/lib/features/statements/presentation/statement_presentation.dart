import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/presentation/status_badge.dart';
import '../domain/card_statement.dart';

extension CardStatementStatusPresentation on CardStatementStatus {
  String get label => switch (this) {
    CardStatementStatus.open => 'Aberta',
    CardStatementStatus.closed => 'Fechada',
    CardStatementStatus.partiallyPaid => 'Parcialmente paga',
    CardStatementStatus.paid => 'Paga',
    CardStatementStatus.overdue => 'Vencida',
  };

  PollarStatusTone get tone => switch (this) {
    CardStatementStatus.open => PollarStatusTone.info,
    CardStatementStatus.closed => PollarStatusTone.neutral,
    CardStatementStatus.partiallyPaid => PollarStatusTone.warning,
    CardStatementStatus.paid => PollarStatusTone.success,
    CardStatementStatus.overdue => PollarStatusTone.danger,
  };

  IconData get icon => switch (this) {
    CardStatementStatus.open => LucideIcons.clock3,
    CardStatementStatus.closed => LucideIcons.lock,
    CardStatementStatus.partiallyPaid => LucideIcons.clock3,
    CardStatementStatus.paid => LucideIcons.circleCheck,
    CardStatementStatus.overdue => LucideIcons.circleAlert,
  };
}
