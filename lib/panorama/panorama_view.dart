import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panorama_viewer_app/panorama/panorama_viewer.dart';
//import 'package:panorama_viewer/panorama_viewer.dart';

class PanoramaView extends ConsumerStatefulWidget {
  final String? photo;

  const PanoramaView(String this.photo, {super.key});

  @override
  ConsumerState<PanoramaView> createState() => _PanoramaView();
}

class _PanoramaView extends ConsumerState<PanoramaView> {
  late String photoPath;

  @override
  void initState() {
    photoPath = widget.photo!;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        body: Stack(
          children: [
            Center(
              child: PanoramaViewer(
                key: UniqueKey(),
                maxZoom: 15.0,
                child: Image.file(File(photoPath)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  label: const Text('Back'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
