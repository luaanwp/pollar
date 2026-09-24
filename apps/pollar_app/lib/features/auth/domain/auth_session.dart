class AuthSession {
  const AuthSession({required this.userId, required this.email});

  final String userId;
  final String email;
}

class SignUpResult {
  const SignUpResult({required this.needsEmailConfirmation});

  final bool needsEmailConfirmation;
}
