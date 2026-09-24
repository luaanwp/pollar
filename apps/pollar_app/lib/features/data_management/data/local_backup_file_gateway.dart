import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../application/backup_data_source.dart';
import '../domain/data_backup.dart';

class LocalBackupFileGateway implements BackupFileGateway {
  const LocalBackupFileGateway();

  static const maxBackupBytes = 25 * 1024 * 1024;

  @override
  Future<BackupSaveResult> save(BackupDocument document) async {
    final directory =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final separator = Platform.pathSeparator;
    final path = '${directory.path}$separator${document.fileName}';
    await File(path).writeAsString(document.contents, flush: true);
    return BackupSaveResult(path: path);
  }

  @override
  Future<PickedBackupFile?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    final reportedLength = file.lengthSync() ?? await file.length();
    if (reportedLength != null && reportedLength > maxBackupBytes) {
      throw const BackupValidationException(
        'O backup excede o limite de 25 MB. Escolha um arquivo menor.',
      );
    }
    final bytes = BytesBuilder(copy: false);
    var length = 0;
    await for (final chunk in file.readAsByteStream()) {
      length += chunk.length;
      if (length > maxBackupBytes) {
        throw const BackupValidationException(
          'O backup excede o limite de 25 MB. Escolha um arquivo menor.',
        );
      }
      bytes.add(chunk);
    }
    return PickedBackupFile(
      name: file.name,
      contents: utf8.decode(bytes.takeBytes()),
    );
  }
}
