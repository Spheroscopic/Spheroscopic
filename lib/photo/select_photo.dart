import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:spheroscopic/class/recentFiles.dart';
import 'package:spheroscopic/class/shared_preferences.dart';
import 'package:spheroscopic/modules/snackbar.dart';
import 'package:spheroscopic/panorama/panorama_view.dart';
import 'package:spheroscopic/riverpod/photoState.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PanoramaHandler {
  // Open DialogBox for selecting photos
  static void selectPanorama(context, ref) async {
    ref.read(addPhotoState.notifier).loading();

    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: photoExtensions,
      allowMultiple: false,
    );

    if (selectedFile != null) {
      List<RecentFile> files = ref.read(appProvider.notifier).getRecentFiles();

      bool inList = false;

      for (RecentFile file in files) {
        if (file.file.path == selectedFile.files[0].path) {
          inList = true;
        }
      }

      if (!inList) {
        if (files.length == 10) {
          files.removeAt(0); // delete the old one
        }

        files.add(
          RecentFile(File(selectedFile.files[0].path!)),
        );

        ref.read(appProvider.notifier).setAllRecentFiles(files);
      }

      openPanorama(selectedFile.paths[0]!, context);
    }

    ref.read(addPhotoState.notifier).completed();
  }

  static void openPanorama(String panorama, context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaView(panorama),
        ),
      );
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );

      openSnackBar(title: 'Error:', text: '$error', context: context);
    }
  }

  static void openRecentlyPanorama(RecentFile panorama, context, ref) async {
    try {
      ref.read(appProvider.notifier).movePanoramaToTop(panorama.id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaView(panorama.file.path),
        ),
      );
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );

      openSnackBar(title: 'Error:', text: '$error', context: context);
    }
  }
}
