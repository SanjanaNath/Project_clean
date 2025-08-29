import 'package:flutter/material.dart';

class ColorConstants{
  Color themeColor = const Color(0xFF075985);
  Color teal = Colors.teal;
  Color white = Colors.white;
  final Color tealAccent = const Color(0xFF64FFDA);

  var screenGradient =  BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white,
        Colors.white,
        Colors.teal,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
    ),
  );
}


class AppColors {
  static const Color primaryTeal = Color(0xFF00796B);
  static Color tealAccent = const Color(0xFF5EECC6);
  static Color blue = const   Color(0xFF00BCD4);
  static Color purple = const  Color(0xFF9C27B0);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color lightAccentOrange = Color(0xFFFFF1E9);
  static const Color deepBlue = Color(0xFF003366);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textMedium = Color(0xFF5C5B5B);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color red = Color(0xFFE82020);
  static const Color green = Color(0xFF4CAF50);
  static const Color blueGrey = Color(0xFF4C6A8B);
  static const Color lightBlueGrey = Color(0xFF9AB2C5);



}

