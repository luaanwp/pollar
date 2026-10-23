// Isolated native catalog: no auth initialization, database or user profile.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/app/theme/theme_mode_provider.dart';
import 'package:pollar_app/features/design_system/presentation/forms_catalog_screen.dart';

void main() {
  assert(() {
    runApp(const ProviderScope(child: _CatalogApp()));
    return true;
  }(), 'The design catalog is debug-only.');
}

class _CatalogApp extends ConsumerWidget {
  const _CatalogApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: PollarTheme.light(),
    darkTheme: PollarTheme.dark(),
    themeMode: ref.watch(themeModeProvider),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const FormsCatalogScreen(),
  );
}
