import 'package:flutter/material.dart';

import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/status_pill.dart';
import '../widgets/user_avatar.dart';

class MemberTasksScreen extends StatefulWidget {
  final Member member;

  const MemberTasksScreen({super.key, required this.member});

  @override
  State<MemberTasksScreen> createState() => _MemberTasksScreenState();
}

class _MemberTasksScreenState extends State<MemberTasksScreen> {
  List<Task> _openTasks = [];
  List<Task> _doneTasks = [];
  Workload _workload = Workload.balanced;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Loads all tasks, keeps this member's, sorts them and redraws.
  Future<void> _loadTasks() async {
    try {
      final allTasks = await StorageService.getTasks();
      final mine = allTasks
          .where((t) => t.assigneeId == widget.member.id)
          .toList();

      // Open tasks: earliest due date first, so the most urgent is on top.
      final open = mine.where((t) => t.status != TaskStatus.done).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      // Completed tasks: most recent due date first.
      final done = mine.where((t) => t.status == TaskStatus.done).toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

      if (!mounted) return;
      setState(() {
        _openTasks = open;
        _doneTasks = done;
        _workload = SlaService.workloadFor(widget.member.id, mine);
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load the tasks. Pull down to try again.';
        _isLoading = false;
      });
    }
  }

  /// Opens Task Details for a task, then reloads in case it changed.
  Future<void> _openTask(Task task) async {
    // When Deborah's Task Details is merged, replace the SnackBar with
    // these lines (check her constructor - it may take the task or its id):
    // await Navigator.push(context, MaterialPageRoute(
    //     builder: (_) => TaskDetailsScreen(task: task)));
    // await _loadTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task Details for "${task.title}" coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Member Tasks',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(140);

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _MemberHeader(member: widget.member, workload: _workload),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            _Message(icon: Icons.error_outline_rounded, text: _errorMessage!)
          else if (_openTasks.isEmpty && _doneTasks.isEmpty)
            _Message(
              icon: Icons.assignment_outlined,
              text: '${_firstName(widget.member.name)} has no tasks yet.',
            )
          else ...[
            _SectionTitle(text: 'Open tasks (${_openTasks.length})'),
            if (_openTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Nothing open. All caught up!',
                  style: TextStyle(color: muted),
                ),
              ),
            for (final task in _openTasks)
              _TaskTile(task: task, onTap: () => _openTask(task)),
            if (_doneTasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionTitle(text: 'Completed (${_doneTasks.length})'),
              for (final task in _doneTasks)
                _TaskTile(task: task, onTap: () => _openTask(task)),
            ],
          ],
        ],
      ),
    );
  }

  static String _firstName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'This member' : parts.first;
  }
}

/// Big avatar, name, title and workload badge at the top.
class _MemberHeader extends StatelessWidget {
  final Member member;
  final Workload workload;

  const _MemberHeader({required this.member, required this.workload});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(150);
    final title = member.title.trim().isEmpty ? 'Team member' : member.title;

    return Column(
      children: [
        UserAvatar(
          name: member.name,
          color: Color(member.avatarColor),
          size: 72,
        ),
        const SizedBox(height: 12),
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(title, style: TextStyle(color: muted)),
        const SizedBox(height: 10),
        WorkloadBadge(workload: workload),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    );
  }
}

/// One task: title, SLA pill, due date, priority and a work done bar.
class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF15102A) : Colors.white;
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(150);
    final status = SlaService.computeStatus(task, DateTime.now());
    final statusColor = StatusPill.colorFor(status);
    final progress = task.progress.clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(status: status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dueText(task, status),
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                    Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: _priorityColor(task.priority),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _priorityLabel(task.priority),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          color: statusColor,
                          backgroundColor: statusColor.withAlpha(40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$progress%',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "Due Oct 12", "Was due Oct 3" or "Done Oct 2", as in the mockups.
  static String _dueText(Task task, SlaStatus status) {
    final date = '${_months[task.dueDate.month - 1]} ${task.dueDate.day}';
    switch (status) {
      case SlaStatus.completed:
        return 'Done $date';
      case SlaStatus.overdue:
        return 'Was due $date';
      default:
        return 'Due $date';
    }
  }

  static String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  static Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.low:
        return const Color(0xFF14B8A6);
      case Priority.medium:
        return const Color(0xFFF59E0B);
      case Priority.high:
        return const Color(0xFFEF4444);
    }
  }
}

/// Empty state and error message.
class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Icon(icon, size: 44, color: muted),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
