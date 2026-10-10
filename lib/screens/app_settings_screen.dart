import 'package:flutter/material.dart';

/// Screen 4.5 — App Settings
///
/// The dark-mode switch. `main.dart` owns the theme state and passes two
/// things into this screen:
///   * initialDarkMode — the current value, to render the switch position
///   * onThemeChanged  — the callback the switch calls when tapped
///
/// When the switch flips, we call `onThemeChanged(value)`, which triggers
/// `setState` in `main.dart`, which rebuilds the entire `MaterialApp` with
/// a new `themeMode`. That is the "lifting state up" pattern the brief
/// requires.
class AppSettingsScreen extends StatefulWidget {
  final bool initialDarkMode;
  final Future<void> Function(bool value) onThemeChanged;

  const AppSettingsScreen({
    super.key,
    required this.initialDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDarkMode;
  }

  Future<void> _toggle(bool value) async {
    // Update the local switch immediately so it feels responsive, then
    // hand the change up to main.dart.
    setState(() => _isDark = value);
    await widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'App Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Card(
                    child: SwitchListTile.adaptive(
                      value: _isDark,
                      onChanged: _toggle,
                      secondary: Icon(
                        _isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),
                      title: const Text('Dark mode'),
                      subtitle: Text(
                        _isDark
                            ? 'Currently using the dark theme'
                            : 'Currently using the light theme',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
