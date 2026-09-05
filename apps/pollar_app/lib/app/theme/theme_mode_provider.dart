import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide theme mode. Defaults to the platform setting; the top-bar toggle
/// overrides it. A persisted preference replaces this in the settings feature.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;

  /// Flips between light and dark based on the currently resolved brightness.
  void toggle({required bool isDark}) =>
      state = isDark ? ThemeMode.light : ThemeMode.dark;
}
