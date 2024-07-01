import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spheroscopic/class/shared_preferences.dart';
import 'package:spheroscopic/selector/home_screen.dart';
import 'package:spheroscopic/utils/options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:spheroscopic/riverpod/brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String>? args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

  // Must add this line.
  await windowManager.ensureInitialized();

  // for setting minimal size of window
  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(600, 400),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  print('args: $args');

  SystemTheme.fallbackColor = const Color(0x9C0078D4);
  await SystemTheme.accentColor.load();

  Brightness brightness = PlatformDispatcher.instance.platformBrightness;
  await initFunc(brightness);

  // initialization SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://3ee13c2813e0d95f066e7bc4171d7042@o4506094609563648.ingest.sentry.io/4506524905963520';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MyApp(args),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final List<String>? args;
  const MyApp(this.args, {super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late List<String> args;
  @override
  void initState() {
    args = widget.args!;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = ref.watch(brightnessRef);

    var dispatcher = SchedulerBinding.instance.platformDispatcher;

    // This callback is called every time the brightness changes.
    dispatcher.onPlatformBrightnessChanged = () async {
      Brightness brightness = dispatcher.platformBrightness;
      ref.read(brightnessRef.notifier).state = brightness;

      await initFunc(brightness);
    };

    GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

    return SystemThemeBuilder(
      builder: (context, accent) => FluentApp(
        navigatorKey: key,
        theme: FluentThemeData(
          accentColor: accent.accent.toAccentColor(),
          brightness: brightness,
        ),
        home: HomeScreen(args),
      ),
    );
  }
}
