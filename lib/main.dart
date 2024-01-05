import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panorama_viewer_app/photo/select_photo.dart';
import 'package:panorama_viewer_app/riverpod/photoState.dart';
import 'package:panorama_viewer_app/utils/consts.dart';
import 'package:desktop_drop/desktop_drop.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: TColor.colorOptions[0],
        useMaterial3: true,
        brightness:
            Brightness.dark, //isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final addPhotoButtonState = ref.watch(addPhotoState);

    return Builder(
      builder: (context) => Scaffold(
        body: DropTarget(
          onDragDone: (detail) {
            setState(() {
              PanoramaHandler.openPanorama(detail.files[0].path, context);
            });
          },
          onDragEntered: (detail) {
            setState(() {
              _dragging = true;
            });
          },
          onDragExited: (detail) {
            setState(() {
              _dragging = false;
            });
          },
          child: _dragging
              ? Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF141414),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 50, horizontal: 50),
                    child: DottedBorder(
                      color: TColor.colorOptions[0],
                      dashPattern: const [15, 15],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(25),
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 100,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Drop panorama file here!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  color: const Color(0xFF141414),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          size: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Select 360 panorama.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        FilledButton(
                          onPressed: addPhotoButtonState.isLoading
                              ? null
                              : () {
                                  PanoramaHandler.selectPanorama(context, ref);
                                },
                          child: addPhotoButtonState.isLoading
                              ? const SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const Text('Select panorama'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
