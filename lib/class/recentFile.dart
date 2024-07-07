import 'package:flutter/material.dart';

class RecentFile {
  late final Key id;
  late final FileImage file;
  late final ResizeImage img;
  //final DateTime date = DateTime.now();

  RecentFile(this.file) {
    id = Key(file.toString());
    img = ResizeImage(
      width: 320,
      height: 80,
      file,
    );
  }
}
