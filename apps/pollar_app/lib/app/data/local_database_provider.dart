import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/local_database.dart';
import '../../shared/data/local_database_connection.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final database = LocalDatabase(openLocalDatabaseConnection());
  ref.onDispose(database.close);
  return database;
});
