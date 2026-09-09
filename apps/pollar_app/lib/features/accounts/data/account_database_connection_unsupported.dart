import 'package:drift/drift.dart';

QueryExecutor openAccountDatabaseConnection() => LazyDatabase(
  () => throw UnsupportedError(
    'Local account persistence is not configured for this platform.',
  ),
);
