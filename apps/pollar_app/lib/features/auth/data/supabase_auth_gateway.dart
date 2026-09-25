import 'package:supabase_flutter/supabase_flutter.dart';

import '../application/auth_gateway.dart';
import '../domain/auth_session.dart' as domain;

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  @override
  bool get isConfigured => true;

  @override
  domain.AuthSession? get currentSession => _map(_client.auth.currentSession);

  @override
  bool get isSecondFactorVerified =>
      _client.auth.mfa.getAuthenticatorAssuranceLevel().currentLevel ==
      AuthenticatorAssuranceLevels.aal2;

  @override
  bool get hasRecentEmailCode {
    final methods = _client.auth.mfa
        .getAuthenticatorAssuranceLevel()
        .currentAuthenticationMethods;
    final threshold = DateTime.now().subtract(const Duration(days: 10));
    return methods.any(
      (entry) =>
          (entry.method == AMRMethod.otp ||
              entry.method == AMRMethod.magiclink) &&
          entry.timestamp.isAfter(threshold),
    );
  }

  @override
  Stream<domain.AuthSession?> sessionChanges() async* {
    yield currentSession;
    await for (final event in _client.auth.onAuthStateChange) {
      yield _map(event.session);
    }
  }

  @override
  Future<void> sendEmailCode(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
    } on AuthException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );
    } on AuthException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async {
    try {
      final factors = await _client.auth.mfa.listFactors();
      if (factors.totp.isNotEmpty) {
        return AuthenticatorEnrollment(factorId: factors.totp.first.id);
      }
      final enrolled = await _client.auth.mfa.enroll(
        factorType: FactorType.totp,
        issuer: 'Pollar',
        friendlyName: 'Pollar',
      );
      return AuthenticatorEnrollment(
        factorId: enrolled.id,
        secret: enrolled.totp?.secret,
      );
    } on AuthException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async {
    try {
      await _client.auth.mfa.challengeAndVerify(factorId: factorId, code: code);
    } on AuthException catch (_) {
      throw const AuthFailure(
        'Código não conferiu. Confira o relógio do celular e tente novamente.',
      );
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut(scope: SignOutScope.local);

  domain.AuthSession? _map(Session? session) {
    final user = session?.user;
    if (user == null) return null;
    return domain.AuthSession(userId: user.id, email: user.email ?? '');
  }

  AuthFailure _failure(AuthException error) {
    final normalized = error.message.toLowerCase();
    if (normalized.contains('invalid') || normalized.contains('expired')) {
      return const AuthFailure(
        'Código inválido ou expirado. Solicite outro e tente novamente.',
      );
    }
    return const AuthFailure(
      'Não foi possível acessar a conta. Verifique a conexão e tente novamente.',
    );
  }
}
