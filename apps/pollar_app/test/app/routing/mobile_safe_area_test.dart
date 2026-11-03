import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_shell.dart';

import '../../support/mobile_shell_fixture.dart';

void main() {
  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
  }

  for (final width in [590.0, 844.0]) {
    testWidgets('shell protects cutouts and gestures at $width wide', (
      tester,
    ) async {
      viewport(tester, Size(width, 390));
      tester.view.padding = const FakeViewPadding(
        left: 44,
        right: 34,
        top: 24,
        bottom: 21,
      );
      tester.view.viewPadding = const FakeViewPadding(
        left: 44,
        right: 34,
        top: 24,
        bottom: 21,
      );
      final router = createMobileShellRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(mobileShellApp(router));
      await tester.pumpAndSettle();
      final field = tester.getRect(find.byType(TextField));
      expect(field.left, greaterThanOrEqualTo(44));
      expect(field.right, lessThanOrEqualTo(width - 34));
      if (width >= 600) {
        expect(tester.getRect(find.byType(NavigationRail)).left, 44);
        expect(
          tester.getRect(find.byType(NavigationRail)).bottom,
          lessThanOrEqualTo(369),
        );
      } else {
        for (final d in appDestinations) {
          final bounds = tester.getRect(
            find.widgetWithText(NavigationDestination, d.label),
          );
          expect(bounds.left, greaterThanOrEqualTo(44));
          expect(bounds.right, lessThanOrEqualTo(width - 34));
          expect(bounds.bottom, lessThanOrEqualTo(369));
          expect(bounds.height, greaterThanOrEqualTo(48));
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'rotation and destination switching retain the form draft with safe areas',
    (tester) async {
      viewport(tester, const Size(844, 390));
      tester.view.padding = const FakeViewPadding(
        left: 44,
        right: 34,
        top: 24,
        bottom: 21,
      );
      final router = createMobileShellRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(mobileShellApp(router));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'rascunho preservado');
      final field = tester.state(find.byType(EditableText));
      tester.view.physicalSize = const Size(390, 844);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(EditableText)), same(field));
      await tester.tap(find.widgetWithText(NavigationDestination, 'Contas'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(NavigationDestination, 'Visão geral'),
      );
      await tester.pumpAndSettle();
      expect(find.text('rascunho preservado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
