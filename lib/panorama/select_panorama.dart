import 'dart:async';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:Spheroscopic/class/recentFile.dart';
import 'package:Spheroscopic/modules/snackbar.dart';
import 'package:Spheroscopic/panorama/panorama_view.dart';
import 'package:Spheroscopic/riverpod/photoState.dart';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as path;

class PanoramaHandler {
  static Future<RecentFile> _loadImage(File file) async {
    final Completer<RecentFile> completer = Completer();
    final FileImage fileImage = FileImage(file);

    fileImage.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo info, bool synchronousCall) {
            completer.complete(RecentFile(fileImage));
          }, onError: (dynamic error, StackTrace? stackTrace) {
            completer.completeError(error, stackTrace);
          }),
        );

    return completer.future;
  }

  static Future<void> openPanorama(List<String> panPath, context, ref) async {
    ref.read(addPhotoState.notifier).loading();

    if (panPath.isEmpty) {
      final List<XFile> files = await openFiles(
        acceptedTypeGroups: [
          const XTypeGroup(extensions: photoExtensions),
        ],
      );

      if (files.isNotEmpty) {
        for (var file in files) {
          panPath.add(file.path);
        }
      }
    }

    List<RecentFile> panos = [];

    for (String pano in panPath) {
      try {
        String panExt = path.extension(pano).replaceAll(".", "").toLowerCase();
        bool canOpen = photoExtensions.contains(panExt);

        if (canOpen) {
          File file = File(pano);

          if (file.existsSync()) {
            //RecentFile rf = RecentFile(FileImage(file));
            RecentFile rf = await _loadImage(file);
            print(rf.file.file.path);

            panos.add(rf);
          } else {
            openSnackBar(
                title: 'Error:',
                text:
                    'The selected file was not found. File path: ${file.path}',
                context: context);
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

    ref.read(addPhotoState.notifier).completed();
  }
}
