import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:Spheroscopic/utils/snackBar.dart';
import 'package:Spheroscopic/panorama/select_panorama.dart';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends HookWidget {
  final List<String>? args;
  final bool isDarkMode;
  const HomeScreen(this.args, this.isDarkMode, {super.key});

  void startTime(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('first_time') ?? false;

    if (!firstTime && context.mounted) {
      await showDialog<String>(
        context: context,
        dismissWithEsc: false,
        builder: (context) => ContentDialog(
          title: const Text('Hey!'),
          content: RichText(
            text: TextSpan(
              text:
                  'Before you start using Spheroscopic, you need to read the ',
              style: TextStyle(
                color: TColor.secondColorText(isDarkMode),
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Terms of Use',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://spheroscopic.github.io/terms-of-use'));
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: TextStyle(
                    color: TColor.secondColorText(isDarkMode),
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://spheroscopic.github.io/privacy-policy'));
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                  text:
                      '. If you do not agree to them, please refrain from using our application.',
                  style: TextStyle(
                    color: TColor.secondColorText(isDarkMode),
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              style: const ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              child: const Text('Agree'),
              onPressed: () async {
                await prefs.setBool('first_time', true);
                Sentry.metrics().increment(
                  'first.time', // key
                  value: 1, // value
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhotoLoading = useState(false);
    final _dragging = useState(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("HomeScreen build finished");

      startTime(context);

      if (args!.isNotEmpty) {
        PanoramaHandler.openPanorama(args!, isPhotoLoading, context);
        args?.clear();
      }
    });

    return m.Scaffold(
      body: DropTarget(
        onDragDone: (detail) {
          List<String> files = [];
          for (var str in detail.files) {
            files.add(str.path);
          }
          PanoramaHandler.openPanorama(files, isPhotoLoading, context);
        },
        onDragEntered: (detail) {
          _dragging.value = true;
        },
        onDragExited: (detail) {
          _dragging.value = false;
        },
        child: Mica(
          backgroundColor: Colors.transparent,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _dragging.value
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
                    EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  ),
                ),
                onPressed: () async {
                  Uri url = Uri.parse('https://ko-fi.com/consequential');

                  if (!await launchUrl(url)) {
                    openSnackBar('Could not open url', '$url', context);
                  }
                },
                child: Row(
                  children: [
                    Image.asset(
                      "assets/img/kofi-logo.png",
                      width: 24,
                      height: 24,
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
                onPressed: () async {
                  Uri url =
                      Uri.parse('https://github.com/Spheroscopic/Spheroscopic');

                  if (!await launchUrl(url)) {
                    openSnackBar('Could not open url', '$url', context);
                  }
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
                onPressed: isLoading.value
                    ? null
                    : () {
                        PanoramaHandler.openPanorama([], isLoading, context);
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
