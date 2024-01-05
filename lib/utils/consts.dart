import 'package:flutter/material.dart';

// files
const List<String> photoExtensions = [
  'jpg',
];

class TColor {
  static const Color m3BaseColor = Color(0xff6750a4);

  static const List<Color> colorOptions = [
    m3BaseColor,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink
  ];

  static const List<String> colorText = <String>[
    "purple",
    "blue",
    "teal",
    "green",
    "yellow",
    "orange",
    "pink",
  ];

  // get theme colors
  static Color mainColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1C1B1E) : const Color(0xFFFFFBFF);
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
