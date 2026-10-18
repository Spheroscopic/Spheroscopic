import 'package:flutter/material.dart';

class RecentFile {
  late final Key id;
  late final FileImage file;
  late final ImageProvider thumbnail;
  final Size _resolution;
  //final DateTime date = DateTime.now();

  String get resolution =>
      '${_resolution.width.toInt()} x ${_resolution.height.toInt()}';

  RecentFile(this.file,
      {required Size resolution,
      int thumbnailWidth = 110,
      int thumbnailHeight = 80})
      : _resolution = resolution {
    id = Key(file.file.path);
    thumbnail = ResizeImage(
      file,
      width: thumbnailWidth,
      height: thumbnailHeight,
    );
  }
}
