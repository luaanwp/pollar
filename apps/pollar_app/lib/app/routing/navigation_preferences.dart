import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop presentation preference, retained for this application session.
/// Viewport changes never reset it or replace the branch navigators.
final railExpandedProvider = NotifierProvider<RailExpanded, bool>(
  RailExpanded.new,
);

class RailExpanded extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
