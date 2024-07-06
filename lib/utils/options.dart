import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:spheroscopic/class/recentFile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Options {
  // current platform: true - windows; false - mac
  static bool currentPlatform() {
    return Platform.isWindows ? true : false;
  }
}

Future<void> initFunc(Brightness brightness) async {
  await Window.setEffect(
    effect: WindowEffect.mica,
    dark: brightness == Brightness.dark ? true : false,
  );
}

enum Settings_keys {
  recentFiles,
}

class Settings extends ChangeNotifier {
  Settings(this._prefs);

  final SharedPreferences _prefs;

  List<RecentFile> getRecentFiles() {
    List<String> filePaths =
        _prefs.getStringList(Settings_keys.recentFiles.name) ?? [];

    List<RecentFile> recentFiles = filePaths
        .map((filePath) => RecentFile(FileImage(File(filePath))))
        .toList();

    return recentFiles;
  }

  void setRecentFiles(RecentFile newRecentFile) {
    List<RecentFile> currentRecentFiles = getRecentFiles();
    currentRecentFiles.add(newRecentFile);

    List<String> filePaths =
        currentRecentFiles.map((file) => file.file.file.path).toList();

    _prefs.setStringList(Settings_keys.recentFiles.name, filePaths);

    notifyListeners();
  }

  void setAllRecentFiles(List<RecentFile> newRecentFile) {
    List<String> filePaths =
        newRecentFile.map((file) => file.file.file.path).toList();

    _prefs.setStringList(Settings_keys.recentFiles.name, filePaths);
  }

  void deleteRecentFile(Key fileid) {
    List<RecentFile> currentRecentFiles = getRecentFiles();

    int indexToRemove =
        currentRecentFiles.indexWhere((file) => file.id == fileid);

    if (indexToRemove != -1) {
      currentRecentFiles.removeAt(indexToRemove);

      List<String> filePaths =
          currentRecentFiles.map((file) => file.file.file.path).toList();

      _prefs.setStringList(Settings_keys.recentFiles.name, filePaths);

      notifyListeners();
    }
  }

  void deleteAllRecentFiles() {
    _prefs.clear();

    notifyListeners();
  }

  void movePanToRecently(RecentFile panorama) {
    List<RecentFile> currentFiles = getRecentFiles();

    int indexToMove = currentFiles.indexWhere((file) => file.id == panorama.id);

    if (indexToMove != -1) {
      RecentFile panorama = currentFiles[indexToMove];

      currentFiles.removeAt(indexToMove);
      currentFiles.add(panorama);
    } else {
      if (currentFiles.length == 10) {
        currentFiles.removeAt(0); // delete the old one
      }

      currentFiles.add(panorama);
    }

    List<String> filePaths =
        currentFiles.map((file) => file.file.file.path).toList();

    _prefs.setStringList(Settings_keys.recentFiles.name, filePaths);

    notifyListeners();
  }
}
