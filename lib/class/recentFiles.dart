import 'dart:io';
import 'package:flutter/material.dart';

class RecentFile {
  final Key id = UniqueKey();
  late final File file;
  late final ResizeImage img;
  //final DateTime date = DateTime.now();

  RecentFile(this.file)
      : img = ResizeImage(
          width: 320,
          height: 80,
          FileImage(file),
        );
}
