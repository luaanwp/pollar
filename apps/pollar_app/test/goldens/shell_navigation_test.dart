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
    bool reduced = false,
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: Directionality(textDirection: direction, child: child!),
          ),
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
      expect(router.state.uri.path, '/overview');
      expect(find.byKey(const Key('more-menu-panel')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
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
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
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

  for (final size in [const Size(1200, 900), const Size(390, 844)]) {
    testWidgets('More overlays the current draft and toggles closed at $size', (
      tester,
    ) async {
      final (router, _) = await mount(tester, size: size);
      await tester.enterText(find.byType(TextField), 'rascunho sem sair');
      final target = size.width < 600
          ? find.widgetWithText(NavigationDestination, 'Mais')
          : find.byTooltip('Mais');
      final anchor = tester.getCenter(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/overview');
      expect(find.byKey(const Key('more-menu-panel')), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      final clipping = find.byKey(const Key('more-menu-backdrop-clip'));
      final backdrop = tester.widget<ClipPath>(clipping);
      final path = backdrop.clipper!.getClip(tester.getSize(clipping));
      final origin = tester.getTopLeft(clipping);
      expect(path.contains(anchor - origin), isFalse);
      expect(path.contains(const Offset(24, 400) - origin), isTrue);
      expect(find.text('Preferências'), findsOneWidget);
      await tester.tapAt(anchor);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('more-menu-panel')), findsNothing);
      expect(find.text('rascunho sem sair'), findsOneWidget);
      expect(router.state.uri.path, '/overview');
    });
  }

  testWidgets(
    'More dismisses by Escape and outside click without changing branch',
    (tester) async {
      final (router, _) = await mount(tester, location: '/accounts');
      for (final keyboard in [true, false]) {
        await tester.tap(find.byTooltip('Mais'));
        await tester.pumpAndSettle();
        if (keyboard) {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        } else {
          await tester.tapAt(const Offset(24, 400));
        }
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('more-menu-panel')), findsNothing);
        expect(router.state.uri.path, '/accounts');
      }
    },
  );

  testWidgets(
    'More selection opens the destination and Back restores the original detail',
    (tester) async {
      final (router, _) = await mount(tester);
      router.push('/overview/detail');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-menu-/more/reports')));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/more/reports');
      expect(find.byKey(const Key('more-menu-panel')), findsNothing);
      router.pop();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/overview/detail');
      expect(find.text('Detalhe preservado'), findsOneWidget);
    },
  );

  testWidgets('More keyboard arrows select a destination', (tester) async {
    final (router, _) = await mount(tester);
    await tester.tap(find.byTooltip('Mais'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/more/wealth');
  });

  testWidgets('short enlarged menu scrolls to the last destination', (
    tester,
  ) async {
    final (router, _) = await mount(
      tester,
      size: const Size(800, 320),
      scale: 2,
    );
    final anchor = find.byTooltip('Mais');
    await tester.ensureVisible(anchor);
    await tester.pumpAndSettle();
    await tester.tap(anchor);
    await tester.pumpAndSettle();
    final last = find.byKey(const Key('more-menu-/more/settings'));
    await tester.scrollUntilVisible(
      last,
      100,
      scrollable: find.descendant(
        of: find.byKey(const Key('more-menu-panel')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(last).height, greaterThanOrEqualTo(48));
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/more/settings');
  });

  testWidgets('More respects reduced motion and system Back', (tester) async {
    final (router, _) = await mount(tester, reduced: true);
    await tester.tap(find.byTooltip('Mais'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('more-menu-panel')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('more-menu-panel')),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('more-menu-panel')), findsNothing);
    expect(router.state.uri.path, '/overview');
  });

  for (final enlargeText in [false, true]) {
    testWidgets(
      'More closes when its anchor layout changes text=$enlargeText',
      (tester) async {
        final (router, _) = await mount(tester);
        await tester.tap(find.byTooltip('Mais'));
        await tester.pumpAndSettle();
        if (enlargeText) {
          tester.platformDispatcher.textScaleFactorTestValue = 2;
        } else {
          tester.view.physicalSize = const Size(800, 600);
        }
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('more-menu-panel')), findsNothing);
        expect(router.state.uri.path, '/overview');
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final sample in [
    (
      size: Size(1440, 900),
      scale: 1.0,
      dark: true,
      name: 'more_menu_1440_dark.png',
    ),
    (
      size: Size(390, 844),
      scale: 1.0,
      dark: false,
      name: 'more_menu_390_light.png',
    ),
    (
      size: Size(800, 320),
      scale: 2.0,
      dark: true,
      name: 'more_menu_800_dark_2x.png',
    ),
  ]) {
    testWidgets(sample.name, (tester) async {
      await mount(
        tester,
        size: sample.size,
        scale: sample.scale,
        dark: sample.dark,
      );
      final target = sample.size.width < 600
          ? find.widgetWithText(NavigationDestination, 'Mais')
          : find.byTooltip('Mais');
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      final originalAnchor = tester.getRect(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(tester.getRect(target), originalAnchor);
      final bounds = tester.getRect(find.byKey(const Key('more-menu-panel')));
      expect(bounds.left, greaterThanOrEqualTo(16));
      expect(bounds.right, lessThanOrEqualTo(sample.size.width - 16));
      expect(bounds.top, greaterThanOrEqualTo(16));
      expect(bounds.bottom, lessThanOrEqualTo(sample.size.height - 16));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(sample.name),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

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
