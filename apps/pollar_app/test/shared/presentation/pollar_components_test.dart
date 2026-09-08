import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/shared/presentation/pollar_button.dart';
import 'package:pollar_app/shared/presentation/pollar_form_controls.dart';
import 'package:pollar_app/shared/presentation/pollar_modal.dart';
import 'package:pollar_app/shared/presentation/pollar_states.dart';
import 'package:pollar_app/shared/presentation/pollar_toast.dart';

void main() {
  Widget app(Widget child) => MaterialApp(
    theme: PollarTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('button activates once and loading disables activation', (
    tester,
  ) async {
    var activations = 0;

    await tester.pumpWidget(
      app(
        PollarButton(label: 'Salvar orçamento', onPressed: () => activations++),
      ),
    );
    await tester.tap(find.text('Salvar orçamento'));
    expect(activations, 1);

    await tester.pumpWidget(
      app(
        PollarButton(
          label: 'Salvar orçamento',
          loading: true,
          onPressed: () => activations++,
        ),
      ),
    );
    await tester.tap(find.byType(PollarButton));
    expect(activations, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('form controls forward explicit values', (tester) async {
    int? selected;
    bool? checked = false;
    var enabled = false;

    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PollarSelect<int>(
                  label: 'Parcelas',
                  options: const [
                    PollarSelectOption(value: 1, label: '1 parcela'),
                    PollarSelectOption(value: 3, label: '3 parcelas'),
                  ],
                  onChanged: (value) => setState(() => selected = value),
                ),
                PollarCheckbox(
                  label: 'Conferi os valores',
                  value: checked,
                  onChanged: (value) => setState(() => checked = value),
                ),
                PollarSwitch(
                  label: 'Lembrar vencimento',
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 parcelas').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.byType(SwitchListTile));

    expect(selected, 3);
    expect(checked, isTrue);
    expect(enabled, isTrue);
  });

  testWidgets('adaptive modal uses a sheet on compact layouts', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => PollarButton(
            label: 'Abrir confirmação',
            onPressed: () => showPollarAdaptiveModal<void>(
              context: context,
              title: 'Excluir cartão?',
              description: 'Esta ação exige confirmação.',
              actions: (modalContext) => [
                PollarButton(
                  label: 'Cancelar',
                  onPressed: () => Navigator.pop(modalContext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir confirmação'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(PollarDecisionDialog), findsNothing);
    expect(find.text('Excluir cartão?'), findsOneWidget);
  });

  testWidgets('adaptive modal uses a dialog on wide layouts', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => PollarIconButton(
            icon: LucideIcons.trash2,
            label: 'Excluir cartão',
            onPressed: () => showPollarAdaptiveModal<void>(
              context: context,
              title: 'Excluir cartão?',
              description: 'Esta ação exige confirmação.',
              actions: (_) => const [],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Excluir cartão'));
    await tester.pumpAndSettle();

    expect(find.byType(PollarDecisionDialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('toast and error state expose their recovery actions', (
    tester,
  ) async {
    var recovered = false;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PollarErrorState(
                title: 'Falha ao carregar',
                message: 'Tente novamente.',
                actionLabel: 'Carregar novamente',
                onRetry: () => recovered = true,
              ),
              PollarButton(
                label: 'Mostrar aviso',
                onPressed: () => showPollarToast(
                  context,
                  message: 'Transação excluída.',
                  actionLabel: 'Desfazer',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Carregar novamente'));
    await tester.tap(find.text('Mostrar aviso'));
    await tester.pump();

    expect(recovered, isTrue);
    expect(find.text('Transação excluída.'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);
  });
}
