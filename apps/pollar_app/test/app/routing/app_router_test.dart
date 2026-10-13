import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/features/auth/application/auth_gateway.dart';
import 'package:pollar_app/features/auth/domain/auth_session.dart';
import 'package:pollar_app/features/auth/presentation/auth_controller.dart';

void main() {
  test(
    'logout clears the device unlock and replacement identity stays locked',
    () async {
      final gateway = _AuthGateway()..signIn();
      final container = ProviderContainer(
        overrides: [authGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(() async {
        container.dispose();
        await gateway.dispose();
      });
      final unlock = container.read(authenticatorUnlockedProvider.notifier);
      unlock.unlock();
      gateway.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authenticatorUnlockedProvider), isTrue);
      await gateway.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authenticatorUnlockedProvider), isFalse);
      gateway.signIn(userId: 'other-user');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authenticatorUnlockedProvider), isFalse);
    },
  );

  test(
    'direct identity replacement clears the previous device unlock',
    () async {
      final gateway = _AuthGateway()..signIn();
      final container = ProviderContainer(
        overrides: [authGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(() async {
        container.dispose();
        await gateway.dispose();
      });
      container.read(authenticatorUnlockedProvider.notifier).unlock();
      gateway.signIn(userId: 'other-user');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authenticatorUnlockedProvider), isFalse);
    },
  );

  test('auth events and unlock changes preserve the same router', () async {
    final gateway = _AuthGateway();
    final container = ProviderContainer(
      overrides: [authGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(() async {
      container.dispose();
      await gateway.dispose();
    });

    final router = container.read(routerProvider);
    gateway.signIn();
    await Future<void>.delayed(Duration.zero);
    expect(identical(container.read(routerProvider), router), isTrue);

    gateway.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(identical(container.read(routerProvider), router), isTrue);

    container.read(authenticatorUnlockedProvider.notifier).unlock();
    expect(identical(container.read(routerProvider), router), isTrue);
  });
}

class _AuthGateway implements AuthGateway {
  final _changes = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  void signIn({String userId = 'test-user'}) {
    _session = AuthSession(userId: userId, email: 'user@example.test');
    _changes.add(_session);
  }

  void refresh() => _changes.add(_session);

  Future<void> dispose() => _changes.close();

  @override
  bool get isConfigured => true;

  @override
  AuthSession? get currentSession => _session;

  @override
  bool get isSecondFactorVerified => false;

  @override
  bool get hasRecentEmailCode => true;

  @override
  Stream<AuthSession?> sessionChanges() => _changes.stream;

  @override
  Future<void> sendEmailCode(String email) async {}

  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {}

  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async =>
      const AuthenticatorEnrollment(factorId: 'test-factor');

  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async {}

  @override
  Future<void> signOut() async {
    _session = null;
    _changes.add(null);
  }
}
