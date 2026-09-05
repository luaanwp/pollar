import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routing/app_router.dart';
import 'app/theme/pollar_theme.dart';
import 'app/theme/theme_mode_provider.dart';

void main() {
  runApp(const ProviderScope(child: PollarApp()));
}

class PollarApp extends ConsumerWidget {
  const PollarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pollar',
      debugShowCheckedModeBanner: false,
      theme: PollarTheme.light(),
      darkTheme: PollarTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
