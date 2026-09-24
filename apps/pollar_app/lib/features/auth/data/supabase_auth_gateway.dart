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
  Stream<domain.AuthSession?> sessionChanges() async* {
    yield currentSession;
    await for (final event in _client.auth.onAuthStateChange) {
      yield _map(event.session);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<domain.SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return domain.SignUpResult(
        needsEmailConfirmation: response.session == null,
      );
    } on AuthException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> sendMagicLink(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
    } on AuthException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  domain.AuthSession? _map(Session? session) {
    final user = session?.user;
    if (user == null) return null;
    return domain.AuthSession(userId: user.id, email: user.email ?? '');
  }

  AuthFailure _failure(AuthException error) {
    final normalized = error.message.toLowerCase();
    if (normalized.contains('invalid login') ||
        normalized.contains('invalid credentials')) {
      return const AuthFailure(
        'E-mail ou senha não conferem. Revise os dados e tente novamente.',
      );
    }
    if (normalized.contains('email not confirmed')) {
      return const AuthFailure(
        'Confirme o e-mail antes de entrar. Verifique sua caixa de entrada.',
      );
    }
    if (normalized.contains('already registered') ||
        normalized.contains('already exists')) {
      return const AuthFailure(
        'Este e-mail já possui uma conta. Entre com a senha cadastrada.',
      );
    }
    if (normalized.contains('password')) {
      return const AuthFailure(
        'A senha não atende aos requisitos do servidor. Use pelo menos 8 caracteres.',
      );
    }
    return const AuthFailure(
      'Não foi possível acessar a conta. Verifique a conexão e tente novamente.',
    );
  }
}
