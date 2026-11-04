import 'dart:convert';
import 'dart:io';

/// Starts preflight with normal process semantics and a hidden window.
/// Detached modes exited before reaching the script in the native Windows test.
/// Drain its pipes; explicit exit(0) later leaves the helper alive.
class WindowsUpdateLauncher {
  const WindowsUpdateLauncher({
    this.readyTimeout = const Duration(seconds: 60),
  });

  final Duration readyTimeout;

  Future<Process> prepare({
    required File script,
    required File archive,
    required String expectedHash,
    required String expectedVersion,
    required String installDirectory,
    required int parentProcessId,
    required File status,
  }) async {
    final systemRoot = Platform.environment['SystemRoot'];
    if (systemRoot == null) throw StateError('Windows directory unavailable');
    final process = await Process.start(
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
        archive.path,
        '-ExpectedHash',
        expectedHash,
        '-ExpectedVersion',
        expectedVersion,
        '-InstallDirectory',
        installDirectory,
        '-ParentProcessId',
        '$parentProcessId',
        '-StatusFile',
        status.path,
      ],
      mode: ProcessStartMode.normal,
    ).timeout(const Duration(seconds: 20));
    process.stdin.close().ignore();
    process.stdout.drain<void>().ignore();
    process.stderr
        .pipe(File('${status.parent.path}/launcher-error.log').openWrite())
        .ignore();
    var exited = false;
    process.exitCode.then<void>((_) {
      exited = true;
    }).ignore();
    final elapsed = Stopwatch()..start();
    try {
      while (elapsed.elapsed < readyTimeout) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (await status.exists()) {
          final result =
              jsonDecode(await status.readAsString()) as Map<String, dynamic>;
          if (result['phase'] != 'ready') {
            throw StateError('Update preparation failed');
          }
          return process;
        }
        if (exited) throw StateError('Update helper exited before preparation');
      }
      throw StateError('Update preparation timed out');
    } catch (_) {
      process.kill();
      rethrow;
    }
  }
}
