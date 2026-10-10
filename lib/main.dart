import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/app_settings_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'widgets/main_shell.dart';

Future<void> main() async {
  // Required before any plugin (SharedPreferences, etc.) is touched in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Load the persisted theme choice before the first frame so the app does
  // not flash light then switch to dark.
  final isDark = await StorageService.getDarkMode();

  runApp(MomentumApp(initialDarkMode: isDark));
}

/// Root widget. Owns the app-wide theme state, and provides the callback
/// that App Settings uses to flip between light and dark.
class MomentumApp extends StatefulWidget {
  final bool initialDarkMode;
  const MomentumApp({super.key, required this.initialDarkMode});

  @override
  State<MomentumApp> createState() => _MomentumAppState();
}

class _MomentumAppState extends State<MomentumApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDarkMode;
  }

  /// Called by App Settings. Updates the whole app immediately (setState
  /// rebuilds MaterialApp with a new `themeMode`) and persists the choice.
  Future<void> _setDarkMode(bool value) async {
    setState(() => _isDark = value);
    await StorageService.setDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // Startup gate decides Sign In vs Dashboard once, then redirects.
      initialRoute: '/',

      routes: {
        '/': (context) => const _StartupGate(),
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/app-settings': (context) => AppSettingsScreen(
          initialDarkMode: _isDark,
          onThemeChanged: _setDarkMode,
        ),

        // After sign in: the bottom bar with the five tabs.
        '/dashboard': (context) => const MainShell(),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Startup gate
// ─────────────────────────────────────────────────────────────────────────────

/// Shows a spinner while we check for a saved session, then replaces itself
/// with Sign In or Dashboard. This is what makes "reopening the app keeps the
/// user signed in" work.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final user = await AuthService.currentUser();
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
