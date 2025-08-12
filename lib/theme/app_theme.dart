import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color appBar = Color(0xff6C4AB6);
  static const Color background = Color(0xff232D3F);
  static const Color text = Colors.white;
  static const Color textFieldBorder = Color(0xffB9E0FF);
  static const Color success = Color(0xff66DE93);
  static const Color error = Colors.red;

  // Text styles
  static const TextStyle defaultStyle = TextStyle(
    fontFamily: 'Dongle',
    fontSize: 30,
    height: 0.8,
  );

  static TextStyle get titleLarge => defaultStyle.copyWith(fontSize: 40);
  static TextStyle get titleMedium => defaultStyle.copyWith(fontSize: 35);
  static TextStyle get bodyLarge => defaultStyle.copyWith(fontSize: 30);
  static TextStyle get bodyMedium => defaultStyle.copyWith(fontSize: 25);
  static TextStyle get bodySmall => defaultStyle.copyWith(fontSize: 18);

  // Clay text presets
  static const double defaultSpread = 6;
  static const double defaultDepth = 25;
  static const double smallDepth = 5;
  static const double mediumDepth = 15;
}
