import 'package:flutter/material.dart';

class CustomSnackBar {
  final String message;
  final String buttonText = 'Okay!';

  CustomSnackBar({
    required this.message,
  });

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      width: 400.0,
      content: Text(message),
    ));
  }
}
