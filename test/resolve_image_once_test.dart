import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Spheroscopic/utils/resolve_image_once.dart';

class ControlledCompleter extends ImageStreamCompleter {
  late ImageStreamListener listener;
  int listenerCount = 0;

  @override
  void addListener(ImageStreamListener value) {
    listener = value;
    listenerCount++;
    super.addListener(value);
  }

  @override
  void removeListener(ImageStreamListener value) {
    listenerCount--;
    super.removeListener(value);
  }
}

class ControlledProvider extends ImageProvider<ControlledProvider> {
  final completer = ControlledCompleter();

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream,
      ControlledProvider key, ImageErrorListener handleError) {
    stream.setCompleter(completer);
  }

  @override
  Future<ControlledProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('accepts one frame, ignores repeated callbacks, and detaches', () async {
    final provider = ControlledProvider();
    final future = resolveImageOnce(provider);
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(1, 1);
    picture.dispose();

    provider.completer.listener.onImage(ImageInfo(image: image.clone()), false);
    provider.completer.listener.onImage(ImageInfo(image: image.clone()), false);
    provider.completer.listener.onError!(
        StateError('late error'), StackTrace.current);
    final info = await future;
    expect(info.image.width, 1);
    expect(provider.completer.listenerCount, 0);
    info.dispose();
    image.dispose();
  });

  test('forwards the initial error once and detaches', () async {
    final provider = ControlledProvider();
    final future = resolveImageOnce(provider);
    final error = StateError('decode failed');
    final expectation = expectLater(future, throwsA(same(error)));
    provider.completer.listener.onError!(error, StackTrace.current);
    provider.completer.listener.onError!(error, StackTrace.current);
    await expectation;
    expect(provider.completer.listenerCount, 0);
  });
}
