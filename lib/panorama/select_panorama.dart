import 'dart:async';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:Spheroscopic/class/panorama_file.dart';
import 'package:Spheroscopic/utils/snack_bar.dart';
import 'package:Spheroscopic/panorama/panorama_view.dart';
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

  static Future<List<String>> _selectFiles() async {
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: photoExtensions),
      ],
    );

    return files.map((file) => file.path).toList();
  }

  static Future<void> openPanorama(
      List<String> panPath, status, context) async {
    status.value = true;

    if (panPath.isEmpty) {
      panPath = await _selectFiles();
    }

    List<RecentFile> processedPanos = [];

    DateTime startProcessing = DateTime.now();
    final panoramas_transaction = Sentry.startTransaction(
      'Panoramas',
      'Opened Panoramas',
      bindToScope: true,
      startTimestamp: startProcessing,
    );

    for (String pano in panPath) {
      final file_transaction = panoramas_transaction.startChild(
        'Read file',
        description: pano,
        startTimestamp: DateTime.now(),
      );

      try {
        String panExt = path.extension(pano).replaceAll(".", "").toLowerCase();
        bool canOpen = photoExtensions.contains(panExt);

        if (canOpen) {
          File file = File(pano);
          //final file = _file.sentryTrace();

          if (file.existsSync()) {
            RecentFile rf = await _loadImage(file);
            processedPanos.add(rf);
            panoramas_transaction.status = const SpanStatus.ok();
            panoramas_transaction.setData("Found", true);
            panoramas_transaction.setData("Image Resolution", rf.resolution);
          } else {
            openSnackBar("The file wasn't found", pano, context);
            panoramas_transaction.status = const SpanStatus.notFound();
            panoramas_transaction.setData("Found", false);
          }
        } else {
          openSnackBar("Spheroscopic only supports: .jpg, .png, .dng, .tiff",
              pano, context);
          panoramas_transaction.status = SpanStatus.fromString('Not supported');
        }

        file_transaction.setData("Processed", true);
      } catch (error, stackTrace) {
        String msg = error.toString();
        file_transaction.setData("Processed", false);
        file_transaction.setData("Error", msg);

        // Since the error is just about corrupted image it shouldn't be sent
        if (msg == "Exception: Invalid image data") {
          openSnackBar('Invalid image data', pano, context);
        } else {
          final p = {
            'problem with file': pano,
            'processed panos': processedPanos.length,
            'raw panos': panPath,
          };

          await Sentry.configureScope(
              (scope) => scope.setContexts('Panoramas', p));
          await Sentry.captureException(error, stackTrace: stackTrace);

          panoramas_transaction.status = SpanStatus.fromString('$error');

          openSnackBar(error.toString(), pano, context);
        }
      } finally {
        file_transaction.finish();
      }
    }

    if (processedPanos.isNotEmpty) {
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

      await panoramas_transaction.finish(status: const SpanStatus.ok());
    } else {
      panoramas_transaction.status =
          SpanStatus.fromString('No panoramas found');
    }

    status.value = false;
  }
}
