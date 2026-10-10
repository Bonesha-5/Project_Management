import 'package:flutter/material.dart';

import '../models/member.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/insight_widgets.dart';
import '../widgets/status_pill.dart';
import 'new_task_screen.dart';
import 'task_details_screen.dart';

/// Home tab: overall progress, SLA counts, this week and tasks needing attention.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  List<Task> _tasks = [];
  List<Member> _members = [];
  Member? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads everything from storage, then calls setState so the screen redraws.
  Future<void> _loadData() async {
    try {
      final tasks = await StorageService.getTasks();
      final members = await StorageService.getMembers();
      final user = await AuthService.currentUser();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _members = members;
        _user = user;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the dashboard. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load the dashboard.')),
      );
    }
  }

  /// Opens another screen and reloads when the user comes back,
  /// so the numbers always match the latest data.
  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadData();
  }

  String get _firstName {
    final name = _user?.name.trim() ?? '';
    return name.isEmpty ? 'there' : name.split(' ').first;
  }

  String _assigneeName(String id) {
    for (final m in _members) {
      if (m.id == id) return m.name;
    }
    return 'Unassigned';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
      floatingActionButton: Padding(
        // Keeps the + button above the floating bottom bar.
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () => _open(const NewTaskScreen()),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadData,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final theme = Theme.of(context);
    final counts = SlaService.countByStatus(_tasks, now);
    final progress = SlaService.projectProgress(_tasks);
    final attention = SlaService.needsAttention(_tasks, now);

    // ListView makes the whole screen scrollable, so nothing overflows.
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            '${SlaService.greeting(now)}, $_firstName',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here is how the project is doing',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _progressCard(progress, SlaService.completedCount(_tasks)),
          const SizedBox(height: 16),
          _statGrid(counts),
          const SizedBox(height: 24),
          _weekSection(now),
          const SizedBox(height: 24),
          _attentionSection(attention, now),
        ],
      ),
    );
  }

  Widget _progressCard(double progress, int completed) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall project progress',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completed of ${_tasks.length} tasks completed',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _statGrid(Map<SlaStatus, int> counts) {
    final primary = Theme.of(context).colorScheme.primary;
    final cards = <Widget>[
      StatCard(
        label: 'Team Members',
        value: '${_members.length}',
        color: primary,
      ),
      StatCard(label: 'Total Tasks', value: '${_tasks.length}', color: primary),
      for (final status in SlaStatus.values)
        StatCard(
          label: status.label,
          value: '${counts[status]}',
          color: statusColor(status),
        ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: cards,
    );
  }

  Widget _weekSection(DateTime now) {
    final days = SlaService.weekDays(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This week',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final day in days) Expanded(child: _dayCell(day, now)),
          ],
        ),
      ],
    );
  }

  Widget _dayCell(DateTime day, DateTime now) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isToday = SlaService.isSameDay(day, now);
    final due = SlaService.tasksDueOn(_tasks, day);
    return Column(
      children: [
        Text(_dayNames[day.weekday - 1], style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? scheme.primary : Colors.transparent,
          ),
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isToday ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // One small dot per task due that day, coloured by SLA status.
        SizedBox(
          height: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final task in due.take(3))
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor(SlaService.computeStatus(task, now)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attentionSection(List<Task> attention, DateTime now) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs attention',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (attention.isEmpty)
          const InsightCard(
            child: Center(child: Text('Nothing needs attention. Great work!')),
          )
        else
          for (final task in attention) _attentionTile(task, now),
      ],
    );
  }

  Widget _attentionTile(Task task, DateTime now) {
    final theme = Theme.of(context);
    final status = SlaService.computeStatus(task, now);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(TaskDetailsScreen(taskId: task.id)),
        child: InsightCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(status: status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Assigned to ${_assigneeName(task.assigneeId)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              LabeledBar(
                label: 'Time used',
                percent: SlaService.timeUsedPercent(task, now),
                color: statusColor(status),
              ),
              const SizedBox(height: 8),
              LabeledBar(
                label: 'Work done',
                percent: task.progress.toDouble(),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
