import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';
import 'new_task_screen.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  List<Member> _members = [];
  String _search = '';
  SlaStatus? _filter;
  bool _loading = true;

  static const _filters = <String, SlaStatus?>{
    'All': null,
    'On Track': SlaStatus.onTrack,
    'At Risk': SlaStatus.atRisk,
    'Overdue': SlaStatus.overdue,
    'Done': SlaStatus.completed,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tasks = await StorageService.getTasks();
      final members = await StorageService.getMembers();
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load tasks. Please try again.'),
        ),
      );
    }
  }

  Member? _memberFor(String id) {
    for (final m in _members) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<Task> _visibleTasks() {
    final now = DateTime.now();
    final query = _search.trim().toLowerCase();
    return _tasks.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(query);
      final matchesFilter =
          _filter == null || SlaService.computeStatus(t, now) == _filter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _visibleTasks();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.pink,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'New task',
        onPressed: () => _open(const NewTaskScreen()),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                children: [
                  Text(
                    'Tasks',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final e in _filters.entries)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(e.key),
                              selected: _filter == e.value,
                              shape: const StadiumBorder(),
                              onSelected: (_) =>
                                  setState(() => _filter = e.value),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (visible.isEmpty)
                    _EmptyState(
                      message: _tasks.isEmpty
                          ? 'No tasks yet.'
                          : 'No tasks match your search.',
                    ),
                  for (final t in visible)
                    TaskCard(
                      task: t,
                      member: _memberFor(t.assigneeId),
                      onTap: () => _open(TaskDetailsScreen(taskId: t.id)),
                    ),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
