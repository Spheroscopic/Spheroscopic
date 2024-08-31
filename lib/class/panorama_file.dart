import 'package:flutter/material.dart';

class RecentFile {
  late final Key id;
  late final FileImage file;
  late final ImageProvider thumbnail;
  late final Size _resolution;
  //final DateTime date = DateTime.now();

  String get resolution =>
      '${_resolution.width.toInt()} x ${_resolution.height.toInt()}';

  RecentFile(this.file, {int thumbnailWidth = 110, int thumbnailHeight = 80}) {
    id = Key(file.file.path);
    thumbnail = ResizeImage(
      file,
      width: thumbnailWidth,
      height: thumbnailHeight,
    );

    file.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        _resolution = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
      }),
    );
  }
}
