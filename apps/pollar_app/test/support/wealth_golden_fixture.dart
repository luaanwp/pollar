import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_controller.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_screen.dart';

import 'wealth_fixture.dart';

Widget wealthGoldenApp({
  bool dark = false,
  bool reduced = false,
  InMemoryWealthRepository? repository,
}) => ProviderScope(
  overrides: [
    wealthRepositoryProvider.overrideWithValue(
      repository ?? createWealthFixtureRepository(),
    ),
    wealthLedgerSourceProvider.overrideWithValue(
      const WealthFixtureLedgerSource(),
    ),
    wealthClockProvider.overrideWithValue(() => wealthFixtureNow),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    theme: PollarTheme.light(),
    darkTheme: PollarTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const Scaffold(body: WealthScreen()),
  ),
);
