import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart' as m;
import 'package:spheroscopic/panorama/select_panorama.dart';
import 'package:spheroscopic/riverpod/photoState.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:spheroscopic/riverpod/brightness.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final List<String>? args;
  const HomeScreen(this.args, {super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late List<String> args;

  @override
  void initState() {
    args = widget.args!;

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
    bool isDarkMode = ref.watch(brightnessRef) == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("HomeScreen build finished");

      if (args.isNotEmpty) {
        PanoramaHandler.openPanorama(args, context, ref);
        args = [];
      }
    });

    return m.Scaffold(
      body: DropTarget(
        onDragDone: (detail) {
          List<String> files = [];
          for (var str in detail.files) {
            files.add(str.path);
          }
          PanoramaHandler.openPanorama(files, context, ref);
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
        child: Mica(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              _dragging
                  ? Padding(
                      padding: const EdgeInsets.all(50),
                      child: DottedBorder(
                        color: TColor.colorOptions[0],
                        dashPattern: const [15, 15],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(25),
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                m.Icons.upload_file,
                                size: 100,
                                color: TColor.mainColor(isDarkMode),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                "Drop panoramas over here!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.mainColorText(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  m.Icons.upload_file,
                                  size: 100,
                                  color: TColor.mainColor(isDarkMode),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  "Select or drop panoramas here",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.mainColorText(isDarkMode),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                FilledButton(
                                  onPressed: addPhotoButtonState.isLoading
                                      ? null
                                      : () {
                                          PanoramaHandler.openPanorama(
                                              [], context, ref);
                                        },
                                  child: addPhotoButtonState.isLoading
                                      ? const SizedBox(
                                          height: 20.0,
                                          width: 20.0,
                                          child: Center(
                                            child: ProgressRing(),
                                          ),
                                        )
                                      : const Text('Select panorama'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
