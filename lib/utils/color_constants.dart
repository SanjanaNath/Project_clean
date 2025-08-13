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