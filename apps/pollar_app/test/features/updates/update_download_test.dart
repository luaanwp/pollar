import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/updates/data/github_update_gateway.dart';
import 'package:pollar_app/features/updates/domain/app_release.dart';

void main() {
  late Directory directory;
  late HttpServer server;
  final bytes = List<int>.generate(4096, (i) => i % 256);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pollar-download-test-');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });
  tearDown(() async {
    await server.close(force: true);
    await directory.delete(recursive: true);
  });
  AppRelease asset({String? hash, int? size}) => AppRelease(
    version: const AppVersion('1.0.0', 1001),
    platform: UpdatePlatform.android,
    downloadUrl: Uri.parse('http://127.0.0.1:${server.port}/app.apk'),
    sha256: hash ?? sha256.convert(bytes).toString(),
    bytes: size ?? bytes.length,
  );
  test(
    'streams actual bytes, verifies digest and atomically finishes package',
    () async {
      server.listen((request) async {
        request.response.add(bytes);
        await request.response.close();
      });
      final progress = <double>[];
      final gateway = GitHubUpdateGateway(downloadDirectory: directory);
      final file = await gateway.download(asset(), progress.add);
      expect(await file.readAsBytes(), bytes);
      expect(progress.last, 1);
      expect(directory.listSync().whereType<File>().length, 1);
    },
  );
  test('corruption is rejected and partial file is removed', () async {
    server.listen((request) async {
      request.response.add(bytes);
      await request.response.close();
    });
    final gateway = GitHubUpdateGateway(downloadDirectory: directory);
    await expectLater(
      gateway.download(asset(hash: '0' * 64), (_) {}),
      throwsFormatException,
    );
    expect(directory.listSync(), isEmpty);
  });
  test('truncated package is rejected and never becomes installable', () async {
    server.listen((request) async {
      request.response.add(bytes.take(50).toList());
      await request.response.close();
    });
    final gateway = GitHubUpdateGateway(downloadDirectory: directory);
    await expectLater(gateway.download(asset(), (_) {}), throwsFormatException);
    expect(directory.listSync(), isEmpty);
  });
}
