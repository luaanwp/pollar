import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_gateway.dart';
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

class AuthController {
  const AuthController(this._gateway);

  final AuthGateway _gateway;

  Future<void> signIn({required String email, required String password}) =>
      _gateway.signIn(email: email.trim(), password: password);

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) => _gateway.signUp(email: email.trim(), password: password);

  Future<void> sendMagicLink(String email) =>
      _gateway.sendMagicLink(email.trim());

  Future<void> signOut() => _gateway.signOut();
}
