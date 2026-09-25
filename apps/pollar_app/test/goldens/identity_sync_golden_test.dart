import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/auth/application/auth_gateway.dart';
import 'package:pollar_app/features/auth/domain/auth_session.dart';
import 'package:pollar_app/features/auth/presentation/auth_controller.dart';
import 'package:pollar_app/features/auth/presentation/sign_in_screen.dart';
import 'package:pollar_app/features/sync/application/sync_gateway.dart';
import 'package:pollar_app/features/sync/domain/sync_models.dart';
import 'package:pollar_app/features/sync/presentation/sync_controller.dart';
import 'package:pollar_app/features/sync/presentation/identity_mismatch_screen.dart';
import 'package:pollar_app/features/sync/presentation/sync_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'));
    final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
      ..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
    await Future.wait([inter.load(), lucide.load()]);
  });

  testWidgets('sign in compact', (tester) async {
    await _pump(tester, const SignInScreen(), const Size(390, 844));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sign_in_390x844.png'),
    );
  });

  testWidgets('sign in wide', (tester) async {
    await _pump(tester, const SignInScreen(), const Size(1200, 900));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sign_in_1200x900.png'),
    );
  });

  testWidgets('sign in medium remains stacked', (tester) async {
    await _pump(tester, const SignInScreen(), const Size(700, 900));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sign_in_700x900.png'),
    );
  });

  testWidgets('sync local only compact', (tester) async {
    await _pump(
      tester,
      const SyncScreen(),
      const Size(390, 844),
      store: _FakeSyncStore(
        const SyncOverview(
          phase: SyncPhase.localOnly,
          pendingCount: 3,
          conflictCount: 0,
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sync_local_390x844.png'),
    );
  });

  testWidgets('sync conflict wide', (tester) async {
    await _pump(
      tester,
      const SyncScreen(),
      const Size(1200, 900),
      auth: const _ConfiguredAuth(),
      store: _conflictStore(),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sync_conflict_1200x900.png'),
    );
  });

  testWidgets('sync conflict comparison uses financial language', (
    tester,
  ) async {
    await _pump(
      tester,
      const SyncScreen(),
      const Size(1200, 900),
      auth: const _ConfiguredAuth(),
      store: _conflictStore(),
    );
    await tester.tap(find.text('Comparar versões'));
    await tester.pumpAndSettle();
    expect(find.text('Valor: R\$ 120,00'), findsOneWidget);
    expect(find.text('Valor: R\$ 118,00'), findsOneWidget);
    expect(find.text('Tipo: Pagamento de fatura'), findsOneWidget);
    expect(find.text('Tipo: Despesa'), findsOneWidget);
    expect(find.text('Conta: Conta principal'), findsNWidgets(2));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sync_conflict_comparison_1200x900.png'),
    );
  });

  testWidgets('sync local only at 200 percent text', (tester) async {
    await _pump(
      tester,
      const SyncScreen(),
      const Size(390, 844),
      textScale: 2,
      store: _FakeSyncStore(
        const SyncOverview(
          phase: SyncPhase.localOnly,
          pendingCount: 3,
          conflictCount: 0,
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('sync_local_text_200_390x844.png'),
    );
  });

  testWidgets('identity mismatch blocks the ledger', (tester) async {
    await _pump(
      tester,
      const IdentityMismatchScreen(),
      const Size(390, 844),
      auth: const _ConfiguredAuth(),
      store: _FakeSyncStore(
        const SyncOverview(
          phase: SyncPhase.idle,
          pendingCount: 0,
          conflictCount: 0,
        ),
      ),
    );
    expect(find.text('Estes dados pertencem a outra conta'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('identity_mismatch_390x844.png'),
    );
  });
}

_FakeSyncStore _conflictStore() => _FakeSyncStore(
  SyncOverview(
    phase: SyncPhase.conflict,
    pendingCount: 1,
    conflictCount: 1,
    lastSyncedAt: DateTime(2026, 9, 24, 10, 30),
  ),
  conflictItems: [
    SyncConflictRecord(
      id: 'conflict',
      entityType: 'transaction',
      entityId: 'transaction',
      localPayload: const {
        'description': 'Mercado',
        'type': 'cardStatementPayment',
        'amount_minor': 12000,
        'account_name': 'Conta principal',
        'currency_code': 'BRL',
        'currency_decimal_digits': 2,
        'currency_symbol': 'R\$',
      },
      remotePayload: const {
        'description': 'Supermercado',
        'type': 'expense',
        'amount_minor': 11800,
        'account_name': 'Conta principal',
        'currency_code': 'BRL',
        'currency_decimal_digits': 2,
        'currency_symbol': 'R\$',
      },
      detectedAt: DateTime(2026, 9, 24),
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size, {
  double textScale = 1,
  AuthGateway auth = const UnconfiguredAuthGateway(),
  SyncLocalStore? store,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authGatewayProvider.overrideWithValue(auth),
        syncSessionAccessProvider.overrideWithValue(_TestSyncSession(auth)),
        if (store != null) syncLocalStoreProvider.overrideWithValue(store),
        if (auth.isConfigured)
          syncRemoteGatewayProvider.overrideWithValue(const _FakeRemote()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: PollarTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ConfiguredAuth implements AuthGateway {
  const _ConfiguredAuth();

  @override
  bool get isConfigured => true;
  @override
  bool get isSecondFactorVerified => true;
  @override
  bool get hasRecentEmailCode => true;
  @override
  AuthSession? get currentSession =>
      const AuthSession(userId: 'user', email: 'luan@pollar.app');
  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(currentSession);
  @override
  Future<void> sendEmailCode(String email) async {}
  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {}
  @override
  Future<AuthenticatorEnrollment> prepareAuthenticator() async =>
      const AuthenticatorEnrollment(factorId: 'factor');
  @override
  Future<void> verifyAuthenticator({
    required String factorId,
    required String code,
  }) async {}
  @override
  Future<void> signOut() async {}
}

class _TestSyncSession implements SyncSessionAccess {
  const _TestSyncSession(this.auth);

  final AuthGateway auth;

  @override
  String? get email => auth.currentSession?.email;

  @override
  bool get hasSession => auth.currentSession != null;

  @override
  bool get isConfigured => auth.isConfigured;

  @override
  String? get userId => auth.currentSession?.userId;

  @override
  Future<void> signOut() => auth.signOut();
}

class _FakeSyncStore implements SyncLocalStore {
  _FakeSyncStore(this.value, {this.conflictItems = const []});

  final SyncOverview value;
  final List<SyncConflictRecord> conflictItems;

  @override
  Future<SyncOverview> overview({required bool remoteConfigured}) async =>
      remoteConfigured ? value : value.copyWith(phase: SyncPhase.localOnly);
  @override
  Future<List<SyncConflictRecord>> conflicts() async => conflictItems;
  @override
  Future<int> applyPushResults(
    List<SyncMutation> sent,
    List<PushMutationResult> results,
  ) async => 0;
  @override
  Future<int> applyRemote(PullResult result) async => 0;
  @override
  Future<bool> bindIdentity(String userId) async => true;
  @override
  Future<int> cursor() async => 0;
  @override
  Future<String> deviceId() async => 'device';
  @override
  Future<void> markAttemptFailed(
    List<SyncMutation> mutations, {
    required DateTime now,
  }) async {}
  @override
  Future<void> markCompleted({
    required int cursor,
    required DateTime completedAt,
  }) async {}
  @override
  Future<List<SyncMutation>> pending({
    required DateTime now,
    int limit = 100,
  }) async => const [];
  @override
  Future<void> resolveConflict(String id, {required bool keepLocal}) async {}
}

class _FakeRemote implements SyncRemoteGateway {
  const _FakeRemote();

  @override
  Future<PullResult> pull({required int afterCursor, int limit = 500}) async =>
      const PullResult(cursor: 0, changes: []);

  @override
  Future<List<PushMutationResult>> push({
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async => const [];
}
