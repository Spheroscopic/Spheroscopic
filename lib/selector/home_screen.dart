import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart' as m;
import 'package:spheroscopic/class/recentFiles.dart';
import 'package:spheroscopic/panorama/recentlyPanorama.dart';
import 'package:spheroscopic/photo/select_photo.dart';
import 'package:spheroscopic/riverpod/photoState.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:spheroscopic/utils/variables.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  //late final AnimationController _animatedController;

  @override
  void initState() {
    args = widget.args!;

    Variables.animatedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    super.initState();
  }

  @override
  void dispose() {
    Variables.animatedController!.dispose();
    super.dispose();
  }

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final addPhotoButtonState = ref.watch(addPhotoState);
    bool isDarkMode =
        ref.watch(brightnessRef) == Brightness.dark ? true : false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("HomeScreen build finished");

      if (args.isNotEmpty) {
        PanoramaHandler.openPanorama(RecentFile(File(args[0])), context, ref);
        args = [];
      }
    });

    return m.Scaffold(
      body: Builder(
        builder: (context) => DropTarget(
          onDragDone: (detail) {
            setState(() {
              PanoramaHandler.openPanorama(
                  RecentFile(File(detail.files[0].path)), context, ref);
            });
          },
          onDragEntered: (detail) {
            setState(() {
              Variables.animatedController!.reverse();
              Variables.recentlyOpened = false;

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
                        padding: const EdgeInsets.symmetric(
                            vertical: 50, horizontal: 50),
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
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Drop panorama file here!",
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
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
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Select or drop 360 panorama.",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: TColor.mainColorText(isDarkMode),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  FilledButton(
                                    onPressed: addPhotoButtonState.isLoading
                                        ? null
                                        : () {
                                            PanoramaHandler.selectPanorama(
                                                context, ref);
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
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Button(
                                    onPressed: () {
                                      setState(() {
                                        if (Variables.recentlyOpened) {
                                          Variables.animatedController!
                                              .reverse();
                                          Variables.recentlyOpened = false;
                                        } else {
                                          Variables.animatedController!
                                              .forward();
                                          Variables.recentlyOpened = true;
                                        }
                                      });
                                    },
                                    child: const Text('Recently opened'),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Animate(
                                controller: Variables.animatedController!,
                                autoPlay: false,
                                effects: [
                                  FadeEffect(
                                    duration: 400.ms,
                                    delay: 100.ms,
                                  ),
                                  const MoveEffect(
                                    begin: Offset(30, 0),
                                    end: Offset(0, 0),
                                    curve: Curves.easeOutQuad,
                                  )
                                ],
                                child: const PanoPanel(),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}