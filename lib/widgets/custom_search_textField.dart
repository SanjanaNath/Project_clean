import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double height;
  final double width;
  final double fontSize;
  final String fontFamily;
  final Color borderColor;
  final Color iconColor;
  final Color fillColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  const SearchTextField({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search',
    this.height = 50,
    this.width = 200,
    this.fontSize = 14,
    this.fontFamily = 'railLight',
    this.borderColor = Colors.white,
    this.iconColor = Colors.blue,
    this.fillColor = Colors.white,
    this.borderRadius = 20,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextFormField(
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 3, color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          filled: true,
          fillColor: fillColor,
          suffixIcon: Icon(Icons.search, color: iconColor),
          hintText: hintText,
          contentPadding: contentPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}