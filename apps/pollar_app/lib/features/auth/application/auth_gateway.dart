import '../domain/auth_session.dart';

class AuthenticatorEnrollment {
  const AuthenticatorEnrollment({required this.factorId, this.secret});

  final String factorId;

  /// Present only during first enrollment; never persist this secret locally.
  final String? secret;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

abstract interface class AuthGateway {
  bool get isConfigured;

  AuthSession? get currentSession;

  bool get isSecondFactorVerified;

  bool get hasRecentEmailCode;

  Stream<AuthSession?> sessionChanges();

  Future<void> sendEmailCode(String email);

  Future<void> verifyEmailCode({required String email, required String code});

  Future<AuthenticatorEnrollment> prepareAuthenticator();

  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  });

  Future<void> signOut();
}

class UnconfiguredAuthGateway implements AuthGateway {
  const UnconfiguredAuthGateway();

  @override
  bool get isConfigured => false;

  @override
  AuthSession? get currentSession => null;

  @override
  bool get isSecondFactorVerified => false;

  @override
  bool get hasRecentEmailCode => false;

  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(null);

  Never _unavailable() => throw StateError(
    'Supabase não configurado. Informe SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY.',
  );

  @override
  Future<void> sendEmailCode(String email) async => _unavailable();

  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async => _unavailable();

  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async =>
      _unavailable();

  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async => _unavailable();

  @override
  Future<void> signOut() async {}
}
