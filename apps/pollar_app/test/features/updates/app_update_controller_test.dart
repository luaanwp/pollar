import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/updates/application/app_update_gateway.dart';
import 'package:pollar_app/features/updates/domain/app_release.dart';
import 'package:pollar_app/features/updates/presentation/app_update_controller.dart';

final release = AppRelease(
  version: const AppVersion('1.0.0', 1001),
  platform: UpdatePlatform.android,
  downloadUrl: Uri.https('github.com', '/test'),
  sha256: 'a' * 64,
  bytes: 20,
);

class FakeUpdates implements AppUpdateGateway {
  int checks = 0;
  int downloads = 0;
  int installs = 0;
  bool fail = false;
  bool permission = false;
  bool installError = false;
  Completer<File>? pending;
  @override
  AppVersion get installed => const AppVersion('1.0.0', 10);
  @override
  bool get supported => true;
  @override
  Future<AppRelease?> check() async {
    checks++;
    if (fail) throw const SocketException('offline');
    return release;
  }

  @override
  Future<File> download(
    AppRelease release,
    void Function(double) onProgress,
  ) async {
    downloads++;
    if (fail) throw const FormatException('corrupt');
    onProgress(.5);
    return pending == null ? File('verified.apk') : await pending!.future;
  }

  @override
  Future<UpdateInstallResult> install(AppRelease release, File file) async {
    installs++;
    if (installError) throw StateError('installer unavailable');
    return permission
        ? UpdateInstallResult.permissionRequired
        : UpdateInstallResult.installerOpened;
  }
}

void main() {
  late FakeUpdates gateway;
  late ProviderContainer container;
  setUp(() {
    gateway = FakeUpdates();
    container = ProviderContainer(
      overrides: [appUpdateGatewayProvider.overrideWithValue(gateway)],
    );
  });
  tearDown(() => container.dispose());
  test(
    'failed installation can download again instead of retaining a bad package',
    () async {
      final controller = container.read(appUpdateProvider.notifier);
      await controller.check();
      await controller.download();
      gateway.installError = true;
      await controller.install();
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.error);
      expect(container.read(appUpdateProvider).file, isNull);
      await controller.download();
      expect(gateway.downloads, 2);
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.ready);
    },
  );
  test(
    'check is throttled, explicit checks retry, availability never installs',
    () async {
      final controller = container.read(appUpdateProvider.notifier);
      await controller.check();
      await controller.check();
      expect(gateway.checks, 1);
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.available);
      expect(gateway.installs, 0);
      await controller.check(force: true);
      expect(gateway.checks, 2);
    },
  );
  test(
    'duplicate downloads are ignored and install needs verified file',
    () async {
      final controller = container.read(appUpdateProvider.notifier);
      await controller.check();
      await controller.install();
      expect(gateway.installs, 0);
      gateway.pending = Completer<File>();
      final download = controller.download();
      await controller.download();
      expect(gateway.downloads, 1);
      expect(container.read(appUpdateProvider).progress, .5);
      gateway.pending!.complete(File('verified.apk'));
      await download;
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.ready);
      await controller.check(force: true);
      expect(gateway.checks, 1);
    },
  );
  test(
    'offline/corrupt package allows retry and never opens installer',
    () async {
      final controller = container.read(appUpdateProvider.notifier);
      gateway.fail = true;
      await controller.check();
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.error);
      gateway.fail = false;
      await controller.check(force: true);
      gateway.fail = true;
      await controller.download();
      expect(container.read(appUpdateProvider).file, isNull);
      await controller.install();
      expect(gateway.installs, 0);
      gateway.fail = false;
      await controller.download();
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.ready);
    },
  );
  test(
    'Android permission and canceled installer retain package for retry',
    () async {
      final controller = container.read(appUpdateProvider.notifier);
      await controller.check();
      await controller.download();
      gateway.permission = true;
      await controller.install();
      expect(
        container.read(appUpdateProvider).phase,
        AppUpdatePhase.permissionRequired,
      );
      gateway.permission = false;
      await controller.install();
      expect(container.read(appUpdateProvider).phase, AppUpdatePhase.ready);
      expect(gateway.installs, 2);
      expect(gateway.downloads, 1);
    },
  );
}
