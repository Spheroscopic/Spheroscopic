import 'package:Spheroscopic/panorama/select_panorama.dart';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:Spheroscopic/utils/snack_bar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void processDragAndDrop(
    List<XFile> raw, ValueNotifier<bool> isPhotoLoading, BuildContext context) {
  List<String> files = raw.map((str) => str.path).toList();
  PanoramaHandler.openPanorama(files, isPhotoLoading, context);
}

void openKoFi(BuildContext context) async {
  Uri url = Uri.parse('https://ko-fi.com/consequential');

  if (!await launchUrl(url) && context.mounted) {
    openSnackBar('Could not open url', '$url', context);
  }
}

void openGitHub(BuildContext context) async {
  Uri url = Uri.parse('https://github.com/Spheroscopic/Spheroscopic');

  if (!await launchUrl(url) && context.mounted) {
    openSnackBar('Could not open url', '$url', context);
  }
}

void sendFeedBack(BuildContext context) async {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController feedback = TextEditingController();

  if (context.mounted) {
    await showDialog<String>(
      context: context,
      dismissWithEsc: true,
      barrierDismissible: false,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(
          minWidth: 400,
          maxWidth: 600,
          minHeight: 200,
          maxHeight: 500,
        ),
        style: const ContentDialogThemeData(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We would love to hear your feedback!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(
                m.Icons.close_rounded,
                size: 24,
              ),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
        content: Column(
          children: [
            TextBox(
              placeholder: 'Name (Optional)',
              controller: name,
            ),
            const SizedBox(height: 10),
            TextBox(
              placeholder: 'Email (Optional)',
              controller: email,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextBox(
                textAlignVertical: TextAlignVertical.top,
                placeholder: 'Enter your feedback here',
                maxLines: null,
                controller: feedback,
              ),
            ),
          ],
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
                EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
            child: const Text('Send'),
            onPressed: () async {
              SentryId sentryId = await Sentry.captureMessage(
                  "Feedback from ${name.text}",
                  level: SentryLevel.info);

              if (feedback.text.isEmpty) {
                return;
              }

              final userFeedback = SentryUserFeedback(
                eventId: sentryId,
                name: name.text,
                email: email.text,
                comments: feedback.text,
              );

              await Sentry.captureUserFeedback(userFeedback);

              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

void firstTimeDialog(bool isDarkMode, BuildContext context) async {
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
            text: 'Before you start using Spheroscopic, you need to read the ',
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

              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
