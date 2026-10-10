import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/insight_widgets.dart';
import '../widgets/status_pill.dart';

/// Stats tab: status chart, on-time rate, workload per member, deadlines.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Task> _tasks = [];
  List<Member> _members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tasks = await StorageService.getTasks();
      final members = await StorageService.getMembers();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _members = members;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the statistics. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load the statistics.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildBody()));
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

    final theme = Theme.of(context);
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            'Statistics',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_tasks.isEmpty)
            const InsightCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No data yet. Create a task to see statistics.'),
                ),
              ),
            )
          else ...[
            _summaryRow(),
            const SizedBox(height: 24),
            _sectionTitle('Tasks by status'),
            _statusChart(SlaService.countByStatus(_tasks, now)),
            const SizedBox(height: 24),
            _sectionTitle('Open tasks per member'),
            _memberBars(),
            const SizedBox(height: 24),
            _sectionTitle('Upcoming deadlines'),
            _upcoming(now),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _summaryRow() {
    final primary = Theme.of(context).colorScheme.primary;
    final rate = SlaService.onTimeRate(_tasks);
    final high = SlaService.openHighPriorityCount(_tasks);
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'On-time rate',
              value: '${rate.round()}%',
              color: statusColor(SlaStatus.onTrack),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Open high priority',
              value: '$high',
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Bar chart drawn with plain Containers (no chart package).
  /// Bar height = chart height x (count / biggest count).
  Widget _statusChart(Map<SlaStatus, int> counts) {
    const chartHeight = 140.0;
    final maxCount = counts.values.fold<int>(1, (m, c) => c > m ? c : m);
    final textTheme = Theme.of(context).textTheme;

    return InsightCard(
      child: SizedBox(
        height: chartHeight + 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final status in SlaStatus.values)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${counts[status]}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: chartHeight * (counts[status]! / maxCount),
                      decoration: BoxDecoration(
                        color: statusColor(status),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _memberBars() {
    final perMember = SlaService.openTasksPerMember(_tasks);
    final knownIds = {for (final m in _members) m.id};

    final rows = <MapEntry<String, int>>[
      for (final m in _members) MapEntry(m.name, perMember[m.id] ?? 0),
    ];

    // Tasks whose assignee no longer exists are shown as "Unassigned".
    var unassigned = 0;
    perMember.forEach((id, count) {
      if (!knownIds.contains(id)) unassigned += count;
    });
    if (unassigned > 0) rows.add(MapEntry('Unassigned', unassigned));

    if (rows.isEmpty) {
      return const InsightCard(child: Text('No team members yet.'));
    }

    rows.sort((a, b) => b.value.compareTo(a.value));
    final maxOpen = rows.fold<int>(1, (m, r) => r.value > m ? r.value : m);
    final primary = Theme.of(context).colorScheme.primary;

    return InsightCard(
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: LabeledBar(
                label: row.key,
                percent: row.value / maxOpen * 100,
                valueText: '${row.value}',
                color: primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _upcoming(DateTime now) {
    final upcoming = SlaService.upcomingDeadlines(_tasks, now);
    if (upcoming.isEmpty) {
      return const InsightCard(child: Text('No upcoming deadlines.'));
    }
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('EEE, d MMM');

    return InsightCard(
      child: Column(
        children: [
          for (final task in upcoming)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormat.format(task.dueDate),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(status: SlaService.computeStatus(task, now)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
