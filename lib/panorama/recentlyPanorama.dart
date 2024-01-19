import 'package:fluent_ui/fluent_ui.dart';
//import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spheroscopic/class/recentFiles.dart';
import 'package:spheroscopic/class/shared_preferences.dart';
import 'package:spheroscopic/photo/select_photo.dart';
import 'package:spheroscopic/riverpod/brightness.dart';
import 'package:spheroscopic/utils/consts.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
//import 'package:intl/intl.dart';

class PanoPanel extends ConsumerStatefulWidget {
  const PanoPanel({super.key});

  @override
  ConsumerState<PanoPanel> createState() => _PanoPanel();
}

class _PanoPanel extends ConsumerState<PanoPanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<RecentFile> _checkFiles(List<RecentFile> files, ref) {
    List<RecentFile> recentFiles = [];

    for (RecentFile file in files) {
      if (file.file.existsSync()) {
        recentFiles.add(file);
      }
    }

    ref.read(appProvider.notifier).setAllRecentFiles(recentFiles);

    return recentFiles;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        ref.watch(brightnessRef) == Brightness.dark ? true : false;

    List<RecentFile> recentFiles =
        _checkFiles(ref.read(appProvider).getRecentFiles(), ref);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TColor.secondColor(isDarkMode),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Button(
                  onPressed: () {
                    setState(() {
                      ref.read(appProvider.notifier).deleteAllRecentFile();
                    });
                  },
                  child: const Text('Clear all'),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                clipBehavior: Clip.antiAlias,
                itemCount: recentFiles.length,
                itemBuilder: (context, index) {
                  // (recentFiles.length - 1) - index  : needs for inversive list (reverse is for inversed scroll)

                  RecentFile panorama =
                      recentFiles[(recentFiles.length - 1) - index];

                  //Key id = panorama.id;
                  File file = panorama.file;
                  ResizeImage img = panorama.img;
                  //String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(panorama.date);

                  String filePath = file.path;
                  String fileName = path.basename(file.path);

                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 230,
                            child: Tooltip(
                              message: filePath,
                              style: const TooltipThemeData(
                                preferBelow: false,
                                waitDuration: Duration(seconds: 1),
                              ),
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Container(
                            width: 230,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: img,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Button(
                            onPressed: () {
                              setState(() {
                                PanoramaHandler.openRecentlyPanorama(
                                    panorama, context, ref);
                              });
                            },
                            child: const Text(
                              'Open',
                            ),
                          ),
                          /* const SizedBox(
                            height: 10,
                          ),
                          const m.Divider(
                            indent: 0,
                            thickness: 0.2,
                            height: 0.1,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: 230,
                            child: Text(
                              date.toString(),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: TColor.secondColorText(isDarkMode),
                              ),
                            ),
                          ), */
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
