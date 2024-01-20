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
import 'package:spheroscopic/utils/variables.dart';

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
      try {
        List<RecentFile> files =
            ref.read(appProvider.notifier).getRecentFiles();

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

        Variables.animatedController!.reverse();
        Variables.recentlyOpened = false;

        openPanorama(selectedFile.paths[0]!, context);
      } on FileSystemException {
        openSnackBar(
            title: 'Error:',
            text: 'The selected file cannot be opened. Check permissions.',
            context: context);
      } catch (error, stackTrace) {
        await Sentry.captureException(
          error,
          stackTrace: stackTrace,
        );

        openSnackBar(title: 'Error:', text: '$error', context: context);
      }
    }

    ref.read(addPhotoState.notifier).completed();
  }

  static void openPanorama(String panorama, context) async {
    try {
      Variables.animatedController!.reverse();
      Variables.recentlyOpened = false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaView(panorama),
        ),
      );
    } on FileSystemException {
      openSnackBar(
          title: 'Error:',
          text: 'The selected file cannot be opened. Check permissions.',
          context: context);
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

      Variables.animatedController!.reverse();
      Variables.recentlyOpened = false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaView(panorama.file.path),
        ),
      );
    } on FileSystemException {
      openSnackBar(
          title: 'Error:',
          text: 'The selected file cannot be opened. Check permissions.',
          context: context);
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );

      openSnackBar(title: 'Error:', text: '$error', context: context);
    }
  }
}
