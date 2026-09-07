import 'package:flutter/material.dart';

class AppColors {
  static const error = Color(0xFFCF6765);
  static const warning = Color(0xFFFF6F00);

}

Color darken(Color color, [double amount = .1]) {
  final hsl = HSLColor.fromColor(color);
  final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return darker.toColor();
}
