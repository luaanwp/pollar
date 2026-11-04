import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../application/app_update_gateway.dart';
import '../domain/app_release.dart';

class GitHubUpdateGateway implements AppUpdateGateway {
  GitHubUpdateGateway({this.beforeRestart, this.downloadDirectory});

  final Future<void> Function()? beforeRestart;
  final Directory? downloadDirectory;
  static const _channel = MethodChannel('com.pollar/app_updates');
  static final _api = Uri.https(
    'api.github.com',
    '/repos/luaanwp/pollar/releases/latest',
  );

  @override
  AppVersion get installed => AppVersion(
    const String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: '1.0.0'),
    int.tryParse(const String.fromEnvironment('FLUTTER_BUILD_NUMBER')) ?? 0,
  );

  @override
  bool get supported => Platform.isAndroid || Platform.isWindows;

  UpdatePlatform get _platform =>
      Platform.isAndroid ? UpdatePlatform.android : UpdatePlatform.windows;

  HttpClient _client() => HttpClient()
    ..connectionTimeout = const Duration(seconds: 20)
    ..userAgent = 'Pollar/${installed.toString()}';

  @override
  Future<AppRelease?> check() async {
    if (!supported) return null;
    final client = _client();
    try {
      final request = await client
          .getUrl(_api)
          .timeout(const Duration(seconds: 20));
      request.headers.set('Accept', 'application/vnd.github+json');
      request.headers.set('X-GitHub-Api-Version', '2022-11-28');
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw const HttpException('Update check failed');
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 20))) {
        bytes.addAll(chunk);
        if (bytes.length > 1024 * 1024) {
          throw const FormatException('Release too large');
        }
      }
      return AppRelease.fromGitHub(
        jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
        installed,
        _platform,
      );
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<File> download(
    AppRelease release,
    void Function(double) onProgress,
  ) async {
    final directory =
        downloadDirectory ??
        Directory('${(await getTemporaryDirectory()).path}/pollar-updates');
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}/${release.version}-${release.platform.assetName}',
    );
    final partial = File('${file.path}.part');
    final client = _client();
    try {
      final request = await client
          .getUrl(release.downloadUrl)
          .timeout(const Duration(seconds: 20));
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200) {
        throw const HttpException('Download failed');
      }
      var received = 0;
      final sink = partial.openWrite();
      try {
        await for (final chunk in response.timeout(
          const Duration(seconds: 30),
        )) {
          received += chunk.length;
          if (received > release.bytes) {
            throw const FormatException('Unexpected download size');
          }
          sink.add(chunk);
          onProgress(received / release.bytes);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if (received != release.bytes ||
          (await sha256.bind(partial.openRead()).first).toString() !=
              release.sha256) {
        throw const FormatException('Update integrity check failed');
      }
      if (await file.exists()) await file.delete();
      return await partial.rename(file.path);
    } finally {
      client.close(force: true);
      if (await partial.exists()) await partial.delete();
    }
  }

  @override
  Future<UpdateInstallResult> install(AppRelease release, File file) async {
    if (release.version.compareTo(installed) <= 0 ||
        await file.length() != release.bytes ||
        (await sha256.bind(file.openRead()).first).toString() !=
            release.sha256) {
      throw const FormatException('Invalid installation package');
    }
    if (Platform.isAndroid) {
      final result = await _channel.invokeMethod<String>('installUpdate', {
        'path': file.path,
      });
      return result == 'permissionRequired'
          ? UpdateInstallResult.permissionRequired
          : UpdateInstallResult.installerOpened;
    }
    if (!Platform.isWindows) {
      throw UnsupportedError('Unsupported update platform');
    }
    final work = await Directory(
      '${file.parent.path}/install-${DateTime.now().microsecondsSinceEpoch}',
    ).create();
    final script = File('${work.path}/pollar-update.ps1');
    await script.writeAsString(
      await rootBundle.loadString('assets/update/pollar-update.ps1'),
    );
    final status = File('${work.path}/status.json');
    final executable = File(Platform.resolvedExecutable);
    final systemRoot = Platform.environment['SystemRoot'];
    if (systemRoot == null) throw StateError('Windows directory unavailable');
    await Process.start(
      '$systemRoot/System32/WindowsPowerShell/v1.0/powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-WindowStyle',
        'Hidden',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        script.path,
        '-Archive',
        file.path,
        '-ExpectedHash',
        release.sha256,
        '-ExpectedVersion',
        release.version.toString(),
        '-InstallDirectory',
        executable.parent.path,
        '-ParentProcessId',
        '$pid',
        '-StatusFile',
        status.path,
      ],
      mode: ProcessStartMode.detached,
    );
    for (var i = 0; i < 120; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!await status.exists()) continue;
      final result =
          jsonDecode(await status.readAsString()) as Map<String, dynamic>;
      if (result['phase'] != 'ready') {
        throw StateError('Update preparation failed');
      }
      await beforeRestart?.call();
      exit(0);
    }
    throw TimeoutException('Update preparation timed out');
  }
}
