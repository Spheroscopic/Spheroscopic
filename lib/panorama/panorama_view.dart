import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
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

  int selectedIndex = 0;

  Key hovered = UniqueKey();

  bool isPinned = false;

  // fixes a bug with addPostFrameCallback causes the bottomPanel to dissapears after each rebuild
  bool wasBuilt = false;

  late ScrollController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    panos = widget.panos!;

    isPinned = panos.length > 1 ? false : true;

    animatedController = AnimationController(
      value: 1.0,
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _focusNode = FocusNode();
    _controller = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    animatedController.dispose();

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    _focusNode.dispose();
    _controller.dispose();

    for (var pano in panos) {
      pano.file.evict();
      pano.thumbnail.evict();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext cotext) {
    bool isDarkMode = ref.watch(brightnessRef) == Brightness.dark;

    return m.Scaffold(
      body: KeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (value) {
          if (_controller.position.outOfRange) {
            return;
          }
          if (value is KeyUpEvent) {
            return;
          }

          final offset = _controller.offset;
          final minExtent = _controller.position.minScrollExtent;
          final maxExtent = _controller.position.maxScrollExtent;

          if (value.physicalKey == PhysicalKeyboardKey.arrowLeft) {
            if (offset > minExtent) {
              double oLeft = offset - minExtent;
              double dec = oLeft > 50 ? 50 : oLeft;

              _controller.animateTo(offset - dec,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear);
            }

            if (selectedIndex > 0) {
              setState(() {
                selectedIndex--;
              });
            }
          }

          if (value.physicalKey == PhysicalKeyboardKey.arrowRight) {
            if (offset < maxExtent) {
              double oLeft = maxExtent - offset;
              double add = oLeft > 50 ? 50 : oLeft;

              _controller.animateTo(offset + add,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear);
            }

            if (selectedIndex < panos.length - 1) {
              setState(() {
                selectedIndex++;
              });
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: PanoramaViewer(
                key: UniqueKey(),
                maxZoom: 15.0,
                child: Image(image: panos[selectedIndex].file),
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
                                      controller: _controller,
                                      itemCount: panos.length,
                                      itemBuilder: (context, index) {
                                        RecentFile panorama = panos[index];

                                        Key id = panorama.id;
                                        FileImage file = panorama.file;
                                        ImageProvider img = panorama.thumbnail;
                                        String filePath = file.file.path;

                                        bool isSelected =
                                            selectedIndex == index;
                                        bool isHovering = hovered == id;

                                        return Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: m.InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                              });
                                            },
                                            onHover: (value) {
                                              if (!isSelected) {
                                                _setState(() {
                                                  hovered =
                                                      value ? id : UniqueKey();
                                                });
                                              }
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              width: 80,
                                              padding: const EdgeInsets.all(1),
                                              transform: Matrix4.identity()
                                                ..scale(
                                                    isHovering ? 1.035 : 1.0),
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
                                                        BorderRadius.circular(
                                                            4),
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
      ),
    );
  }
}
