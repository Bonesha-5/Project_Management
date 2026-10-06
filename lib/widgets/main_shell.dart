import 'package:flutter/material.dart';

import '../screens/teamMembers.dart';

class MainShell extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final int initialIndex;

  const MainShell({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    this.initialIndex = 0,
  });

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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _WaitingPage(title: 'Home', owner: 'Jospin');
      // return const DashboardScreen();
      case 1:
        return const _WaitingPage(title: 'Tasks', owner: 'Deborah');
      // return const TaskListScreen();
      case 2:
        return const TeamScreen();
      case 3:
        return const _WaitingPage(title: 'Stats', owner: 'Jospin');
      // return const StatisticsScreen();
      default:
        return const _WaitingPage(title: 'Profile', owner: 'Byusa');
      // return ProfileScreen(
      //   isDark: widget.isDark,
      //   onThemeChanged: widget.onThemeChanged,
      // );
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

/// Temporary page shown until a teammate's screen is merged.
class _WaitingPage extends StatelessWidget {
  final String title;
  final String owner;

  const _WaitingPage({required this.title, required this.owner});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 40, color: muted),
            const SizedBox(height: 12),
            Text(
              '$title screen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Arrives when $owner merges it',
              style: TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
