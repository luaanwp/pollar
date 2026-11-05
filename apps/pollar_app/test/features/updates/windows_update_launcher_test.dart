@Tags(['windows-process'])
@Timeout(Duration(minutes: 3))
library;

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
  final children = <Process>[];
  setUp(() async {
    work = await Directory.systemTemp.createTemp('pollar-launch-test-');
  });
  tearDown(() async {
    for (final child in children) {
      child.kill();
      await child.exitCode.timeout(const Duration(seconds: 10));
    }
    children.clear();
    final temporaryRoot = await Directory.systemTemp.resolveSymbolicLinks();
    final target = await work.resolveSymbolicLinks();
    if (!target.toLowerCase().startsWith(
      '$temporaryRoot${Platform.pathSeparator}pollar-launch-test-'
          .toLowerCase(),
    )) {
      throw StateError('Refusing cleanup outside the native test directory');
    }
    final elapsed = Stopwatch()..start();
    while (true) {
      try {
        await work.delete(recursive: true);
        break;
      } on FileSystemException {
        // Windows can briefly retain the process pipes after exitCode resolves.
        if (elapsed.elapsed >= const Duration(seconds: 10)) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  });

  Future<Process> prepare(File script, File status) async {
    // Use the application's real preparation deadline, including cold startup.
    final child = await const WindowsUpdateLauncher().prepare(
      script: script,
      archive: File('${work.path}/package.zip'),
      expectedHash: 'a' * 64,
      expectedVersion: '1.0.0+1009',
      installDirectory: work.path,
      parentProcessId: pid,
      status: status,
    );
    children.add(child);
    return child;
  }

  test(
    'PowerShell executes and reports readiness from the Flutter process',
    () async {
      final script = File('${work.path}/ready.ps1');
      await script.writeAsString(
        parameters +
            r'''
@{phase='ready'} | ConvertTo-Json -Compress | Set-Content -LiteralPath $StatusFile -Encoding UTF8
Start-Sleep -Seconds 90
''',
      );
      final status = File('${work.path}/status.json');
      final child = await prepare(script, status);
      try {
        expect(jsonDecode(await status.readAsString())['phase'], 'ready');
      } finally {
        child.kill();
        await child.exitCode.timeout(const Duration(seconds: 10));
        children.remove(child);
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
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'reason',
            'Update helper exited before preparation',
          ),
        ),
      );
      final log = File('${work.path}/launcher-error.log');
      final elapsed = Stopwatch()..start();
      while (elapsed.elapsed < const Duration(seconds: 10) &&
          (!await log.exists() || await log.length() == 0)) {
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
    final parent = await Process.start(dart, [driver.path, work.path]);
    children.add(parent);
    final stdout = parent.stdout.transform(utf8.decoder).join();
    final stderr = parent.stderr.transform(utf8.decoder).join();
    final code = await parent.exitCode.timeout(const Duration(seconds: 90));
    children.remove(parent);
    final output = await Future.wait([stdout, stderr])
        .timeout(const Duration(seconds: 10));
    expect(code, 0, reason: output.join('\n'));
    final survived = File('${work.path}/survived.txt');
    final elapsed = Stopwatch()..start();
    while (elapsed.elapsed < const Duration(seconds: 10) &&
        !await survived.exists()) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(await survived.readAsString(), 'yes');
  }, skip: !Platform.isWindows);
}
