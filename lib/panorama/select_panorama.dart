import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:spheroscopic/class/recentFile.dart';
import 'package:spheroscopic/riverpod/settings.dart';
import 'package:spheroscopic/modules/snackbar.dart';
import 'package:spheroscopic/panorama/panorama_view.dart';
import 'package:spheroscopic/riverpod/photoState.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as path;

class PanoramaHandler {
  // Open DialogBox for selecting photos
  static void selectPanorama(context, ref) async {
    ref.read(addPhotoState.notifier).loading();

    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: photoExtensions,
      allowMultiple: true,
    );

    if (selectedFile != null) {
      try {
        openPanorama(selectedFile.paths.cast<String>(), context, ref);
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

  static void openPanorama(List<String> panPath, context, ref) async {
    List<RecentFile> panos = [];

    for (String pano in panPath) {
      try {
        String panExt = path.extension(pano).replaceAll(".", "").toLowerCase();
        bool canOpen = photoExtensions.contains(panExt);

        if (canOpen) {
          File file = File(pano);

          if (file.existsSync()) {
            RecentFile rf = RecentFile(FileImage(file));

            ref.read(appProvider.notifier).movePanToRecently(rf);
            panos.add(rf);
          } else {
            openSnackBar(
                title: 'Error:',
                text:
                    'The selected file was not found. File path: ${file.path}',
                context: context);

            ref
                .read(appProvider.notifier)
                .deleteRecentFile(FileImage(file).toString());
          }
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

    if (panos.isNotEmpty) {
      Navigator.push(
        context,
        FluentPageRoute(
          builder: (context) => PanoramaView(panos),
        ),
      );
    }
  }
}
