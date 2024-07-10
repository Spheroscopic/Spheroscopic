import 'package:flutter/material.dart';

class RecentFile {
  late final Key id;
  late final FileImage file;
  late final ImageProvider thumbnail;
  //final DateTime date = DateTime.now();

  RecentFile(this.file, {int thumbnailWidth = 110, int thumbnailHeight = 80}) {
    id = Key(file.file.path);
    thumbnail = ResizeImage(
      file,
      width: thumbnailWidth,
      height: thumbnailHeight,
    );
  }
}
