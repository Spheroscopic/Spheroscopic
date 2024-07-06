import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spheroscopic/class/recentFile.dart';
import 'package:spheroscopic/panorama/panorama_viewer.dart';
import 'package:spheroscopic/riverpod/brightness.dart';
import 'package:spheroscopic/utils/consts.dart';
//import 'package:panorama_viewer/panorama_viewer.dart';

class PanoramaView extends ConsumerStatefulWidget {
  final List<RecentFile>? panos;

  const PanoramaView(List<RecentFile> this.panos, {super.key});

  @override
  ConsumerState<PanoramaView> createState() => _PanoramaView();
}

class _PanoramaView extends ConsumerState<PanoramaView>
    with TickerProviderStateMixin {
  late List<RecentFile> panos;
  late final AnimationController animatedController;
  late RecentFile selected;

  bool isPinned = false;

  // fixes a bug with addPostFrameCallback causes the bottomPanel to dissapears after each rebuild
  bool wasBuilt = false;

  final Map<int, bool> hoverStates = {};

  @override
  void initState() {
    panos = widget.panos!;
    isPinned = panos.length > 1 ? false : true;
    selected = panos[0];
    animatedController = AnimationController(
      value: 1.0,
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    super.initState();
  }

  @override
  void dispose() {
    animatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(brightnessRef) == Brightness.dark;

    return m.Scaffold(
      body: Stack(
        children: [
          Center(
            child: PanoramaViewer(
              key: UniqueKey(),
              maxZoom: 15.0,
              child: Image(image: selected.file),
            ),
          ),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter _setState) {
              // the bottomPanel smoothly dissapears after init, just to make it look cool
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (panos.length > 1 && !isPinned && !wasBuilt) {
                  animatedController.reverse();
                  wasBuilt = true;
                }
              });

              return Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 110,
                  child: MouseRegion(
                    onEnter: (e) {
                      if (!isPinned) animatedController.forward();
                    },
                    onExit: (e) {
                      if (!isPinned) animatedController.reverse();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 25, right: 10, left: 10, bottom: 10),
                      child: Animate(
                        controller: animatedController,
                        autoPlay: false,
                        effects: [
                          FadeEffect(duration: 300.ms, delay: 100.ms),
                        ],
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment:
                                  m.MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: m.CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: const Offset(0, 4),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                    color: TColor.secondColor(isDarkMode),
                                    border: Border.all(
                                      color: TColor.secondColor_selected(
                                          isDarkMode),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isPinned
                                          ? FluentIcons.pinned_solid
                                          : FluentIcons.pinned,
                                      size: 16.0,
                                    ),
                                    onPressed: () {
                                      _setState(() {
                                        isPinned = !isPinned;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: const Offset(0, 4),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                    color: TColor.secondColor(isDarkMode),
                                    border: Border.all(
                                      color: TColor.secondColor_selected(
                                          isDarkMode),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(FluentIcons.back,
                                        size: 16.0),
                                    onPressed: () {
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            if (panos.length > 1)
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: const Offset(0, 4),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                    color: TColor.secondColor(isDarkMode),
                                    border: Border.all(
                                      color: TColor.secondColor_selected(
                                          isDarkMode),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ListView.builder(
                                    clipBehavior: Clip.antiAlias,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: panos.length,
                                    itemBuilder: (context, index) {
                                      RecentFile panorama = panos[index];

                                      Key id = panorama.id;
                                      FileImage file = panorama.file;
                                      ResizeImage img = panorama.img;
                                      String filePath = file.file.path;

                                      bool isSelected = selected.id == id;

                                      bool isHovering =
                                          hoverStates[index] ?? false;

                                      return Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: m.InkWell(
                                          onTap: () {
                                            setState(() {
                                              selected = panorama;
                                            });
                                          },
                                          onHover: (value) {
                                            if (!isSelected) {
                                              _setState(() {
                                                hoverStates[index] = value;
                                              });
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 80,
                                            padding: const EdgeInsets.all(1),
                                            transform: Matrix4.identity()
                                              ..scale(isHovering ? 1.035 : 1.0),
                                            transformAlignment:
                                                Alignment.center,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  offset: const Offset(0, 4),
                                                  blurRadius: 4,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                              color: TColor.secondColor(
                                                  isDarkMode),
                                              border: isSelected
                                                  ? Border.all(
                                                      color: Colors.purple,
                                                      width: 1,
                                                    )
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Tooltip(
                                              message: filePath,
                                              style: const TooltipThemeData(
                                                preferBelow: false,
                                                waitDuration:
                                                    Duration(seconds: 1),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  image: DecorationImage(
                                                    image: img,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
