import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final brightnessRef = StateProvider<Brightness>((ref) {
  return PlatformDispatcher.instance.platformBrightness;
});
