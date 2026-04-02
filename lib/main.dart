import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/setup_screen.dart';
import 'ui/screens/home_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FileSnapApp(),
    ),
  );
}

class FileSnapApp extends ConsumerWidget {
  const FileSnapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'FileSnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(
        settings.themeMode,
        fontFamily: settings.fontFamily,
        isBold: settings.isBoldFont,
      ),
      initialRoute: '/splash',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const ClampingScrollPhysics(),
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/setup': (context) => const SetupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
