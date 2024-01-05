import 'dart:io';

class Options {
  // current platform: true - windows; false - mac
  static bool currentPlatform() {
    return Platform.isWindows ? true : false;
  }
}
