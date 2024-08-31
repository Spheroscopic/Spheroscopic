import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Spheroscopic/class/panorama_file.dart';
import 'package:Spheroscopic/panorama/panorama_viewer.dart';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class IconContainer extends StatelessWidget {
  final Icon icon;
  final VoidCallback func;
  final bool isDarkMode;

  const IconContainer({
    super.key,
    required this.icon,
    required this.func,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
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
          color: TColor.secondColor_selected(isDarkMode),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          icon: icon,
          onPressed: func,
        ),
      ),
    );
  }
}

class PanoramaView extends HookWidget {
  final List<RecentFile> panos;
  const PanoramaView(this.panos, {super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    return m.Scaffold(
      body: Stack(
        children: [
          Center(
            child: PanoramaViewer(
              key: UniqueKey(),
              maxZoom: 15.0,
              child: Image(image: panos[selectedIndex.value].file),
            ),
          ),
          BottomPanel(panos, selectedIndex),
        ],
      ),
    );
  }
}

class BottomPanel extends HookWidget {
  final List<RecentFile> panos;
  final ValueNotifier<int> selectedIndex;

  BottomPanel(this.panos, this.selectedIndex, {super.key});

  final AnimationController animatedController = useAnimationController(
    initialValue: 1.0,
    duration: const Duration(seconds: 0),
  );

  final _controller = useScrollController();
  final _focusNode = useFocusNode();

  @override
  Widget build(BuildContext context) {
    final isPinned = useState(panos.length == 1);

    final hovered = useState(UniqueKey() as Key);
    final isAbsorbing = useState(false);

    // fixes a bug with addPostFrameCallback causes the bottomPanel to dissapear after each rebuild
    final wasBuilt = useState(false);

    // the bottomPanel smoothly dissapears after init, just to make it look cool
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (panos.length > 1 && !isPinned.value && !wasBuilt.value) {
        animatedController.reverse();
        wasBuilt.value = true;
      }
    });

    final isDarkMode =
        useState(m.Theme.of(context).brightness == Brightness.dark);

    return KeyboardListener(
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

          if (selectedIndex.value > 0) {
            selectedIndex.value -= 1;
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

          if (selectedIndex.value < panos.length - 1) {
            selectedIndex.value += 1;
          }
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 110,
          child: MouseRegion(
            onHover: (e) {
              isAbsorbing.value = false;
              if (!isPinned.value && animatedController.isDismissed) {
                animatedController.forward();
              }
            },
            onEnter: (e) {
              if (e.buttons == 1) {
                isAbsorbing.value = true;
              } else {
                isAbsorbing.value = false;
              }
            },
            onExit: (e) {
              if (e.buttons != 1) {
                isAbsorbing.value = false;
              } else {
                isAbsorbing.value = true;
              }

              if (!isPinned.value && e.buttons != 1) {
                animatedController.reverse();
              }
            },
            child: AbsorbPointer(
              absorbing: isAbsorbing.value,
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
                        mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: m.CrossAxisAlignment.end,
                        children: [
                          IconContainer(
                            icon: Icon(
                              isPinned.value
                                  ? FluentIcons.pinned_solid
                                  : FluentIcons.pinned,
                              size: 16.0,
                            ),
                            func: () {
                              isPinned.value = !isPinned.value;
                            },
                            isDarkMode: isDarkMode.value,
                          ),
                          IconContainer(
                            icon: const Icon(
                              FluentIcons.back,
                              size: 16.0,
                            ),
                            func: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            isDarkMode: isDarkMode.value,
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
                              color: TColor.secondColor(isDarkMode.value),
                              border: Border.all(
                                color: TColor.secondColor_selected(
                                    isDarkMode.value),
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
                                String filePath = panorama.file.file.path;

                                bool isSelected = selectedIndex.value == index;
                                bool isHovering = hovered.value == id;

                                return Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: m.InkWell(
                                    onTap: () {
                                      selectedIndex.value = index;
                                    },
                                    onHover: (value) {
                                      if (!isSelected) {
                                        hovered.value =
                                            value ? id : UniqueKey();
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 80,
                                      padding: const EdgeInsets.all(1),
                                      transform: Matrix4.identity()
                                        ..scale(isHovering ? 1.035 : 1.0),
                                      transformAlignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            offset: const Offset(0, 4),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                        color: TColor.secondColor(
                                            isDarkMode.value),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.purple,
                                                width: 1,
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Tooltip(
                                        message: filePath,
                                        style: const TooltipThemeData(
                                          preferBelow: false,
                                          waitDuration: Duration(seconds: 1),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            image: DecorationImage(
                                              image: panorama.thumbnail,
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
        ),
      ),
    );
  }
}
