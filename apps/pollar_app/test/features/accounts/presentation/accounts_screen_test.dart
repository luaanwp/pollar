import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/accounts/data/seeded_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/features/accounts/domain/account_repository.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_controller.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_screen.dart';
import 'package:pollar_app/main.dart';

void main() {
  Widget app({AccountRepository? repository}) => ProviderScope(
    overrides: [
      accountRepositoryProvider.overrideWithValue(
        repository ?? createSeededAccountRepository(),
      ),
    ],
    child: const PollarApp(),
  );

  Finder field(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextFormField),
  );

  Future<void> openAccounts(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contas').first);
    await tester.pumpAndSettle();
  }

  testWidgets('lists seeded accounts and obeys privacy mode', (tester) async {
    await openAccounts(tester);

    expect(find.text('Conta principal'), findsOneWidget);
    expect(find.text('Carteira'), findsOneWidget);
    expect(find.text('Cartão Ouro'), findsOneWidget);
    expect(find.text(r'R$ 8.595,95'), findsOneWidget);

    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pump();

    expect(find.text(r'R$ 8.595,95'), findsNothing);
    expect(find.textContaining('••••••'), findsWidgets);
  });

  testWidgets('creates a checking account through the application layer', (
    tester,
  ) async {
    await openAccounts(tester);
    await tester.tap(find.text('Cadastrar conta ou cartão'));
    await tester.pumpAndSettle();

    await tester.enterText(field('account-name'), 'Reserva da casa');
    await tester.enterText(field('opening-balance'), '150,50');
    await tester.tap(find.text('Salvar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Reserva da casa'), findsOneWidget);
    expect(find.text(r'R$ 150,50'), findsOneWidget);
    expect(find.text('Conta cadastrada.'), findsOneWidget);
  });

  testWidgets('card fields create a liability account with billing terms', (
    tester,
  ) async {
    await openAccounts(tester);
    await tester.tap(find.text('Cadastrar conta ou cartão'));
    await tester.pumpAndSettle();

    await tester.enterText(field('account-name'), 'Cartão Viagem');
    await tester.tap(find.byKey(const Key('account-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cartão de crédito').last);
    await tester.pumpAndSettle();
    await tester.enterText(field('opening-balance'), '320,10');
    await tester.enterText(field('credit-limit'), '8000');
    await tester.enterText(field('closing-day'), '12');
    await tester.enterText(field('due-day'), '19');
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar cartão'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Cartão Viagem'), findsOneWidget);
    expect(find.text(r'−R$ 320,10'), findsOneWidget);
    expect(find.text('Fecha dia 12 · vence dia 19'), findsOneWidget);
  });

  testWidgets('archives and restores an account without removing history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openAccounts(tester);

    await tester.tap(find.byTooltip('Arquivar Conta principal'));
    await tester.pumpAndSettle();
    expect(find.text('Arquivar Conta principal?'), findsOneWidget);
    await tester.tap(find.text('Arquivar conta'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Arquivadas'), findsOneWidget);
    expect(find.byTooltip('Restaurar Conta principal'), findsOneWidget);

    await tester.tap(find.byTooltip('Restaurar Conta principal'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Arquivar Conta principal'), findsOneWidget);
    expect(find.text('Conta restaurada.'), findsOneWidget);
  });

  testWidgets('account cards support 200% text on a compact viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountRepositoryProvider.overrideWithValue(
            createSeededAccountRepository(),
          ),
        ],
        child: MaterialApp(
          theme: PollarTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(body: AccountsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('archive failure keeps confirmation open and explains recovery', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(repository: _FailingMutationRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contas').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Arquivar Conta principal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arquivar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Arquivar Conta principal?'), findsOneWidget);
    expect(
      find.text('Não foi possível arquivar a conta. Tente novamente.'),
      findsOneWidget,
    );
  });
}

class _FailingMutationRepository implements AccountRepository {
  _FailingMutationRepository() : _delegate = createSeededAccountRepository();

  final AccountRepository _delegate;

  @override
  Future<void> add(Account account) => _delegate.add(account);

  @override
  Future<List<Account>> findAll() => _delegate.findAll();

  @override
  Future<Account?> findById(String id) => _delegate.findById(id);

  @override
  Future<void> replace(Account account) async {
    throw StateError('Simulated write failure');
  }
}
