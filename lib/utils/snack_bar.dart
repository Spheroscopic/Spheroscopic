import 'package:fluent_ui/fluent_ui.dart';

void openSnackBar(String title, String text, BuildContext context) async {
  await displayInfoBar(context, builder: (context, close) {
    return InfoBar(
      title: Text(title),
      content: Text(text),
      action: IconButton(
        icon: const Icon(FluentIcons.clear),
        onPressed: close,
      ),
      severity: InfoBarSeverity.error,
    );
  });
}
