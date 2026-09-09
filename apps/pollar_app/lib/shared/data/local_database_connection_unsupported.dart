import 'package:drift/drift.dart';

QueryExecutor openLocalDatabaseConnection() => LazyDatabase(
  () => throw UnsupportedError(
    'Local persistence is not configured for this platform.',
  ),
);
