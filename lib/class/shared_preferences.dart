// provider stores the instance SharedPreferences
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panorama_viewer_app/utils/options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  return throw UnimplementedError();
});

// provider to work with AppTheme
final appProvider = ChangeNotifierProvider((ref) {
  return Settings(ref.watch(sharedPreferencesProvider));
});
