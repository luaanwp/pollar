import '../../features/auth/application/auth_gateway.dart';
import '../../features/sync/application/sync_gateway.dart';

class AuthSyncSessionAccess implements SyncSessionAccess {
  const AuthSyncSessionAccess(this._auth);

  final AuthGateway _auth;

  @override
  bool get isConfigured => _auth.isConfigured;

  @override
  bool get hasSession => _auth.currentSession != null;

  @override
  String? get userId => _auth.currentSession?.userId;

  @override
  String? get email => _auth.currentSession?.email;

  @override
  Future<void> signOut() => _auth.signOut();
}
