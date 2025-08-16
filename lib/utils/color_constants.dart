import 'package:flutter/material.dart';

class ColorConstants{
  Color themeColor = const Color(0xFF075985);
  Color teal = Colors.teal;
  Color white = Colors.white;


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
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color deepBlue = Color(0xFF003366);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textMedium = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0);
}