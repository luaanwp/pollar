import '../domain/auth_session.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

abstract interface class AuthGateway {
  bool get isConfigured;

  AuthSession? get currentSession;

  Stream<AuthSession?> sessionChanges();

  Future<void> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  });

  Future<void> sendMagicLink(String email);

  Future<void> signOut();
}

class UnconfiguredAuthGateway implements AuthGateway {
  const UnconfiguredAuthGateway();

  @override
  bool get isConfigured => false;

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(null);

  Never _unavailable() => throw StateError(
    'Supabase não configurado. Informe SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY.',
  );

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async => _unavailable();

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async => _unavailable();

  @override
  Future<void> sendMagicLink(String email) async => _unavailable();

  @override
  Future<void> signOut() async {}
}
