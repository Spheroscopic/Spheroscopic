import 'dart:io';
import 'package:flutter/material.dart';

class RecentFile {
  late final Key id;
  late final File file;
  late final ResizeImage img;
  //final DateTime date = DateTime.now();

  RecentFile(this.file) {
    id = Key(file.path);
    img = ResizeImage(
      width: 320,
      height: 80,
      FileImage(file),
    );
  }
}
