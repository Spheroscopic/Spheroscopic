import 'package:Spheroscopic/home/home.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart' as m;
import 'package:Spheroscopic/panorama/select_panorama.dart';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluent_ui/fluent_ui.dart';

class HomeScreen extends HookWidget {
  final List<String>? args;
  final bool isDarkMode;
  const HomeScreen(this.args, this.isDarkMode, {super.key});

  @override
  Widget build(BuildContext context) {
    final isPhotoLoading = useState(false);
    final dragging = useState(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("HomeScreen build finished");

      firstTimeDialog(isDarkMode, context);

      if (args!.isNotEmpty) {
        PanoramaHandler.openPanorama(args!, isPhotoLoading, context);
        args?.clear();
      }
    });

    return m.Scaffold(
      body: DropTarget(
        onDragDone: (detail) {
          processDragAndDrop(detail.files, isPhotoLoading, context);
        },
        onDragEntered: (detail) {
          dragging.value = true;
        },
        onDragExited: (detail) {
          dragging.value = false;
        },
        child: Mica(
          backgroundColor: Colors.transparent,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: dragging.value
                ? const DragContainer()
                : SelectContainer(isPhotoLoading, isDarkMode),
          ),
        ),
      ),
    );
  }
}

class SelectContainer extends HookWidget {
  final ValueNotifier<bool> isLoading;
  final bool isDarkMode;
  const SelectContainer(this.isLoading, this.isDarkMode, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 10,
          bottom: 10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FilledButton(
                style: const ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 13),
                  ),
                ),
                onPressed: () {
                  openKoFi(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/img/kofi-logo.png",
                      scale: 5,
                      width: 32,
                      height: 21.5,
                    ),
                    const SizedBox(width: 6),
                    const Text('Donate'),
                  ],
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
                onPressed: () {
                  openGitHub(context);
                },
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: Icon(
                  m.Icons.bug_report,
                  size: 24,
                  color: TColor.secondColorText(isDarkMode),
                ),
                onPressed: () {
                  sendFeedBack(context);
                },
              ),
              const SizedBox(width: 10),
              Text(
                appVersion,
                style: TextStyle(
                  color: TColor.secondColorText(isDarkMode),
                ),
              ),
              const SizedBox(width: 10),
            ],
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
              const SizedBox(height: 15),
              Text(
                "Select or drop panoramas here",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.mainColorText(isDarkMode),
                ),
              ),
              const SizedBox(height: 25),
              Button(
                style: const ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  ),
                ),
                onPressed: () {
                  if (!isLoading.value) {
                    PanoramaHandler.openPanorama([], isLoading, context);
                  }
                },
                child: isLoading.value
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

class DragContainer extends HookWidget {
  const DragContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        useState(m.Theme.of(context).brightness == Brightness.dark);

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
                color: TColor.mainColor(isDarkMode.value),
              ),
              const SizedBox(height: 30),
              Text(
                "Drop panoramas over here!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.mainColorText(isDarkMode.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
