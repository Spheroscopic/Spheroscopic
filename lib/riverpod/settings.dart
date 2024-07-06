import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:spheroscopic/class/recentFile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  List<RecentFile> checkAllFilesAndGet() {
    List<RecentFile> currentFiles = getRecentFiles();

    List<RecentFile> checkedFiles = [];

    for (RecentFile file in currentFiles) {
      if (file.file.file.existsSync()) {
        checkedFiles.add(file);
      }
    }

    setAllRecentFiles(checkedFiles);

    return checkedFiles;
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  return throw UnimplementedError();
});

// provider to work with AppTheme
final appProvider = ChangeNotifierProvider((ref) {
  return Settings(ref.watch(sharedPreferencesProvider));
});
