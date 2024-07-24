import 'package:flutter/material.dart';

const String version = 'v1.2.1';

// files
const List<String> photoExtensions = [
  'jpg',
  'jpeg',
  'jpe',
  'png',
  'dng',
  'tiff',
  'tif'
];

class TColor {
  static const List<Color> colorOptions = [
    Color(0xff6750a4), // m3BaseColor
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink
  ];

  // get theme colors
  static Color mainColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFFFFFBFF) : const Color(0xFF1C1B1E);
  }

  static Color secondColor(bool isDarkMode) {
    return isDarkMode
        ? const Color(0xFF2a282d)
        : const Color.fromARGB(255, 235, 231, 236);
  }

  static Color secondColor_selected(bool isDarkMode) {
    return isDarkMode
        ? const Color.fromARGB(255, 58, 56, 61)
        : const Color.fromARGB(255, 208, 204, 209);
  }

  static Color mainColorText(bool isDarkMode) {
    return isDarkMode ? const Color(0xFFFFFBFF) : const Color(0xFF1C1B1E);
  }

  static Color secondColorText(bool isDarkMode) {
    return isDarkMode ? const Color(0xFFCACACA) : const Color(0xFF56535c);
  }
}
