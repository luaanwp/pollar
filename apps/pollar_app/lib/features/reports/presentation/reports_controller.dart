import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/application/financial_data_revision.dart';
import '../application/report_data_source.dart';
import '../application/report_export_service.dart';
import '../application/report_exporter.dart';
import '../application/report_service.dart';
import '../domain/report_snapshot.dart';

final reportDataSourceProvider = Provider<ReportDataSource>((ref) {
  throw StateError('ReportDataSource was not configured');
});

final reportExporterProvider = Provider<ReportExporter>((ref) {
  throw StateError('ReportExporter was not configured');
});

final reportClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(ref.watch(reportDataSourceProvider)),
);

final reportExportServiceProvider = Provider<ReportExportService>(
  (ref) => const ReportExportService(),
);

final reportsProvider =
    AsyncNotifierProvider<ReportsController, ReportSnapshot>(
      ReportsController.new,
    );

class ReportsController extends AsyncNotifier<ReportSnapshot> {
  @override
  Future<ReportSnapshot> build() {
    ref.watch(financialDataRevisionProvider);
    return ref
        .watch(reportServiceProvider)
        .load(now: ref.watch(reportClockProvider)());
  }

  void retry() => ref.invalidateSelf();

  Future<ReportExportResult> export(ReportCurrencySnapshot report) {
    final document = ref.read(reportExportServiceProvider).build(report);
    return ref.read(reportExporterProvider).export(document);
  }
}
