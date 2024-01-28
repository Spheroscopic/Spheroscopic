import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
//import 'package:spheroscopic/360video/360video_view.dart';
import 'package:spheroscopic/class/recentFiles.dart';
import 'package:spheroscopic/class/shared_preferences.dart';
import 'package:spheroscopic/modules/snackbar.dart';
import 'package:spheroscopic/panorama/panorama_view.dart';
import 'package:spheroscopic/riverpod/photoState.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:spheroscopic/utils/variables.dart';
import 'package:path/path.dart' as path;

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
        openPanorama(RecentFile(File(selectedFile.paths[0]!)), context, ref);
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

  static void openPanorama(RecentFile panorama, context, ref) async {
    try {
      Variables.animatedController!.reverse();
      Variables.recentlyOpened = false;

      String panPath = panorama.file.path;
      String panExt = path.extension(panPath).replaceAll(".", "").toLowerCase();
      bool isPhotoExtension = photoExtensions.contains(panExt);

      if (isPhotoExtension) {
        ref.read(appProvider.notifier).movePanToRecently(panorama);

        Navigator.push(
          context,
          FluentPageRoute(
            builder: (context) => PanoramaView(panPath),
          ),
        );
      } else {
        openSnackBar(
            title: 'Error:',
            text:
                'The selected file is not supported. Spheroscopic only supports: .jpg, .png, .dng, .tiff',
            context: context);
      }
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
