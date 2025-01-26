import 'package:flutter/widgets.dart';

extension ListWidgetExtension on List<Widget> {
  List<Widget> withSpacing(double spacing) {
    if (length <= 1) return this;
    return [
      this[0],
      for (int i = 1; i < length; i++) ...[
        SizedBox(
          height: spacing,
          width: spacing,
        ),
        this[i],
      ],
    ];
  }
}
