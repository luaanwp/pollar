import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/auth/application/auth_gateway.dart';
import 'package:pollar_app/features/auth/application/device_unlock_gateway.dart';
import 'package:pollar_app/features/auth/domain/auth_session.dart';
import 'package:pollar_app/features/auth/presentation/auth_controller.dart';
import 'package:pollar_app/features/auth/presentation/welcome_screen.dart';

void main() {
  const storage = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, (_) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, null);
  });

  testWidgets('disconnected startup allows immediate entry and native Back', (
    tester,
  ) async {
    final container = await _mount(tester, _Auth());
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(container.read(routerProvider).state.uri.path, '/welcome');
    // The ledger is still entering; the action never waits for its completion.
    await tester.tap(find.byKey(const Key('welcome-enter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth-email')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unauthenticated financial deep link returns to welcome', (
    tester,
  ) async {
    final container = await _mount(tester, _Auth());
    container.read(routerProvider).go('/accounts/new');
    await tester.pumpAndSettle();
    expect(container.read(routerProvider).state.uri.path, '/welcome');
    expect(find.byKey(const Key('account-name')), findsNothing);
  });

  for (final verified in [false, true]) {
    testWidgets(
      'saved session starts at welcome and Entrar keeps it locked, aal2=$verified',
      (tester) async {
        final auth = _Auth()
          ..session = const AuthSession(
            userId: 'saved',
            email: 'saved@test.test',
          )
          ..verified = verified;
        final container = await _mount(tester, auth);
        await tester.pumpAndSettle();
        expect(container.read(routerProvider).state.uri.path, '/welcome');
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(container.read(authenticatorUnlockedProvider), isFalse);
        await tester.tap(find.byKey(const Key('welcome-enter')));
        await tester.pumpAndSettle();
        expect(container.read(routerProvider).state.uri.path, '/authenticator');
        expect(container.read(authenticatorUnlockedProvider), isFalse);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(container.read(routerProvider).state.uri.path, '/welcome');
        expect(auth.currentSession?.userId, 'saved');
        // Protected destinations still require authentication without Entrar.
        container.read(routerProvider).go('/accounts/new');
        await tester.pumpAndSettle();
        expect(container.read(routerProvider).state.uri.path, '/authenticator');
        await auth.signOut();
        await tester.pumpAndSettle();
        expect(container.read(routerProvider).state.uri.path, '/welcome');
        expect(container.read(authenticatorUnlockedProvider), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('saved session needing email renewal keeps the email gate', (
    tester,
  ) async {
    final auth = _Auth()
      ..session = const AuthSession(userId: 'saved', email: 'saved@test.test')
      ..recent = false;
    final container = await _mount(tester, auth);
    await tester.pumpAndSettle();
    expect(container.read(routerProvider).state.uri.path, '/welcome');
    await tester.tap(find.byKey(const Key('welcome-enter')));
    await tester.pumpAndSettle();
    expect(container.read(routerProvider).state.uri.path, '/sign-in');
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byKey(const Key('auth-email')), findsOneWidget);
  });

  testWidgets('registration starts blank and Back preserves a saved session', (
    tester,
  ) async {
    final auth = _Auth()
      ..session = const AuthSession(userId: 'saved', email: 'saved@test.test');
    final container = await _mount(tester, auth);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('welcome-register')));
    await tester.pumpAndSettle();
    expect(container.read(routerProvider).state.uri.path, '/sign-up');
    expect(find.text('Criar sua conta'), findsOneWidget);
    final email = tester.widget<TextField>(find.byKey(const Key('auth-email')));
    expect(email.controller!.text, isEmpty);
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'new@test.test',
    );
    await tester.ensureVisible(find.text('Receber código por e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receber código por e-mail'));
    await tester.pumpAndSettle();
    expect(auth.sentEmail, 'new@test.test');
    expect(auth.currentSession?.userId, 'saved');
    expect(container.read(routerProvider).state.uri.path, '/sign-up');
    await tester.ensureVisible(find.text('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(container.read(routerProvider).state.uri.path, '/welcome');
    expect(auth.currentSession?.userId, 'saved');
    expect(auth.signOutCalls, 0);
    expect(tester.takeException(), isNull);
  });

  for (final saved in [false, true]) {
    testWidgets('registration confirms new identity before MFA, saved=$saved', (
      tester,
    ) async {
      final auth = _Auth();
      if (saved) {
        auth.session = const AuthSession(
          userId: 'saved',
          email: 'saved@test.test',
        );
        auth.verified = true;
      }
      final container = await _mount(tester, auth);
      await tester.pumpAndSettle();
      if (saved) {
        container.read(authenticatorUnlockedProvider.notifier).unlock();
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('welcome-register')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('auth-email')),
        'new@test.test',
      );
      await tester.ensureVisible(find.text('Receber código por e-mail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Receber código por e-mail'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('auth-email-code')),
        '12345678',
      );
      await tester.ensureVisible(find.text('Confirmar código do e-mail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar código do e-mail'));
      await tester.pumpAndSettle();
      expect(auth.currentSession?.userId, 'new-user');
      expect(auth.currentSession?.email, 'new@test.test');
      expect(container.read(routerProvider).state.uri.path, '/authenticator');
      expect(container.read(authenticatorUnlockedProvider), isFalse);
      expect(auth.signOutCalls, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Tab and Enter activate the entry action', (tester) async {
    await _mount(tester, _Auth());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth-email')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ledger settles once and reduced motion stops it immediately', (
    tester,
  ) async {
    final reduced = ValueNotifier(false);
    addTearDown(reduced.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PollarTheme.dark(),
          home: ValueListenableBuilder(
            valueListenable: reduced,
            builder: (context, value, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: value),
              child: child!,
            ),
            child: const WelcomeScreen(),
          ),
        ),
      ),
    );
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 160));
    reduced.value = true;
    await tester.pump();
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    reduced.value = false;
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(find.text('Entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(844, 390)]) {
    testWidgets('large text scrolls to a full entry target at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: PollarTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(2),
                padding: const EdgeInsets.only(top: 24, bottom: 24),
              ),
              child: child!,
            ),
            home: const WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final entry = find.byKey(const Key('welcome-enter'));
      await tester.ensureVisible(entry);
      await tester.pumpAndSettle();
      final rect = tester.getRect(entry);
      expect(rect.height, greaterThanOrEqualTo(56));
      expect(rect.bottom, lessThanOrEqualTo(size.height - 24));
      expect(rect.width, lessThanOrEqualTo(size.width));
      final register = find.byKey(const Key('welcome-register'));
      await tester.ensureVisible(register);
      await tester.pumpAndSettle();
      expect(tester.getSize(register).height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });
  }
}

Future<ProviderContainer> _mount(WidgetTester tester, _Auth auth) async {
  final container = ProviderContainer(
    overrides: [
      authGatewayProvider.overrideWithValue(auth),
      deviceUnlockGatewayProvider.overrideWithValue(_NoDevice()),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await auth.changes.close();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: PollarTheme.light(),
        routerConfig: container.read(routerProvider),
      ),
    ),
  );
  // Resolve the asynchronous router redirect without finishing the entrance.
  await tester.pump();
  await tester.pump();
  return container;
}

class _Auth implements AuthGateway {
  final changes = StreamController<AuthSession?>.broadcast();
  AuthSession? session;
  bool verified = false;
  bool recent = true;
  String? sentEmail;
  int signOutCalls = 0;
  @override
  bool get isConfigured => true;
  @override
  AuthSession? get currentSession => session;
  @override
  bool get hasRecentEmailCode => recent;
  @override
  bool get isSecondFactorVerified => verified;
  @override
  Stream<AuthSession?> sessionChanges() => changes.stream;
  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async =>
      const AuthenticatorEnrollment(factorId: 'test-factor');
  @override
  Future<void> signOut() async {
    signOutCalls++;
    session = null;
    changes.add(null);
  }

  @override
  Future<void> sendEmailCode(String email) async => sentEmail = email;
  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    session = AuthSession(userId: 'new-user', email: email);
    verified = false;
    recent = true;
    changes.add(session);
  }

  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async {}
}

class _NoDevice implements DeviceUnlockGateway {
  @override
  Future<bool> isSupported() async => false;
  @override
  Future<bool> authenticate() async => false;
}
