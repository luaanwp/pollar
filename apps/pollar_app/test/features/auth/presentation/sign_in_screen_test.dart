import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/auth/application/auth_gateway.dart';
import 'package:pollar_app/features/auth/domain/auth_session.dart';
import 'package:pollar_app/features/auth/presentation/auth_controller.dart';
import 'package:pollar_app/features/auth/presentation/sign_in_screen.dart';

void main() {
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

Future<_FakeAuthGateway> _showCodeField(WidgetTester tester) async {
  final auth = _FakeAuthGateway();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authGatewayProvider.overrideWithValue(auth)],
      child: MaterialApp(
        theme: PollarTheme.light(),
        home: const SignInScreen(),
      ),
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

class _FakeAuthGateway implements AuthGateway {
  String? verifiedCode;

  @override
  bool get isConfigured => true;
  @override
  AuthSession? get currentSession => null;
  @override
  bool get isSecondFactorVerified => false;
  @override
  bool get hasRecentEmailCode => false;
  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(null);
  @override
  Future<void> sendEmailCode(String email) async {}
  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    verifiedCode = code;
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
