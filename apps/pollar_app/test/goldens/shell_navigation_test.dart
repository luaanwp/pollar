import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/app/routing/app_shell.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/settings/presentation/more_screen.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
    await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
          rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
        ))
        .load();
  });

  Future<(GoRouter, ProviderContainer)> mount(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    String location = '/overview',
    bool dark = false,
    double scale = 1,
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final container = ProviderContainer();
    final router = GoRouter(
      initialLocation: location,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            for (final destination in appDestinations)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: destination.path,
                    builder: (context, state) => destination.path == '/more'
                        ? const MoreScreen()
                        : _DraftPage(label: destination.label),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        builder: (context, state) =>
                            const Scaffold(body: Text('Detalhe preservado')),
                      ),
                      if (destination.path == '/more')
                        for (final path in [
                          'reports',
                          'wealth',
                          'sync',
                          'data',
                          'settings',
                        ])
                          GoRoute(
                            path: path,
                            builder: (context, state) =>
                                Scaffold(body: Text('Destino $path')),
                          ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: dark ? PollarTheme.dark() : PollarTheme.light(),
          routerConfig: router,
          builder: (context, child) =>
              Directionality(textDirection: direction, child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (router, container);
  }

  testWidgets('top navigation and resizing preserve branch drafts and stacks', (
    tester,
  ) async {
    final (router, _) = await mount(tester);
    await tester.enterText(find.byType(TextField), 'rascunho preservado');
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.getRect(find.byType(TextField)).left, 16);
    router.push('/overview/detail');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Contas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Visão geral'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/overview/detail');
    for (final width in [390.0, 800.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      expect(find.text('Detalhe preservado'), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(
        find.byType(NavigationDestination),
        width < 600 ? findsNWidgets(5) : findsNothing,
      );
    }
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('rascunho preservado'), findsOneWidget);
  });

  testWidgets(
    'short top navigation scrolls at double text without shrinking targets',
    (tester) async {
      final (router, _) = await mount(
        tester,
        size: const Size(800, 320),
        scale: 2,
      );
      final last = find.byTooltip('Mais');
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      expect(tester.getSize(last).height, greaterThanOrEqualTo(48));
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/more');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keyboard operates top destinations, privacy shortcut and More rows',
    (tester) async {
      final (router, container) = await mount(tester);
      for (var i = 0; i < 24; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        if (FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<Tooltip>()
                ?.message ==
            'Contas') {
          break;
        }
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/accounts');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(container.read(privacyModeProvider), isTrue);
      router.go('/more');
      await tester.pumpAndSettle();
      for (var i = 0; i < 24; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final tile = FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<ListTile>();
        if (tile?.title is Text && (tile!.title as Text).data == 'Relatórios') {
          break;
        }
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/more/reports');
    },
  );

  testWidgets(
    'selected destination stays visible after enlarged text and resizing',
    (tester) async {
      final (router, _) = await mount(tester, location: '/more');
      tester.view.physicalSize = const Size(600, 500);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await tester.pumpAndSettle();
      final selected = tester.getRect(find.byTooltip('Mais'));
      expect(selected.left, greaterThanOrEqualTo(24));
      expect(selected.right, lessThanOrEqualTo(576));
      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/more');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('navigation hint waits two seconds and stays beside its target', (
    tester,
  ) async {
    await mount(tester, location: '/more');
    final target = tester.getRect(find.byTooltip('Mais'));
    final hint = find.byWidgetPredicate(
      (widget) => widget is Text && widget.textSpan?.toPlainText() == 'Mais',
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 300));
    await mouse.moveTo(target.center);
    await tester.pump(const Duration(milliseconds: 1900));
    expect(hint, findsNothing);
    await tester.pump(const Duration(milliseconds: 101));
    await tester.pump(const Duration(milliseconds: 200));
    expect(hint, findsOneWidget);
    final bounds = tester.getRect(hint);
    expect((bounds.center.dx - target.center.dx).abs(), lessThan(24));
    expect(bounds.top, greaterThanOrEqualTo(target.bottom));
    expect(bounds.top - target.bottom, lessThan(32));
    await mouse.removePointer();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'compact toolbar has no duplicate page label or wide hover target',
    (tester) async {
      await mount(tester, location: '/more', size: const Size(390, 844));
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Mais')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Mais'),
        ),
        findsNothing,
      );
      expect(find.text('Entenda seus dados'), findsOneWidget);
      expect(find.byTooltip('Ocultar valores'), findsOneWidget);
    },
  );

  testWidgets(
    'RTL navigation follows reading direction and switches branches',
    (tester) async {
      final (router, _) = await mount(tester, direction: TextDirection.rtl);
      expect(
        tester.getCenter(find.byTooltip('Visão geral')).dx,
        greaterThan(tester.getCenter(find.byTooltip('Mais')).dx),
      );
      await tester.tap(find.byTooltip('Contas'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/accounts');
      expect(tester.takeException(), isNull);
    },
  );

  for (final path in ['reports', 'wealth', 'sync', 'data', 'settings']) {
    testWidgets('More opens unchanged $path route', (tester) async {
      final (router, _) = await mount(tester, location: '/more');
      final labels = {
        'reports': 'Relatórios',
        'wealth': 'Patrimônio',
        'sync': 'Sincronização',
        'data': 'Dados e backup',
        'settings': 'Preferências',
      };
      final row = find.widgetWithText(ListTile, labels[path]!);
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/more/$path');
    });
  }

  for (final scenario in [
    (width: 1440.0, height: 900.0, dark: false, scale: 1.0, collapsed: false),
    (width: 1440.0, height: 900.0, dark: true, scale: 1.0, collapsed: true),
    (width: 800.0, height: 900.0, dark: false, scale: 1.0, collapsed: false),
    (width: 800.0, height: 320.0, dark: true, scale: 2.0, collapsed: false),
    (width: 390.0, height: 844.0, dark: false, scale: 1.0, collapsed: false),
    (width: 320.0, height: 844.0, dark: true, scale: 2.0, collapsed: false),
  ]) {
    final name =
        'more_${scenario.width.toInt()}_${scenario.dark ? 'dark' : 'light'}_${scenario.scale.toInt()}x';
    testWidgets(name, (tester) async {
      await mount(
        tester,
        location: '/more',
        size: Size(scenario.width, scenario.height),
        dark: scenario.dark,
        scale: scenario.scale,
      );
      if (scenario.height >= 500) {
        expect(find.text('Entenda seus dados'), findsOneWidget);
      } else {
        expect(find.byTooltip('Mais'), findsOneWidget);
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$name.png'),
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(ListTile, 'Preferências'),
        200,
        scrollable: find.descendant(
          of: find.byType(MoreScreen),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('compact transaction heading fits enlarged text', (tester) async {
    await mount(
      tester,
      location: '/transactions',
      size: const Size(320, 844),
      scale: 2,
    );
    final title = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Transações'),
    );
    expect(tester.getSize(title).height, greaterThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom destinations respect system inset and Android targets', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPadding);
    await mount(tester, size: const Size(390, 844));
    for (final destination in appDestinations) {
      final target = find.widgetWithText(
        NavigationDestination,
        destination.label,
      );
      final bounds = tester.getRect(target);
      expect(bounds.height, greaterThanOrEqualTo(48));
      expect(bounds.bottom, lessThanOrEqualTo(810));
    }
    for (final button in tester.widgetList<IconButton>(
      find.byType(IconButton),
    )) {
      final bounds = tester.getSize(find.byWidget(button));
      expect(bounds.width, greaterThanOrEqualTo(48));
      expect(bounds.height, greaterThanOrEqualTo(48));
    }
  });
}

class _DraftPage extends StatefulWidget {
  const _DraftPage({required this.label});
  final String label;
  @override
  State<_DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<_DraftPage> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Página ${widget.label}'),
      TextField(controller: controller),
    ],
  );
}
