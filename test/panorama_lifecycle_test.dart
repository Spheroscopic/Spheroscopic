import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Spheroscopic/class/panorama_file.dart';
import 'package:Spheroscopic/panorama/panorama_view.dart';
import 'package:Spheroscopic/panorama/panorama_viewer.dart';

class DelayedPanorama extends PanoramaViewer {
  const DelayedPanorama(this.image, {super.key})
      : super(child: const m.Image(image: AssetImage('unused.png')));

  final Completer<ui.Image> image;

  @override
  PanoramaState createState() => DelayedPanoramaState();
}

class DelayedPanoramaState extends PanoramaState {
  @override
  Future<ui.Image> createTransparentImage() =>
      (widget as DelayedPanorama).image.future;
}

void main() {
  testWidgets('scene initialization can finish after the viewer closes',
      (tester) async {
    final completion = Completer<ui.Image>();
    await tester.pumpWidget(m.MaterialApp(home: DelayedPanorama(completion)));
    await tester.pump();
    final state = tester.state<PanoramaState>(find.byType(DelayedPanorama));
    expect(state.scene, isNotNull);
    await tester.pumpWidget(const m.SizedBox());

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final picture = recorder.endRecording();
    completion.complete(picture.toImageSync(1, 1));
    picture.dispose();
    await tester.pump();
    expect(state.surface, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single panorama accepts keyboard input without a scroll view',
      (tester) async {
    final selection = ValueNotifier(0);
    final panorama = RecentFile(FileImage(File('unused.jpg')),
        resolution: const Size(200, 100));
    await tester.pumpWidget(FluentApp(
      home: m.Scaffold(body: BottomPanel([panorama], selection)),
    ));
    await tester.pumpAndSettle();
    for (final key in [
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyA
    ]) {
      await tester.sendKeyEvent(key);
    }
    expect(selection.value, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const m.SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    selection.dispose();
  });

  testWidgets('queued pointer callbacks do nothing after viewer disposal',
      (tester) async {
    await tester.pumpWidget(m.MaterialApp(
      home: PanoramaViewer(onTap: (_, __, ___) {}),
    ));
    await tester.pump();
    final listener = tester
        .widgetList<m.Listener>(find.descendant(
          of: find.byType(PanoramaViewer),
          matching: find.byType(m.Listener),
        ))
        .singleWhere((listener) => listener.onPointerMove != null);
    await tester.pumpWidget(const m.SizedBox());
    listener.onPointerMove!(const PointerMoveEvent(position: Offset(30, 40)));
    listener
        .onPointerSignal!(const PointerScrollEvent(scrollDelta: Offset(0, 20)));
    listener.onPointerUp!(const PointerUpEvent());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
