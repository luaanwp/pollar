import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

QueryExecutor openAccountDatabaseConnection() => LazyDatabase(() async {
  final directory = await getApplicationSupportDirectory();
  final file = File('${directory.path}${Platform.pathSeparator}pollar.sqlite');
  return NativeDatabase.createInBackground(file);
});
