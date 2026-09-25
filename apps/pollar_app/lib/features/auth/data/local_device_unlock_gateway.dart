import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../application/device_unlock_gateway.dart';

class LocalDeviceUnlockGateway implements DeviceUnlockGateway {
  LocalDeviceUnlockGateway([LocalAuthentication? authentication])
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> isSupported() async {
    try {
      return await _authentication.isDeviceSupported();
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    try {
      return await _authentication.authenticate(
        localizedReason: 'Desbloqueie o Pollar neste dispositivo.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    } on Exception {
      return false;
    }
  }
}
