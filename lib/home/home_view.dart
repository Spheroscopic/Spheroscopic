import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart' as m;
import 'package:spheroscopic/modules/snackbar.dart';
import 'package:spheroscopic/panorama/select_panorama.dart';
import 'package:spheroscopic/riverpod/photoState.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:spheroscopic/riverpod/brightness.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final List<String>? args;
  const HomeScreen(this.args, {super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> {
  late List<String> args;

  bool _dragging = false;

  @override
  void initState() {
    args = widget.args!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _dragging
                ? DragContainer(key: UniqueKey())
                : SelectContainer(key: UniqueKey()),
          ),
        ),
      ),
    );
  }
}

class SelectContainer extends ConsumerWidget {
  const SelectContainer({super.key});

  @override
  Widget build(context, ref) {
    final addPhotoButtonState = ref.watch(addPhotoState);
    bool isDarkMode = ref.watch(brightnessRef) == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  version,
                  style: TextStyle(
                    color: TColor.secondColorText(isDarkMode),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    "assets/img/github-logo.png",
                    width: 24,
                    height: 24,
                    color: TColor.secondColorText(isDarkMode),
                  ),
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://github.com/Spheroscopic/Spheroscopic');

                    if (!await launchUrl(url)) {
                      openSnackBar(
                          title: 'Error:',
                          text: 'Could not open url: $url',
                          context: context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
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
                style: const ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                ),
                onPressed: addPhotoButtonState.isLoading
                    ? null
                    : () {
                        PanoramaHandler.openPanorama([], context, ref);
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
    );
  }
}

class DragContainer extends ConsumerWidget {
  const DragContainer({super.key});

  @override
  Widget build(context, ref) {
    bool isDarkMode = ref.watch(brightnessRef) == Brightness.dark;

    return Padding(
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
                m.Icons.file_download_outlined,
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
    );
  }
}
