import 'dart:io';
import 'dart:ui';
import 'package:Spheroscopic/utils/consts.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Spheroscopic/home/home_view.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:Spheroscopic/riverpod/brightness.dart';
import 'package:window_manager/window_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> initFunc(Brightness brightness) async {
  if (!Platform.isLinux) {
    await Window.setEffect(
      effect: WindowEffect.mica,
      dark: brightness == Brightness.dark ? true : false,
    );
  }
}

void main(List<String>? args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

  // Must add this line.
  await windowManager.ensureInitialized();

  // for setting minimal size of window
  WindowOptions windowOptions = WindowOptions(
    minimumSize: const Size(600, 400),
    title: "Spheroscopic",
    titleBarStyle:
        Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
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

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appVersion = packageInfo.version;

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://3ee13c2813e0d95f066e7bc4171d7042@o4506094609563648.ingest.sentry.io/4506524905963520';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.attachViewHierarchy = true;
      options.enableMetrics = true;
      options.enableTimeToFullDisplayTracing = true;
    },
    appRunner: () => runApp(
      ProviderScope(
        child: MyApp(args),
      ),
    ),
  );
  print("dsadas");

  Sentry.metrics().increment(
    'app.opened', // key
    value: 1, // value
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

    return SystemThemeBuilder(
      builder: (context, accent) => FluentApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        theme: FluentThemeData(
          accentColor: accent.accent.toAccentColor(),
          brightness: brightness,
        ),
        home: HomeScreen(args),
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
      ),
    );
  }
}
