import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/task_list_screen.dart';
import '../screens/team_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex = widget.initialIndex;

  // Changes on every tap, so even the same tab is rebuilt and reloads.
  int _reloadCount = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.check_box_rounded, label: 'Tasks'),
    _TabItem(icon: Icons.group_rounded, label: 'Team'),
    _TabItem(icon: Icons.bar_chart_rounded, label: 'Stats'),
    _TabItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  /// Called when a tab is tapped: store the new index and redraw.
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _reloadCount++;
    });
  }

  /// Builds the page for a tab. A new widget every time, so it reloads.
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TaskListScreen();
      case 2:
        return const TeamScreen();
      case 3:
        return const StatisticsScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey('$_selectedIndex-$_reloadCount'),
        child: _buildPage(_selectedIndex),
      ),
      bottomNavigationBar: _FloatingNavBar(
        tabs: _tabs,
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

/// The purple rounded bar that floats above the bottom edge.
class _FloatingNavBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF4C1D95) : const Color(0xFF7C3AED);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withAlpha(isDark ? 70 : 60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            return Expanded(
              child: _NavButton(
                item: tabs[i],
                selected: i == selectedIndex,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white.withAlpha(185);

    return Semantics(
      selected: selected,
      button: true,
      label: '${item.label} tab',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withAlpha(50) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 20, color: color),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
