class ReportExportDocument {
  const ReportExportDocument({
    required this.fileName,
    required this.csv,
    required this.sha256,
  });

  final String fileName;
  final String csv;
  final String sha256;
}

class ReportExportResult {
  const ReportExportResult({required this.csvPath, required this.checksumPath});

  final String csvPath;
  final String checksumPath;
}

abstract interface class ReportExporter {
  Future<ReportExportResult> export(ReportExportDocument document);
}
