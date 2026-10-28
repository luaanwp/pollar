import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';

void main() {
  Future<_HarnessState> mount(WidgetTester tester, {bool rtl = false}) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: PollarTheme.light(),
        home: _Harness(key: key, rtl: rtl),
      ),
    );
    return key.currentState!;
  }

  Offset travel(WidgetTester tester) {
    final position = tester
        .widget<Transform>(find.byKey(const Key('pollar-branch-position')))
        .transform
        .getTranslation();
    return Offset(position.x, position.y);
  }

  for (final rtl in [false, true]) {
    testWidgets('branch direction follows destination order with rtl=$rtl', (
      tester,
    ) async {
      final state = await mount(tester, rtl: rtl);
      expect(travel(tester), Offset.zero);
      state.select(2);
      await tester.pump();
      expect(travel(tester).dx, rtl ? -24 : 24);
      await tester.pump(const Duration(milliseconds: 70));
      expect(travel(tester).dx.abs(), lessThan(24));
      await tester.pumpAndSettle();
      expect(travel(tester), Offset.zero);
      state.select(0);
      await tester.pump();
      expect(travel(tester).dx, rtl ? 24 : -24);
      await tester.pumpAndSettle();
      expect(travel(tester), Offset.zero);
    });
  }

  testWidgets(
    'rapid selections keep drafts, state identities and only the current semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final state = await mount(tester);
        final initial = tester.state(find.byKey(const ValueKey('probe-0')));
        await tester.enterText(find.byType(TextField), 'rascunho');
        state.select(2);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 35));
        state.select(1);
        await tester.pump();
        expect(travel(tester).dx, -24);
        expect(find.bySemanticsLabel(RegExp('Destino 1')), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('Destino 0')), findsNothing);
        expect(find.bySemanticsLabel(RegExp('Destino 2')), findsNothing);
        state.select(0);
        await tester.pumpAndSettle();
        expect(
          tester.state(find.byKey(const ValueKey('probe-0'))),
          same(initial),
        );
        expect(find.text('rascunho'), findsOneWidget);
        expect(tester.binding.transientCallbackCount, 0);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('inactive branches cannot retain or request text focus', (
    tester,
  ) async {
    final state = await mount(tester);
    final probe = tester.state<_ProbeState>(
      find.byKey(const ValueKey('probe-0')),
    );
    probe.focus.requestFocus();
    await tester.pump();
    expect(probe.focus.hasFocus, isTrue);
    state.select(1);
    await tester.pump();
    probe.focus.requestFocus();
    await tester.pump();
    expect(probe.focus.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final accessible in [false, true]) {
    testWidgets(
      'accessibility cuts motion mid-flight without remounting (accessible=$accessible)',
      (tester) async {
        final state = await mount(tester);
        state.select(1);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        final probe = tester.state(find.byKey(const ValueKey('probe-1')));
        expect(travel(tester).dx.abs(), greaterThan(0));
        state.update(() {
          if (accessible) {
            state.accessible = true;
          } else {
            state.reduced = true;
          }
        });
        await tester.pump();
        expect(travel(tester), Offset.zero);
        expect(
          tester.state(find.byKey(const ValueKey('probe-1'))),
          same(probe),
        );
        state.select(2);
        await tester.pump();
        expect(travel(tester), Offset.zero);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }

  testWidgets(
    'ordinary updates do not restart arrival or retain hidden values',
    (tester) async {
      final state = await mount(tester);
      state.select(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final before = travel(tester);
      state.update(() => state.hidden = true);
      await tester.pump();
      expect(travel(tester), before);
      expect(find.text('Valor 1'), findsNothing);
      expect(find.text('Oculto 1'), findsOneWidget);
      await tester.pumpAndSettle();
      state.update(() => state.hidden = false);
      await tester.pump();
      expect(travel(tester), Offset.zero);
      expect(find.text('Valor 1'), findsOneWidget);
    },
  );
}

class _Harness extends StatefulWidget {
  const _Harness({super.key, required this.rtl});
  final bool rtl;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int index = 0;
  bool reduced = false;
  bool accessible = false;
  bool hidden = false;
  void select(int value) => setState(() => index = value);
  void update(VoidCallback action) => setState(action);
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: widget.rtl ? TextDirection.rtl : TextDirection.ltr,
    child: MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: reduced, accessibleNavigation: accessible),
      child: Scaffold(
        body: PollarBranchStack(
          index: index,
          children: [
            for (var i = 0; i < 3; i++)
              _Probe(key: ValueKey('probe-$i'), id: i, hidden: hidden),
          ],
        ),
      ),
    ),
  );
}

class _Probe extends StatefulWidget {
  const _Probe({super.key, required this.id, required this.hidden});
  final int id;
  final bool hidden;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  final focus = FocusNode();
  final controller = TextEditingController();
  @override
  void dispose() {
    focus.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('Destino ${widget.id}'),
      Text(widget.hidden ? 'Oculto ${widget.id}' : 'Valor ${widget.id}'),
      TextField(focusNode: focus, controller: controller),
    ],
  );
}
