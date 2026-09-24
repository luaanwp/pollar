import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../application/report_exporter.dart';

class LocalReportExporter implements ReportExporter {
  const LocalReportExporter();

  @override
  Future<ReportExportResult> export(ReportExportDocument document) async {
    final directory =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final csvFile = File(
      '${directory.path}${Platform.pathSeparator}${document.fileName}',
    );
    final checksumFile = File('${csvFile.path}.sha256');
    await csvFile.writeAsString(document.csv, flush: true);
    await checksumFile.writeAsString(
      '${document.sha256}  ${document.fileName}\n',
      flush: true,
    );
    return ReportExportResult(
      csvPath: csvFile.path,
      checksumPath: checksumFile.path,
    );
  }
}
