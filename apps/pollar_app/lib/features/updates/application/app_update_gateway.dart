import 'dart:io';

import '../domain/app_release.dart';

enum UpdateInstallResult { installerOpened, permissionRequired }

abstract interface class AppUpdateGateway {
  AppVersion get installed;
  bool get supported;
  Future<AppRelease?> check();
  Future<File> download(AppRelease release, void Function(double) onProgress);
  Future<UpdateInstallResult> install(AppRelease release, File file);
}
