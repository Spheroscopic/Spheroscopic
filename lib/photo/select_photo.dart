import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:panorama_viewer_app/modules/snackbar.dart';
import 'package:panorama_viewer_app/panorama/panorama_view.dart';
import 'package:panorama_viewer_app/riverpod/photoState.dart';
import 'package:panorama_viewer_app/utils/consts.dart';

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
      openPanorama(selectedFile.paths[0]!, context);
    }

    ref.read(addPhotoState.notifier).completed();
  }

  static void openPanorama(String panorama, context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaView(panorama),
        ),
      );
    } catch (error, stackTrace) {
      /* await Sentry.captureException(
          error,
          stackTrace: stackTrace,
        ); */

      CustomSnackBar(message: 'Error: $error').show(context);
    }
  }
}
