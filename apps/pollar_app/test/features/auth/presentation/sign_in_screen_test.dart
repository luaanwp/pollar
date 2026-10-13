import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/features/auth/application/auth_gateway.dart';
import 'package:pollar_app/features/auth/domain/auth_session.dart';
import 'package:pollar_app/features/auth/presentation/auth_controller.dart';
import 'package:pollar_app/features/auth/presentation/sign_in_screen.dart';

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
  testWidgets('advances without an auth event or a completed storage write', (
    tester,
  ) async {
    final pendingWrite = Completer<void>();
    addTearDown(() {
      if (!pendingWrite.isCompleted) pendingWrite.complete();
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, (call) async {
          if (call.method == 'write') await pendingWrite.future;
          return null;
        });
    final auth = await _showCodeField(tester, withRouter: true);
    await tester.enterText(
      find.byKey(const Key('auth-email-code')),
      '12345678',
    );
    await tester.ensureVisible(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    expect(find.text('Confirme no autenticador'), findsOneWidget);
    expect(auth.verifications, 1);
    expect(pendingWrite.isCompleted, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejected confirmation remains editable and can be retried', (
    tester,
  ) async {
    final auth = await _showCodeField(tester);
    auth.failure = const AuthFailure(
      'Código inválido ou expirado. Solicite outro e tente novamente.',
    );
    await tester.enterText(
      find.byKey(const Key('auth-email-code')),
      '12345678',
    );
    await tester.ensureVisible(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    expect(find.text(auth.failure!.message), findsOneWidget);
    expect(find.text('Continuar para o autenticador'), findsNothing);
    auth.failure = null;
    await tester.enterText(
      find.byKey(const Key('auth-email-code')),
      '87654321',
    );
    await tester.tap(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    expect(auth.verifications, 2);
    expect(find.text('Continuar para o autenticador'), findsOneWidget);
  });
  testWidgets('accepted code is not submitted again when session events lag', (
    tester,
  ) async {
    final auth = await _showCodeField(tester);
    await tester.enterText(
      find.byKey(const Key('auth-email-code')),
      '12345678',
    );
    await tester.ensureVisible(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    expect(find.text('Continuar para o autenticador'), findsOneWidget);
    await tester.tap(find.text('Continuar para o autenticador'));
    await tester.pumpAndSettle();
    expect(auth.verifications, 1);
  });

  for (final length in [6, 8, 10]) {
    testWidgets('accepts a $length-digit email code', (tester) async {
      final auth = await _showCodeField(tester);
      final code = '1234567890'.substring(0, length);

      await tester.enterText(find.byKey(const Key('auth-email-code')), code);
      await tester.ensureVisible(find.text('Confirmar código do e-mail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar código do e-mail'));
      await tester.pump();

      expect(auth.verifiedCode, code);
    });
  }

  testWidgets('rejects an incomplete email code without contacting Auth', (
    tester,
  ) async {
    final auth = await _showCodeField(tester);

    await tester.enterText(find.byKey(const Key('auth-email-code')), '12345');
    await tester.ensureVisible(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar código do e-mail'));
    await tester.pumpAndSettle();

    expect(auth.verifiedCode, isNull);
    expect(
      find.text('Informe o código de 6 a 10 dígitos enviado por e-mail.'),
      findsOneWidget,
    );
  });
}

Future<_FakeAuthGateway> _showCodeField(
  WidgetTester tester, {
  bool withRouter = false,
}) async {
  final auth = _FakeAuthGateway();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authGatewayProvider.overrideWithValue(auth)],
      child: withRouter
          ? const _RoutedApp()
          : MaterialApp(theme: PollarTheme.light(), home: const SignInScreen()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('auth-email')),
    'pollar@example.test',
  );
  await tester.tap(find.text('Receber código por e-mail'));
  await tester.pumpAndSettle();
  return auth;
}

class _RoutedApp extends ConsumerWidget {
  const _RoutedApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    theme: PollarTheme.light(),
    routerConfig: ref.watch(routerProvider),
  );
}

class _FakeAuthGateway implements AuthGateway {
  String? verifiedCode;
  int verifications = 0;
  AuthSession? _session;
  AuthFailure? failure;

  @override
  bool get isConfigured => true;
  @override
  AuthSession? get currentSession => _session;
  @override
  bool get isSecondFactorVerified => false;
  @override
  bool get hasRecentEmailCode => _session != null;
  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(null);
  @override
  Future<void> sendEmailCode(String email) async {}
  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    verifications++;
    if (failure != null) throw failure!;
    verifiedCode = code;
    _session = AuthSession(userId: 'test-user', email: email);
  }

  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async =>
      const AuthenticatorEnrollment(factorId: 'unused');
  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async {}
  @override
  Future<void> signOut() async {}
}
