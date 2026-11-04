import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_update_gateway.dart';
import '../domain/app_release.dart';

final appUpdateGatewayProvider = Provider<AppUpdateGateway?>((ref) => null);
final appUpdateProvider = NotifierProvider<AppUpdateController, AppUpdateState>(
  AppUpdateController.new,
);

enum AppUpdatePhase {
  idle,
  checking,
  current,
  available,
  downloading,
  ready,
  installing,
  permissionRequired,
  error,
}

class AppUpdateState {
  const AppUpdateState({
    this.phase = AppUpdatePhase.idle,
    this.release,
    this.file,
    this.progress = 0,
    this.message,
  });
  final AppUpdatePhase phase;
  final AppRelease? release;
  final File? file;
  final double progress;
  final String? message;
  bool get busy =>
      phase == AppUpdatePhase.checking ||
      phase == AppUpdatePhase.downloading ||
      phase == AppUpdatePhase.installing;
}

class AppUpdateController extends Notifier<AppUpdateState> {
  DateTime? _lastCheck;

  @override
  AppUpdateState build() => const AppUpdateState();

  Future<void> check({bool force = false}) async {
    final gateway = ref.read(appUpdateGatewayProvider);
    if (gateway == null ||
        !gateway.supported ||
        state.busy ||
        state.file != null) {
      return;
    }
    if (!force &&
        _lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < const Duration(hours: 6)) {
      return;
    }
    final previous = state;
    _lastCheck = DateTime.now();
    state = AppUpdateState(
      phase: AppUpdatePhase.checking,
      release: previous.release,
    );
    try {
      final release = await gateway.check();
      state = AppUpdateState(
        phase: release == null
            ? AppUpdatePhase.current
            : AppUpdatePhase.available,
        release: release,
      );
    } catch (_) {
      // A failed background check never blocks login or financial operations.
      state = AppUpdateState(
        phase: AppUpdatePhase.error,
        release: previous.release,
        message: 'Não foi possível consultar novas versões agora. Tente novamente mais tarde.',
      );
    }
  }

  Future<void> download() async {
    final gateway = ref.read(appUpdateGatewayProvider);
    final release = state.release;
    if (gateway == null || release == null || state.busy) return;
    state = AppUpdateState(phase: AppUpdatePhase.downloading, release: release);
    try {
      final file = await gateway.download(release, (progress) {
        state = AppUpdateState(
          phase: AppUpdatePhase.downloading,
          release: release,
          progress: progress,
        );
      });
      state = AppUpdateState(
        phase: AppUpdatePhase.ready,
        release: release,
        file: file,
        progress: 1,
      );
    } catch (_) {
      state = AppUpdateState(
        phase: AppUpdatePhase.error,
        release: release,
        message: 'Não foi possível baixar uma atualização válida. Seus dados continuam salvos. Tente novamente.',
      );
    }
  }

  Future<void> install() async {
    final gateway = ref.read(appUpdateGatewayProvider);
    final release = state.release;
    final file = state.file;
    if (gateway == null || release == null || file == null || state.busy) {
      return;
    }
    state = AppUpdateState(
      phase: AppUpdatePhase.installing,
      release: release,
      file: file,
    );
    try {
      final result = await gateway.install(release, file);
      state = AppUpdateState(
        phase: result == UpdateInstallResult.permissionRequired
            ? AppUpdatePhase.permissionRequired
            : AppUpdatePhase.ready,
        release: release,
        file: file,
        message: result == UpdateInstallResult.permissionRequired
            ? 'Permita instalar atualizações do Pollar nas configurações abertas e depois toque em Instalar atualização.'
            : 'Confirme a instalação na janela do Android. Se cancelar, você pode tentar novamente.',
      );
    } catch (_) {
      state = AppUpdateState(
        phase: AppUpdatePhase.error,
        release: release,
        message: 'Não foi possível iniciar a instalação. O Pollar continua na versão atual. Tente baixar novamente.',
      );
    }
  }
}
