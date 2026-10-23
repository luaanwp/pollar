import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ignore invisible line-break opportunities, retaining exact visible money.
Finder findMoneyText(String exact) => find.byWidgetPredicate(
  (widget) => widget is Text && widget.data?.replaceAll('\u200B', '') == exact,
  description: 'exact visible amount $exact',
);
