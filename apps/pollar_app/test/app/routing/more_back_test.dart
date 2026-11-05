import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/features/settings/presentation/more_screen.dart';
import 'package:pollar_app/main.dart';

void main() {
  for (final width in [390.0, 1200.0]) {
    for (final destination in [
      'Relatórios',
      'Patrimônio',
      'Sincronização',
      'Dados e backup',
      'Preferências',
    ]) {
      testWidgets('$destination has a visible return to More at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const ProviderScope(child: PollarApp()));
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router = container.read(routerProvider);
        router.go('/more');
        await tester.pumpAndSettle();
        expect(find.byTooltip('Voltar'), findsNothing);
        await tester.scrollUntilVisible(
          find.text(destination),
          200,
          scrollable: find
              .descendant(
                of: find.byType(MoreScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(destination));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Voltar'), findsOneWidget);
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/more');
        expect(find.byType(MoreScreen), findsOneWidget);
        expect(find.byTooltip('Voltar'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
