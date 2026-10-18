import 'dart:async';

import 'package:flutter/painting.dart';

/// Resolves one frame and detaches from the stream on success or failure.
/// The caller owns the returned ImageInfo and must dispose it.
Future<ImageInfo> resolveImageOnce(ImageProvider provider) async {
  final stream = provider.resolve(const ImageConfiguration());
  final completer = Completer<ImageInfo>();
  final listener = ImageStreamListener((info, _) {
    if (completer.isCompleted) {
      info.dispose();
    } else {
      completer.complete(info);
    }
  }, onError: (Object error, StackTrace? stackTrace) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  });

  try {
    stream.addListener(listener);
    return await completer.future;
  } finally {
    stream.removeListener(listener);
  }
}
