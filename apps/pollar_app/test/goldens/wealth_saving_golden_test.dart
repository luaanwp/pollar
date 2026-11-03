import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';

import '../support/wealth_golden_fixture.dart';

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

  // Isolate this pending-write capture from preceding form captures: the
  // optional date text otherwise has order-dependent pixel differences.
  testWidgets('wealth goal saving compact', (tester) async {
    final repository = _PendingWealthRepository();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      wealthGoldenApp(repository: repository, reduced: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Casa própria');
    await tester.enterText(fields.at(1), '100.000,00');
    await tester.tap(find.text('Salvar meta'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_goal_saving_390x844.png'),
    );
    repository.complete();
    await tester.pumpAndSettle();
  });
}

class _PendingWealthRepository extends InMemoryWealthRepository {
  final _write = Completer<void>();

  @override
  Future<void> addGoal(WealthGoal goal) => _write.future;

  void complete() => _write.complete();
}
