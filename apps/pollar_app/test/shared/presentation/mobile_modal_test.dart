import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/shared/presentation/pollar_modal.dart';
import 'package:pollar_app/shared/presentation/pollar_form_controls.dart';

import '../../support/mobile_adaptation_fixture.dart';

void main() {
  void viewport(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double scale = 1,
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> keyboard(WidgetTester tester, double inset) async {
    tester.view.viewInsets = FakeViewPadding(bottom: inset);
    tester.view.padding = FakeViewPadding(top: 24, bottom: inset == 0 ? 34 : 0);
    await tester.pumpAndSettle();
  }

  Future<void> action(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(
      find.text(label),
      120,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'IME constrains the viewport and preserves focused budget draft and exact saving',
    (tester) async {
      viewport(tester);
      Budget? saved;
      await tester.pumpWidget(
        MobileFormHarness(onBudgetSaved: (value) async => saved = value),
      );
      await tester.tap(find.text('Orçamento'));
      await tester.pumpAndSettle();
      final form = tester.state(find.byType(Form));
      await tester.enterText(find.byType(TextFormField).first, 'Saúde');
      final focus = tester
          .widget<EditableText>(find.byType(EditableText).first)
          .focusNode;
      expect(focus.hasFocus, isTrue);
      await keyboard(tester, 300);
      expect(tester.state(find.byType(Form)), same(form));
      expect(focus.hasFocus, isTrue);
      expect(find.text('Saúde'), findsOneWidget);
      await tester.ensureVisible(find.byType(TextFormField).at(1));
      await tester.enterText(find.byType(TextFormField).at(1), '250,00');
      await action(tester, 'Salvar orçamento');
      expect(
        tester.getBottomLeft(find.text('Salvar orçamento')).dy,
        lessThan(544),
      );
      await tester.tap(find.text('Salvar orçamento'));
      await tester.pumpAndSettle();
      expect(saved!.category, 'Saúde');
      expect(saved!.limit.minorUnits, 25000);
      expect(saved!.alertThreshold, 85);
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'system gesture inset stays below the last action without a keyboard',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(const MobileFormHarness());
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(TextButton, 'Voltar ao registro');
      expect(tester.getBottomLeft(button).dy, lessThanOrEqualTo(844 - 34 - 16));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  for (final entry in mobileFormActions.entries) {
    testWidgets('${entry.key} actions remain complete above IME at 320px/2x', (
      tester,
    ) async {
      viewport(tester, size: const Size(320, 900), scale: 2);
      await tester.pumpWidget(const MobileFormHarness());
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      final form = tester.state(find.byType(Form));
      await keyboard(tester, 280);
      await action(tester, entry.value);
      final button = find.widgetWithText(TextButton, entry.value);
      final bounds = tester.getRect(button);
      expect(bounds.bottom, lessThanOrEqualTo(620));
      expect(bounds.height, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(find.text(entry.value)).height,
        lessThanOrEqualTo(bounds.height),
      );
      expect(tester.state(find.byType(Form)), same(form));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'landscape opens a scrollable sheet and retains its draft across rotation',
    (tester) async {
      viewport(tester, size: const Size(844, 390), scale: 2);
      await tester.pumpWidget(const MobileFormHarness());
      await tester.tap(find.text('Orçamento'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(PollarDecisionDialog), findsNothing);
      await tester.ensureVisible(find.byType(TextFormField).first);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Reserva familiar',
      );
      await keyboard(tester, 150);
      await action(tester, 'Salvar orçamento');
      expect(
        tester
            .getBottomLeft(find.widgetWithText(TextButton, 'Salvar orçamento'))
            .dy,
        lessThanOrEqualTo(240),
      );
      tester.view.physicalSize = const Size(390, 844);
      await keyboard(tester, 0);
      expect(find.text('Reserva familiar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'budget persistence failure preserves draft, disables duplicate save and permits retry',
    (tester) async {
      viewport(tester);
      final gate = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        MobileFormHarness(
          onBudgetSaved: (_) {
            calls++;
            return calls == 1 ? gate.future : Future.value();
          },
        ),
      );
      await tester.tap(find.text('Orçamento'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Saúde');
      await tester.enterText(find.byType(TextFormField).at(1), '250,00');
      await keyboard(tester, 300);
      await action(tester, 'Salvar orçamento');
      await tester.tap(find.text('Salvar orçamento'));
      await tester.pump();
      await tester.tap(find.text('Salvar orçamento'));
      await tester.pump();
      expect(calls, 1);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.byType(BottomSheet), findsOneWidget);
      gate.completeError(StateError('write failed'));
      await tester.pumpAndSettle();
      expect(find.text('Saúde'), findsOneWidget);
      expect(
        find.textContaining('Não foi possível salvar o orçamento'),
        findsOneWidget,
      );
      await action(tester, 'Salvar orçamento');
      await tester.tap(find.text('Salvar orçamento'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'large-text native selector fits complete labels and preserves selection',
    (tester) async {
      viewport(tester, size: const Size(320, 844), scale: 2);
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: PollarTheme.light(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: PollarSelect<String>(
                  label: 'Conta',
                  initialValue: 'a',
                  options: const [
                    PollarSelectOption(
                      value: 'a',
                      label: 'Conta para despesas familiares',
                    ),
                    PollarSelectOption(
                      value: 'b',
                      label: 'Reserva para cuidados continuados',
                    ),
                  ],
                  onChanged: (value) => selected = value,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      final label = find.text('Reserva para cuidados continuados').last;
      final item = find
          .ancestor(of: label, matching: find.byType(DropdownMenuItem<String>))
          .first;
      expect(
        tester.getRect(item).bottom,
        greaterThanOrEqualTo(tester.getRect(label).bottom),
      );
      expect(
        tester.getRect(item).top,
        lessThanOrEqualTo(tester.getRect(label).top),
      );
      await tester.tap(label);
      await tester.pumpAndSettle();
      expect(selected, 'b');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'font-scale changes preserve edited text, selection and field identity',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(const MobileFormHarness());
      await tester.tap(find.text('Orçamento'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Reserva familiar',
      );
      final field = tester.state(find.byType(TextFormField).first);
      final editor = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      editor.controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 5,
      );
      for (final scale in [2.0, 1.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(TextFormField).first), same(field));
        expect(editor.controller.text, 'Reserva familiar');
        expect(
          editor.controller.selection,
          const TextSelection(baseOffset: 1, extentOffset: 5),
        );
        expect(editor.focusNode.hasFocus, isTrue);
      }
    },
  );

  testWidgets(
    'native selection survives label reflow without resetting its value',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: PollarTheme.light(),
          home: Scaffold(
            body: PollarSelect<String>(
              label: 'Conta usada no planejamento',
              initialValue: 'a',
              options: const [
                PollarSelectOption(value: 'a', label: 'Conta principal'),
                PollarSelectOption(value: 'b', label: 'Conta reserva'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conta reserva').last);
      await tester.pumpAndSettle();
      final field = tester.state<FormFieldState<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      for (final scale in [2.0, 1.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.pumpAndSettle();
        expect(
          tester.state(find.byType(DropdownButtonFormField<String>)),
          same(field),
        );
        expect(field.value, 'b');
      }
    },
  );

  testWidgets('large reminder field shows its entire label and units', (
    tester,
  ) async {
    viewport(tester, size: const Size(320, 900), scale: 2);
    await tester.pumpWidget(const MobileFormHarness());
    await tester.tap(find.text('Compromisso'));
    await tester.pumpAndSettle();
    final label = find.text('Lembrar com antecedência (dias)');
    expect(
      tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
      isFalse,
    );
    expect(tester.widget<Text>(label).overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets(
    'final numeric keyboard action dismisses focus without implicitly saving',
    (tester) async {
      viewport(tester);
      var saves = 0;
      await tester.pumpWidget(
        MobileFormHarness(
          onBudgetSaved: (_) async {
            saves++;
          },
        ),
      );
      await tester.tap(find.text('Orçamento'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextFormField).last);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).last)
            .focusNode
            .hasFocus,
        isFalse,
      );
      expect(saves, 0);
      expect(find.byType(BottomSheet), findsOneWidget);
    },
  );

  testWidgets(
    'reduced motion opens and dismisses the native sheet without changing the task',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(const MobileFormHarness(reduced: true));
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      expect(find.text('Voltar ao registro').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Voltar ao registro'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    },
  );
}
