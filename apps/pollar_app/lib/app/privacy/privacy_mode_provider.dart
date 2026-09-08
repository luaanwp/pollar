import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide privacy mode for financial values shown on shared surfaces.
///
/// Persistence belongs to the future preferences data layer. Keeping the
/// state here lets every balance use the same source of truth today.
final privacyModeProvider = NotifierProvider<PrivacyModeNotifier, bool>(
  PrivacyModeNotifier.new,
);

class PrivacyModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void set(bool hidden) => state = hidden;
}
