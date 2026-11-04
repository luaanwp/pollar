import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/updates/data/windows_update_launcher.dart';

const parameters = r'''
param([string]$Archive, [string]$ExpectedHash, [string]$ExpectedVersion,
      [string]$InstallDirectory, [int]$ParentProcessId, [string]$StatusFile)
''';

void main() {
  late Directory work;
  setUp(() async {
    work = await Directory.systemTemp.createTemp('pollar-launch-test-');
  });
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await work.delete(recursive: true);
  });

  Future<Process> prepare(File script, File status) =>
      const WindowsUpdateLauncher(readyTimeout: Duration(seconds: 10)).prepare(
        script: script,
        archive: File('${work.path}/package.zip'),
        expectedHash: 'a' * 64,
        expectedVersion: '1.0.0+1009',
        installDirectory: work.path,
        parentProcessId: pid,
        status: status,
      );

  test(
    'PowerShell executes and reports readiness from the Flutter process',
    () async {
      final script = File('${work.path}/ready.ps1');
      await script.writeAsString(
        parameters +
            r'''
@{phase='ready'} | ConvertTo-Json -Compress | Set-Content -LiteralPath $StatusFile -Encoding UTF8
Start-Sleep -Seconds 20
''',
      );
      final status = File('${work.path}/status.json');
      final child = await prepare(script, status);
      try {
        expect(jsonDecode(await status.readAsString())['phase'], 'ready');
      } finally {
        child.kill();
        await child.exitCode;
      }
    },
    skip: !Platform.isWindows,
  );

  test(
    'early helper failure returns with diagnostics instead of hanging',
    () async {
      final script = File('${work.path}/failed.ps1');
      await script.writeAsString(
        parameters +
            r'''
[Console]::Error.WriteLine('fixture launch failure')
exit 7
''',
      );
      await expectLater(
        prepare(script, File('${work.path}/status.json')),
        throwsStateError,
      );
      final log = File('${work.path}/launcher-error.log');
      for (
        var i = 0;
        i < 20 && (!await log.exists() || await log.length() == 0);
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(await log.readAsString(), contains('fixture launch failure'));
    },
    skip: !Platform.isWindows,
  );

  test('prepared helper survives explicit exit of its Dart parent', () async {
    final script = File('${work.path}/survive.ps1');
    await script.writeAsString(
      parameters +
          r'''
@{phase='ready'} | ConvertTo-Json -Compress | Set-Content -LiteralPath $StatusFile -Encoding UTF8
Wait-Process -Id $ParentProcessId -Timeout 15 -ErrorAction SilentlyContinue
[IO.File]::WriteAllText((Join-Path (Split-Path -Parent $StatusFile) 'survived.txt'), 'yes')
''',
    );
    final launcherUri = File(
      'lib/features/updates/data/windows_update_launcher.dart',
    ).absolute.uri;
    final driver = File('${work.path}/parent.dart');
    await driver.writeAsString(
      'import ${jsonEncode(launcherUri.toString())};\n'
      r'''
import 'dart:io';
Future<void> main(List<String> args) async {
  final root = args.first;
  await const WindowsUpdateLauncher().prepare(
    script: File('$root/survive.ps1'), archive: File('$root/package.zip'),
    expectedHash: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    expectedVersion: '1.0.0+1009', installDirectory: root,
    parentProcessId: pid, status: File('$root/status.json'),
  );
  exit(0);
}
''',
    );
    final sdk = Platform.environment['FLUTTER_ROOT'];
    final dart = sdk != null
        ? '$sdk/bin/cache/dart-sdk/bin/dart.exe'
        : '${File(Platform.resolvedExecutable).parent.parent.parent.parent.path}/dart-sdk/bin/dart.exe';
    final parent = await Process.run(dart, [
      driver.path,
      work.path,
    ]).timeout(const Duration(seconds: 25));
    expect(parent.exitCode, 0, reason: '${parent.stderr}');
    final survived = File('${work.path}/survived.txt');
    for (var i = 0; i < 40 && !await survived.exists(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(await survived.readAsString(), 'yes');
  }, skip: !Platform.isWindows);
}
