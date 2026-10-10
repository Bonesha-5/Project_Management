import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/task_list_screen.dart';
import 'services/seed_data.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = StorageService();
  if ((await s.getTasks()).isEmpty) {
    await s.saveMembers(SeedData.members());
    await s.saveTasks(SeedData.tasks());
  }
  runApp(MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.dark,
    home: const _DevShell(),
  ));
}

class _DevShell extends StatefulWidget {
  const _DevShell();
  @override
  State<_DevShell> createState() => _DevShellState();
}

class _DevShellState extends State<_DevShell> {
  int _index = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: _index == 1
              ? const TaskListScreen()
              : const Center(child: Text('Not part of the Tasks work')),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Tasks'),
            NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Team'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      );
}
