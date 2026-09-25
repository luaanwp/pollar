import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/features/auth/application/auth_gateway.dart';
import 'package:pollar_app/features/auth/application/device_unlock_gateway.dart';
import 'package:pollar_app/features/auth/domain/auth_session.dart';
import 'package:pollar_app/features/auth/presentation/auth_controller.dart';
import 'package:pollar_app/features/auth/presentation/authenticator_screen.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';

void main() {
  testWidgets('offers device unlock when TOTP service is offline', (
    tester,
  ) async {
    final unlockLabel = defaultTargetPlatform == TargetPlatform.windows
        ? 'Desbloquear com Windows Hello'
        : 'Desbloquear com biometria ou PIN';
    final device = _DeviceUnlock();
    final router = GoRouter(
      initialLocation: '/authenticator',
      routes: [
        GoRoute(
          path: '/authenticator',
          builder: (_, _) => const AuthenticatorScreen(),
        ),
        GoRoute(
          path: '/overview',
          builder: (_, _) => const Scaffold(body: Text('Ledger unlocked')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(const _OfflineAuth()),
          deviceUnlockGatewayProvider.overrideWithValue(device),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: PollarTheme.light(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(unlockLabel), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    await tester.tap(find.text(unlockLabel));
    await tester.pumpAndSettle();
    expect(device.calls, 1);
    expect(find.text('Ledger unlocked'), findsOneWidget);
  });
}

class _OfflineAuth implements AuthGateway {
  const _OfflineAuth();

  @override
  bool get isConfigured => true;
  @override
  bool get isSecondFactorVerified => true;
  @override
  bool get hasRecentEmailCode => true;
  @override
  AuthSession? get currentSession =>
      const AuthSession(userId: 'one', email: 'one@example.test');
  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(currentSession);
  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async =>
      throw const AuthFailure('Sem conexão com o servidor.');
  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async {}
  @override
  Future<void> sendEmailCode(String email) async {}
  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {}
  @override
  Future<void> signOut() async {}
}

class _DeviceUnlock implements DeviceUnlockGateway {
  int calls = 0;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<bool> authenticate() async {
    calls++;
    return true;
  }
}
