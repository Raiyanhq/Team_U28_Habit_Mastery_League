import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitMasteryLeagueApp());
}

class HabitMasteryLeagueApp extends StatefulWidget {
  const HabitMasteryLeagueApp({super.key});

  @override
  State<HabitMasteryLeagueApp> createState() => _HabitMasteryLeagueAppState();
}

class _HabitMasteryLeagueAppState extends State<HabitMasteryLeagueApp> {
  final PreferencesService _preferencesService = PreferencesService();
  bool _isDarkMode = true;
  bool _showSplash = true;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _isDarkMode = await _preferencesService.getDarkMode();
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  Future<void> _updateTheme(bool value) async {
    await _preferencesService.setDarkMode(value);
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Mastery League',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showSplash
          ? SplashScreen(
              onFinish: () {
                if (mounted) setState(() => _showSplash = false);
              },
            )
          : DashboardScreen(
              isDarkMode: _isDarkMode,
              onThemeChanged: _updateTheme,
            ),
    );
  }
}
