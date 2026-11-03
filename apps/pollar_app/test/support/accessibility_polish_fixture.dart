import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/shared/presentation/pollar_button.dart';
import 'package:pollar_app/shared/presentation/pollar_modal.dart';
import 'package:pollar_app/shared/presentation/pollar_states.dart';

Widget polishApp({bool dark = false, Widget? child}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: dark ? PollarTheme.dark() : PollarTheme.light(),
  locale: const Locale('pt', 'BR'),
  supportedLocales: const [Locale('pt', 'BR')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(body: child ?? const SizedBox()),
);

class PolishControlGallery extends StatelessWidget {
  const PolishControlGallery({
    super.key,
    required this.primaryFocus,
    required this.ghostFocus,
  });
  final FocusNode primaryFocus;
  final FocusNode ghostFocus;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Controles', style: Theme.of(context).textTheme.headlineMedium),
      for (final variant in PollarButtonVariant.values) ...[
        const SizedBox(height: 24),
        Text(switch (variant) {
          PollarButtonVariant.primary => 'Principal',
          PollarButtonVariant.secondary => 'Secundário',
          PollarButtonVariant.ghost => 'Discreto',
          PollarButtonVariant.danger => 'Destrutivo',
        }, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            PollarButton(
              label: 'Disponível',
              variant: variant,
              adaptiveHeight: true,
              focusNode: variant == PollarButtonVariant.primary
                  ? primaryFocus
                  : variant == PollarButtonVariant.ghost
                  ? ghostFocus
                  : null,
              onPressed: () {},
            ),
            PollarButton(
              label: 'Indisponível',
              variant: variant,
              adaptiveHeight: true,
              onPressed: null,
            ),
            PollarButton(
              label: 'Processando',
              variant: variant,
              adaptiveHeight: true,
              loading: true,
              onPressed: () {},
            ),
          ],
        ),
      ],
      const SizedBox(height: 24),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          PollarIconButton(
            label: 'Ocultar valores',
            icon: LucideIcons.eye,
            onPressed: () {},
          ),
          const PollarIconButton(
            label: 'Sincronização indisponível',
            icon: LucideIcons.refreshCw,
            onPressed: null,
          ),
        ],
      ),
    ],
  );
}

Widget polishRecovery() => PollarErrorState(
  title: 'Não foi possível carregar',
  message:
      'Os registros continuam salvos. Tente carregar as informações novamente.',
  actionLabel: 'Carregar informações novamente',
  onRetry: () {},
);

Widget polishModalLauncher(FocusNode focus) => Builder(
  builder: (context) => Center(
    child: PollarButton(
      label: 'Abrir confirmação',
      onPressed: () => showPollarAdaptiveModal<void>(
        context: context,
        title: 'Confirmar alteração?',
        description: 'Confira as informações antes de continuar.',
        actions: (modalContext) => [
          PollarButton(
            label: 'Voltar',
            variant: PollarButtonVariant.ghost,
            adaptiveHeight: true,
            onPressed: () => Navigator.of(modalContext).pop(),
          ),
          PollarButton(
            label: 'Confirmar alteração',
            focusNode: focus,
            adaptiveHeight: true,
            onPressed: () => Navigator.of(modalContext).pop(),
          ),
        ],
      ),
    ),
  ),
);
