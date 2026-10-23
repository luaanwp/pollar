import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/app/routing/app_shell.dart';
import 'package:pollar_app/app/routing/navigation_preferences.dart';
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
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (router, container);
  }

  testWidgets(
    'collapse and responsive changes preserve branch drafts and stacks',
    (tester) async {
      final (router, container) = await mount(tester);
      await tester.enterText(find.byType(TextField), 'rascunho preservado');
      expect(tester.getSize(find.byType(NavigationRail)).width, 256);
      await tester.tap(find.byTooltip('Recolher navegação'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(NavigationRail)).width, 72);
      expect(find.text('rascunho preservado'), findsOneWidget);
      router.push('/overview/detail');
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(NavigationRail),
              matching: find.byTooltip('Contas'),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(NavigationRail),
              matching: find.byTooltip('Visão geral'),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/overview/detail');
      for (final width in [390.0, 800.0, 1200.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpAndSettle();
        expect(find.text('Detalhe preservado'), findsOneWidget);
        expect(container.read(railExpandedProvider), isFalse);
        if (width < 600) {
          expect(find.byType(NavigationDestination), findsNWidgets(5));
        } else {
          expect(tester.getSize(find.byType(NavigationRail)).width, 72);
        }
      }
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('rascunho preservado'), findsOneWidget);
      await tester.tap(find.byTooltip('Expandir navegação'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(NavigationRail)).width, 256);
    },
  );

  testWidgets('short rails scroll without shrinking targets at double text', (
    tester,
  ) async {
    final (router, _) = await mount(
      tester,
      size: const Size(1200, 320),
      scale: 2,
    );
    final rail = find.byType(NavigationRail);
    expect(tester.widget<NavigationRail>(rail).scrollable, isTrue);
    final last = find.descendant(of: rail, matching: find.text('Mais'));
    await tester.ensureVisible(last);
    await tester.pumpAndSettle();
    final target = find
        .ancestor(
          of: last,
          matching: find.byWidgetPredicate((widget) => widget is InkResponse),
        )
        .first;
    expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/more');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keyboard operates collapse, privacy shortcut and More destinations',
    (tester) async {
      final (router, container) = await mount(tester, location: '/more');
      for (var i = 0; i < 24; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        if (FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<IconButton>()
                ?.tooltip ==
            'Recolher navegação') {
          break;
        }
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(container.read(railExpandedProvider), isFalse);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(container.read(privacyModeProvider), isTrue);
      for (var i = 0; i < 20; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused != null &&
            focused.findAncestorWidgetOfExactType<ListTile>()?.title is Text &&
            ((focused.findAncestorWidgetOfExactType<ListTile>()!.title) as Text)
                    .data ==
                'Relatórios') {
          break;
        }
      }
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/more/reports');
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
      if (scenario.collapsed) {
        await tester.tap(find.byTooltip('Recolher navegação'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Entenda seus dados'), findsOneWidget);
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
