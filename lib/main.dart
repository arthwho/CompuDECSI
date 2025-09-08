import 'package:compudecsi/pages/bottom_nav.dart';
import 'package:compudecsi/utils/app_theme.dart';
import 'package:compudecsi/pages/onboarding_page.dart';
import 'package:compudecsi/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple theme manager
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._();
  static ThemeManager get instance => _instance;
  ThemeManager._();

  bool _isDarkMode = false;
  final List<void Function(bool)> _listeners = [];

  bool get isDarkMode => _isDarkMode;

  bool get isSystemTheme {
    final systemIsDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    return _isDarkMode == systemIsDark;
  }

  void addListener(void Function(bool) listener) {
    _listeners.add(listener);
    print('ThemeManager: Added listener, total: ${_listeners.length}');
  }

  void removeListener(void Function(bool) listener) {
    _listeners.remove(listener);
    print('ThemeManager: Removed listener, total: ${_listeners.length}');
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool('isDarkMode');

      if (savedTheme != null) {
        // User has a saved preference, use it
        _isDarkMode = savedTheme;
        print('ThemeManager: Loaded saved theme preference: $_isDarkMode');
      } else {
        // No saved preference, detect system theme
        _isDarkMode =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        print(
          'ThemeManager: No saved preference, detected system theme: $_isDarkMode',
        );

        // Save the detected system theme as the user's preference
        await prefs.setBool('isDarkMode', _isDarkMode);
        print('ThemeManager: Saved detected system theme as preference');
      }
    } catch (e) {
      print('ThemeManager: Error loading theme: $e');
      // Fallback to system theme detection
      _isDarkMode =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    print('ThemeManager: Setting theme to: $_isDarkMode');
    print('ThemeManager: Current listeners count: ${_listeners.length}');

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      print('ThemeManager: Theme saved to preferences');
    } catch (e) {
      print('ThemeManager: Error saving theme: $e');
    }

    // Notify all listeners
    print('ThemeManager: Notifying ${_listeners.length} listeners');
    for (final listener in _listeners) {
      try {
        listener(_isDarkMode);
        print('ThemeManager: Listener notified successfully');
      } catch (e) {
        print('ThemeManager: Error notifying listener: $e');
      }
    }
  }

  void toggleTheme() {
    setTheme(!_isDarkMode);
  }

  Future<void> resetToSystemTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isDarkMode');
      await loadTheme(); // This will detect system theme and save it
      print('ThemeManager: Reset to system theme');
    } catch (e) {
      print('ThemeManager: Error resetting to system theme: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize timezones for notifications
  NotificationService.initializeTimeZones();

  // Initialize notification service
  await NotificationService().initialize();

  // Load saved theme preference
  await ThemeManager.instance.loadTheme();

  print(
    'main(): Theme loaded, current theme: ${ThemeManager.instance.isDarkMode}',
  );
  print('main(): About to run app');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeManager _themeManager;
  void Function(bool)? _currentListener;

  @override
  void initState() {
    super.initState();
    print('MyApp initState: Starting...');

    _themeManager = ThemeManager.instance;
    print('MyApp: Using ThemeManager instance: $_themeManager');
    print('MyApp: Current theme before listener: ${_themeManager.isDarkMode}');

    _currentListener = (isDark) {
      print('MyApp: Listener called with theme: $isDark');
      setState(() {
        print('MyApp: Theme changed to: $isDark');
      });
    };

    print('MyApp: About to add listener to ThemeManager');
    _themeManager.addListener(_currentListener!);
    print('MyApp: Listener added, current theme: ${_themeManager.isDarkMode}');
    print('MyApp: initState completed');
  }

  @override
  void dispose() {
    if (_currentListener != null) {
      print('MyApp: Removing listener from ThemeManager');
      _themeManager.removeListener(_currentListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('MyApp build - theme: ${_themeManager.isDarkMode}');
    return MaterialApp(
      title: 'CompuDECSI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        // If user is signed in, go to main app
        if (snapshot.hasData && snapshot.data != null) {
          return const BottomNav();
        }

        // If user is not signed in, show onboarding
        return const Onboarding();
      },
    );
  }
}
