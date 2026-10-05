import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/task_list_screen.dart';
import '../screens/team_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;

  const MainShell({super.key, required this.onThemeToggle, required this.isDark});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: ValueKey('dashboard_$index')),
      TaskListScreen(key: ValueKey('tasks_$index')),
      TeamScreen(key: ValueKey('team_$index')),
      StatisticsScreen(key: ValueKey('stats_$index')),
      ProfileScreen(onThemeToggle: widget.onThemeToggle, isDark: widget.isDark, key: ValueKey('profile_$index')),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: screens)),
      floatingActionButton: index == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              onPressed: () async {
                await Navigator.pushNamed(context, '/new-task');
                setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Team'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
