import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_gateway.dart';
import '../application/device_unlock_gateway.dart';
import '../data/local_device_unlock_gateway.dart';
import '../domain/auth_session.dart';

final authGatewayProvider = Provider<AuthGateway>(
  (ref) => const UnconfiguredAuthGateway(),
);

final authSessionProvider = StreamProvider<AuthSession?>((ref) {
  return ref.watch(authGatewayProvider).sessionChanges();
});

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref.watch(authGatewayProvider)),
);

final deviceUnlockGatewayProvider = Provider<DeviceUnlockGateway>(
  (ref) => LocalDeviceUnlockGateway(),
);

final authenticatorUnlockedProvider =
    NotifierProvider<AuthenticatorUnlocked, bool>(AuthenticatorUnlocked.new);

class AuthenticatorUnlocked extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}

class AuthController {
  const AuthController(this._gateway);

  final AuthGateway _gateway;

  Future<void> sendEmailCode(String email) =>
      _gateway.sendEmailCode(email.trim());

  Future<void> verifyEmailCode({required String email, required String code}) =>
      _gateway.verifyEmailCode(email: email.trim(), code: code.trim());

  Future<AuthenticatorEnrollment> prepareAuthenticator() =>
      _gateway.prepareAuthenticator();

  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) => _gateway.verifyAuthenticator(factorId: factorId, code: code.trim());

  Future<void> signOut() => _gateway.signOut();
}
