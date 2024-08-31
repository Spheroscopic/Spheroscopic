import 'dart:async';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:Spheroscopic/class/recentFile.dart';
import 'package:Spheroscopic/utils/snackBar.dart';
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

  static Future<List<String>> _selectFiles() async {
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: photoExtensions),
      ],
    );

    return files.map((file) => file.path).toList();
  }

  static Future<void> _processFile(String pano, List<RecentFile> panos,
      ISentrySpan transaction, context) async {
    String panExt = path.extension(pano).replaceAll(".", "").toLowerCase();
    bool canOpen = photoExtensions.contains(panExt);

    if (canOpen) {
      File file = File(pano);
      //final file = _file.sentryTrace();

      if (file.existsSync()) {
        RecentFile rf = await _loadImage(file);
        panos.add(rf);
        transaction.status = const SpanStatus.ok();
        transaction.setData("Found", true);
        transaction.setData("Image Resolution", rf.resolution);
      } else {
        openSnackBar("The file wasn't found", pano, context);
        transaction.status = const SpanStatus.notFound();
        transaction.setData("Found", false);
      }
    } else {
      openSnackBar(
          "Spheroscopic only supports: .jpg, .png, .dng, .tiff", pano, context);
      transaction.status = SpanStatus.fromString('Not supported');
    }
  }

  static Future<void> _handleError(
      error,
      stackTrace,
      String pano,
      int amountOfProcessedPanos,
      List<String> panPath,
      ISentrySpan transaction,
      context) async {
    final p = {
      'problem with file': pano,
      'processed panos': amountOfProcessedPanos,
      'raw panos': panPath,
    };

    await Sentry.configureScope((scope) => scope.setContexts('Panoramas', p));
    await Sentry.captureException(error, stackTrace: stackTrace);

    transaction.status = SpanStatus.fromString('$error');

    openSnackBar(error.toString(), pano, context);
  }

  static Future<void> openPanorama(List<String> panPath, context, ref) async {
    ref.read(addPhotoState.notifier).loading();

    if (panPath.isEmpty) {
      panPath = await _selectFiles();
    }

    List<RecentFile> panos = [];
    final transaction = Sentry.startTransaction(
      'Panoramas',
      'Opened Panoramas',
      bindToScope: true,
      startTimestamp: DateTime.now(),
    );

    for (String pano in panPath) {
      final _transaction = transaction.startChild(
        'Read file',
        description: pano,
        startTimestamp: DateTime.now(),
      );

      try {
        await _processFile(pano, panos, _transaction, context);
        _transaction.setData("Processed", true);
      } catch (error, stackTrace) {
        String msg = error.toString();
        _transaction.setData("Processed", false);
        _transaction.setData("Error", msg);

        // Since the error is just about corrupted image it shouldn't send anything
        if (msg == "Exception: Invalid image data") {
          openSnackBar('Invalid image data', pano, context);
        } else {
          await _handleError(error, stackTrace, pano, panos.length, panPath,
              _transaction, context);
        }
      } finally {
        _transaction.finish();
      }
    }

    if (panos.isNotEmpty) {
      Sentry.metrics().gauge(
        'loaded.panoramas', // key
        value: panos.length.toDouble(), // value
      );

      Navigator.push(
        context!,
        FluentPageRoute(
          builder: (context) => PanoramaView(panos),
        ),
      );
    }

    await transaction.finish(status: const SpanStatus.ok());

    ref.read(addPhotoState.notifier).completed();
  }
}
