import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/shared/presentation/pollar_button.dart';
import 'package:pollar_app/shared/presentation/pollar_focus_outline.dart';
import 'package:pollar_app/shared/presentation/pollar_states.dart';
import 'package:pollar_app/shared/presentation/pollar_modal.dart';

void main() {
  Widget app(
    Widget child, {
    bool dark = false,
    bool reduced = false,
    bool accessible = false,
    bool ticker = true,
  }) => MaterialApp(
    theme: dark ? PollarTheme.dark() : PollarTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: reduced, accessibleNavigation: accessible),
      child: TickerMode(enabled: ticker, child: child!),
    ),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );

  testWidgets(
    'labeled action exposes its native semantic tap and activates once',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        var calls = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: PollarTheme.light(),
            home: Scaffold(
              body: PollarButton(
                label: 'Salvar orçamento',
                onPressed: () => calls++,
              ),
            ),
          ),
        );
        final node = tester.getSemantics(
          find.bySemanticsLabel('Salvar orçamento'),
        );
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
        node.owner!.performAction(node.id, SemanticsAction.tap);
        await tester.pump();
        expect(calls, 1);
      } finally {
        semantics.dispose();
      }
    },
  );

  for (final variant in PollarButtonVariant.values) {
    testWidgets(
      '${variant.name} keeps a single labeled native action including its icons',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          var calls = 0;
          await tester.pumpWidget(
            app(
              PollarButton(
                label: 'Confirmar registro',
                leadingIcon: LucideIcons.check,
                trailingIcon: LucideIcons.arrowRight,
                variant: variant,
                onPressed: () => calls++,
              ),
            ),
          );
          final finder = find.bySemanticsLabel('Confirmar registro');
          expect(finder, findsOneWidget);
          final node = tester.getSemantics(finder);
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          node.owner!.performAction(node.id, SemanticsAction.tap);
          await tester.pump();
          expect(calls, 1);
        } finally {
          handle.dispose();
        }
      },
    );
  }

  for (final loading in [false, true]) {
    testWidgets('unavailable button has no semantic tap, loading=$loading', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        var calls = 0;
        await tester.pumpWidget(
          app(
            PollarButton(
              label: 'Salvar registro',
              loading: loading,
              onPressed: loading ? () => calls++ : null,
            ),
            reduced: true,
          ),
        );
        final node = tester.getSemantics(
          find.bySemanticsLabel(
            loading ? 'Salvar registro, carregando' : 'Salvar registro',
          ),
        );
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
        expect(
          node.getSemanticsData().flagsCollection.isEnabled,
          Tristate.isFalse,
        );
        if (loading) {
          expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
        }
        await tester.tap(find.byType(TextButton));
        await tester.pump();
        expect(calls, 0);
      } finally {
        handle.dispose();
      }
    });
  }

  for (final selected in <bool?>[null, false, true]) {
    testWidgets('icon action exposes selection only when opted in: $selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        var calls = 0;
        await tester.pumpWidget(
          app(
            PollarIconButton(
              label: 'Ação do controle',
              icon: LucideIcons.eye,
              selected: selected,
              onPressed: () => calls++,
            ),
          ),
        );
        final node = tester.getSemantics(find.byType(IconButton));
        expect(node.getSemanticsData().tooltip, 'Ação do controle');
        expect(
          node.getSemanticsData().flagsCollection.isSelected,
          selected == null
              ? Tristate.none
              : selected
              ? Tristate.isTrue
              : Tristate.isFalse,
        );
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        node.owner!.performAction(node.id, SemanticsAction.tap);
        await tester.pump();
        expect(calls, 1);
      } finally {
        handle.dispose();
      }
    });
  }

  testWidgets(
    'Tab skips disabled actions; Enter, Space and icon activation remain native',
    (tester) async {
      final a = FocusNode();
      final b = FocusNode();
      final c = FocusNode();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      addTearDown(c.dispose);
      final calls = <String>[];
      await tester.pumpWidget(
        app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PollarButton(
                label: 'Salvar',
                focusNode: a,
                onPressed: () => calls.add('salvar'),
              ),
              const PollarButton(label: 'Indisponível', onPressed: null),
              PollarIconButton(
                label: 'Ocultar valores',
                icon: LucideIcons.eye,
                focusNode: b,
                onPressed: () => calls.add('ocultar'),
              ),
              PollarButton(
                label: 'Voltar',
                variant: PollarButtonVariant.ghost,
                focusNode: c,
                onPressed: () => calls.add('voltar'),
              ),
            ],
          ),
        ),
      );
      for (final node in [a, b, c]) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(node.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
      }
      expect(calls, ['salvar', 'ocultar', 'voltar']);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(calls, ['salvar', 'ocultar', 'voltar', 'voltar']);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'busy labels retain readable contrast while activation remains disabled, dark=$dark',
      (tester) async {
        for (final variant in PollarButtonVariant.values) {
          await tester.pumpWidget(
            app(
              PollarButton(
                label: 'Salvando',
                loading: true,
                variant: variant,
                onPressed: () {},
              ),
              dark: dark,
              reduced: true,
            ),
          );
          final button = tester.widget<TextButton>(find.byType(TextButton));
          final theme = Theme.of(tester.element(find.byType(TextButton)));
          final background = Color.alphaBlend(
            button.style!.backgroundColor!.resolve({WidgetState.disabled})!,
            theme.scaffoldBackgroundColor,
          );
          final foreground = Color.alphaBlend(
            button.style!.foregroundColor!.resolve({WidgetState.disabled})!,
            background,
          );
          final a = foreground.computeLuminance();
          final b = background.computeLuminance();
          expect(
            (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05),
            greaterThanOrEqualTo(4.5),
            reason: variant.name,
          );
          expect(button.onPressed, isNull);
        }
      },
    );
    test('focus role contrasts with external surfaces, dark=$dark', () {
      final colors = dark ? PollarColors.dark : PollarColors.light;
      for (final backdrop in [
        colors.canvas,
        colors.background,
        colors.financialSurface,
      ]) {
        final a = colors.info.computeLuminance();
        final b = backdrop.computeLuminance();
        final contrast =
            (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
        expect(contrast, greaterThanOrEqualTo(3));
      }
    });
    testWidgets(
      'keyboard outline does not change targets or semantics, dark=$dark',
      (tester) async {
        final strategy = FocusManager.instance.highlightStrategy;
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTraditional;
        addTearDown(() => FocusManager.instance.highlightStrategy = strategy);
        final focus = FocusNode();
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          app(
            PollarButton(
              label: 'Confirmar',
              focusNode: focus,
              onPressed: () {},
            ),
            dark: dark,
          ),
        );
        final before = tester.getRect(find.byType(TextButton));
        focus.requestFocus();
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byType(TextButton)), before);
        CustomPaint outline() => tester.widget<CustomPaint>(
          find
              .descendant(
                of: find.byType(PollarFocusOutline),
                matching: find.byType(CustomPaint),
              )
              .first,
        );
        expect(outline().foregroundPainter, isNotNull);
        await tester.pumpWidget(
          app(
            const PollarButton(label: 'Confirmar', onPressed: null),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(outline().foregroundPainter, isNull);
      },
    );
    testWidgets('disabled ghost keeps its transparent surface, dark=$dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const PollarButton(
            label: 'Cancelar',
            variant: PollarButtonVariant.ghost,
            onPressed: null,
          ),
          dark: dark,
        ),
      );
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(
        button.style!.backgroundColor!.resolve({WidgetState.disabled})!.a,
        0,
      );
    });
  }

  for (final mode in ['reduce', 'accessible', 'ticker']) {
    testWidgets('loading indicators are static under $mode', (tester) async {
      await tester.pumpWidget(
        app(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PollarButton(label: 'Salvar', loading: true, onPressed: null),
              PollarLoadingState(),
            ],
          ),
          reduced: mode == 'reduce',
          accessible: mode == 'accessible',
          ticker: mode != 'ticker',
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(LucideIcons.loaderCircle), findsNWidgets(2));
    });
  }

  testWidgets(
    'enabling reduced motion interrupts a current loading animation',
    (tester) async {
      await tester.pumpWidget(app(const PollarLoadingState()));
      await tester.pump(const Duration(milliseconds: 70));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(app(const PollarLoadingState(), reduced: true));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Carregando informações…'), findsOneWidget);
    },
  );

  testWidgets(
    'error exposes a heading and complete recovery action in short large-text windows',
    (tester) async {
      tester.view.physicalSize = const Size(320, 420);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final handle = tester.ensureSemantics();
      try {
        var calls = 0;
        await tester.pumpWidget(
          app(
            PollarErrorState(
              title: 'Falha ao carregar',
              message: 'Os registros continuam salvos.',
              actionLabel: 'Carregar informações novamente',
              onRetry: () => calls++,
            ),
          ),
        );
        final heading = tester.getSemantics(
          find.bySemanticsLabel('Falha ao carregar'),
        );
        expect(heading.getSemanticsData().flagsCollection.isHeader, isTrue);
        await tester.scrollUntilVisible(
          find.text('Carregar informações novamente'),
          100,
        );
        final button = find.widgetWithText(
          TextButton,
          'Carregar informações novamente',
        );
        expect(
          tester.getSize(button).height,
          greaterThanOrEqualTo(
            tester.getSize(find.text('Carregar informações novamente')).height,
          ),
        );
        final action = tester.getSemantics(
          find.bySemanticsLabel('Carregar informações novamente'),
        );
        action.owner!.performAction(action.id, SemanticsAction.tap);
        await tester.pump();
        expect(calls, 1);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'modal heading, semantic confirmation and focus restoration keep the native route',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final handle = tester.ensureSemantics();
      try {
        var calls = 0;
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) => PollarButton(
                label: 'Abrir confirmação',
                focusNode: focus,
                onPressed: () => showPollarAdaptiveModal<void>(
                  context: context,
                  title: 'Confirmar registro?',
                  description: 'Confira antes de continuar.',
                  actions: (modalContext) => [
                    PollarButton(
                      label: 'Confirmar registro',
                      onPressed: () {
                        calls++;
                        Navigator.of(modalContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
            reduced: true,
          ),
        );
        focus.requestFocus();
        await tester.pump();
        final open = tester.getSemantics(
          find.bySemanticsLabel('Abrir confirmação'),
        );
        open.owner!.performAction(open.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        final heading = tester.getSemantics(
          find.bySemanticsLabel('Confirmar registro?'),
        );
        expect(heading.getSemanticsData().flagsCollection.isHeader, isTrue);
        final confirm = tester.getSemantics(
          find.bySemanticsLabel('Confirmar registro'),
        );
        confirm.owner!.performAction(confirm.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(focus.hasPrimaryFocus, isTrue);
      } finally {
        handle.dispose();
      }
    },
  );
}
