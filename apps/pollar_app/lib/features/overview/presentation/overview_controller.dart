import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/application/financial_data_revision.dart';
import '../application/overview_data_source.dart';
import '../application/overview_service.dart';
import '../domain/overview_snapshot.dart';

final overviewDataSourceProvider = Provider<OverviewDataSource>((ref) {
  throw StateError('OverviewDataSource was not configured');
});

final overviewClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final overviewServiceProvider = Provider<OverviewService>(
  (ref) => OverviewService(ref.watch(overviewDataSourceProvider)),
);

final overviewProvider =
    AsyncNotifierProvider<OverviewController, OverviewSnapshot>(
      OverviewController.new,
    );

class OverviewController extends AsyncNotifier<OverviewSnapshot> {
  @override
  Future<OverviewSnapshot> build() {
    ref.watch(financialDataRevisionProvider);
    return ref
        .watch(overviewServiceProvider)
        .load(now: ref.watch(overviewClockProvider)());
  }

  void retry() => ref.invalidateSelf();
}
