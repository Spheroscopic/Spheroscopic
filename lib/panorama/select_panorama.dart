import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:Spheroscopic/class/panorama_file.dart';
import 'package:Spheroscopic/utils/snack_bar.dart';
import 'package:Spheroscopic/panorama/panorama_view.dart';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:Spheroscopic/utils/resolve_image_once.dart';

class PanoramaHandler {
  static Future<RecentFile> _loadImage(File file) async {
    final FileImage fileImage = FileImage(file);
    final info = await resolveImageOnce(fileImage);
    try {
      return RecentFile(fileImage,
          resolution:
              Size(info.image.width.toDouble(), info.image.height.toDouble()));
    } finally {
      info.dispose();
    }
  }

  static Future<List<String>> _selectFiles() async {
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: photoExtensions),
      ],
    );

    return files.map((file) => file.path).toList();
  }

  static Future<void> openPanorama(List<String> panPath,
      ValueNotifier<bool> status, BuildContext context) async {
    if (!context.mounted || status.value) return;
    status.value = true;
    try {
      if (panPath.isEmpty) {
        panPath = await _selectFiles();
      }
      if (!context.mounted || panPath.isEmpty) return;

      List<RecentFile> processedPanos = [];

      DateTime startProcessing = DateTime.now();
      final panoramasTransaction = Sentry.startTransaction(
        'Panoramas',
        'Opened Panoramas',
        bindToScope: true,
        startTimestamp: startProcessing,
      );
      try {
        for (String pano in panPath) {
          if (!context.mounted) return;
          final fileTransaction = panoramasTransaction.startChild(
            'Read file',
            description: pano,
            startTimestamp: DateTime.now(),
          );

          try {
            String panExt =
                path.extension(pano).replaceAll(".", "").toLowerCase();
            bool canOpen = photoExtensions.contains(panExt);

            if (canOpen) {
              File file = File(pano);
              //final file = _file.sentryTrace();

              if (file.existsSync()) {
                RecentFile rf = await _loadImage(file);
                if (!context.mounted) return;
                processedPanos.add(rf);
                panoramasTransaction.status = const SpanStatus.ok();
                panoramasTransaction.setData("Found", true);
                panoramasTransaction.setData("Image Resolution", rf.resolution);
              } else {
                openSnackBar("The file wasn't found", pano, context);
                panoramasTransaction.status = const SpanStatus.notFound();
                panoramasTransaction.setData("Found", false);
              }
            } else {
              openSnackBar(
                  "Spheroscopic only supports: .jpg, .png, .dng, .tiff",
                  pano,
                  context);
              panoramasTransaction.status =
                  SpanStatus.fromString('Not supported');
            }

            fileTransaction.setData("Processed", true);
          } catch (error, stackTrace) {
            String msg = error.toString();
            fileTransaction.setData("Processed", false);
            fileTransaction.setData("Error", msg);

            // Since the error is just about corrupted image it shouldn't be sent
            if (msg == "Exception: Invalid image data") {
              if (context.mounted) {
                openSnackBar('Invalid image data', pano, context);
              }
            } else {
              final p = {
                'problem with file': pano,
                'processed panos': processedPanos.length,
                'raw panos': panPath,
              };

              await Sentry.configureScope(
                  (scope) => scope.setContexts('Panoramas', p));
              await Sentry.captureException(error, stackTrace: stackTrace);

              panoramasTransaction.status = SpanStatus.fromString('$error');

              if (context.mounted) {
                openSnackBar(error.toString(), pano, context);
              }
            }
          } finally {
            fileTransaction.finish();
          }
        }

        if (context.mounted && processedPanos.isNotEmpty) {
          DateTime endProcessing = DateTime.now();
          Duration duration = endProcessing.difference(startProcessing);

          Sentry.metrics().distribution(
            'loading.panoramas.duration', // key
            value: duration.inMilliseconds.toDouble(), // value
            unit: DurationSentryMeasurementUnit.milliSecond,
          );

          Sentry.metrics().gauge(
            'loaded.panoramas', // key
            value: processedPanos.length.toDouble(), // value
          );

          Navigator.push(
            context,
            FluentPageRoute(
              builder: (context) => PanoramaView(processedPanos),
            ),
          );

          panoramasTransaction.status = const SpanStatus.ok();
        } else {
          panoramasTransaction.status =
              SpanStatus.fromString('No panoramas found');
        }
      } finally {
        await panoramasTransaction.finish();
      }
    } finally {
      if (context.mounted) status.value = false;
    }
  }
}
