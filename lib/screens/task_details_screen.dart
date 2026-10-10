import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/status_pill.dart';
import 'edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _notesController = TextEditingController();
  final _notesFocus = FocusNode();

  Task? _task;
  Member? _member;
  bool _loading = true;
  bool _leaving = false;
  String _savedNotes = '';

  @override
  void initState() {
    super.initState();
    _notesFocus.addListener(() {
      if (!_notesFocus.hasFocus) _saveNotes();
    });
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final tasks = await StorageService.getTasks();
      final members = await StorageService.getMembers();
      Task? found;
      for (final t in tasks) {
        if (t.id == widget.taskId) found = t;
      }
      Member? assignee;
      if (found != null) {
        for (final m in members) {
          if (m.id == found.assigneeId) assignee = m;
        }
      }
      if (!mounted) return;
      setState(() {
        _task = found;
        _member = assignee;
        _savedNotes = found?.notes ?? '';
        _notesController.text = _savedNotes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Could not load the task. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _persist(Task updated) async {
    try {
      final tasks = await StorageService.getTasks();
      final i = tasks.indexWhere((t) => t.id == updated.id);
      if (i < 0) throw Exception('missing');
      tasks[i] = updated;
      await StorageService.saveTasks(tasks);
      if (!mounted) return true;
      setState(() => _task = updated);
      return true;
    } catch (_) {
      if (mounted) _showError('Could not save the task. Please try again.');
      return false;
    }
  }

  Future<void> _changeStatus(TaskStatus status) async {
    final t = _task;
    if (t == null || t.status == status) return;
    await _persist(t.copyWith(status: status, progress: status == TaskStatus.done ? 100 : t.progress));
  }

  void _onProgressChanged(double v) {
    final t = _task;
    if (t == null) return;
    setState(() => _task = t.copyWith(progress: v, status: t.status == TaskStatus.done && v < 100 ? TaskStatus.inProgress : t.status));
  }

  Future<void> _onProgressEnd(double v) async {
    final t = _task;
    if (t != null) await _persist(t);
  }

  Future<void> _saveNotes() async {
    final t = _task;
    final text = _notesController.text;
    if (t == null || text == _savedNotes) return;
    if (await _persist(t.copyWith(notes: text))) _savedNotes = text;
  }

  Future<void> _edit() async {
    await _saveNotes();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(taskId: widget.taskId)),
    );
    if (!mounted) return;
    await _loadData();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final tasks = await StorageService.getTasks();
      tasks.removeWhere((t) => t.id == widget.taskId);
      await StorageService.saveTasks(tasks);
      if (!mounted) return;
      setState(() => _leaving = true);
      Navigator.pop(context);
    } catch (_) {
      if (mounted) _showError('Could not delete the task. Please try again.');
    }
  }

  Color _slaColor(SlaStatus s) => switch (s) {
        SlaStatus.onTrack => AppTheme.teal,
        SlaStatus.atRisk => AppTheme.amber,
        SlaStatus.overdue => AppTheme.red,
        SlaStatus.completed => AppTheme.purple,
      };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _saveNotes();
        if (!mounted) return;
        setState(() => _leaving = true);
        Navigator.pop(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _task == null
                  ? _notFound()
                  : _content(_task!),
        ),
      ),
    );
  }

  Widget _backButton() => TextButton(
        onPressed: () => Navigator.maybePop(context),
        child: const Text('←', style: TextStyle(fontSize: 24)),
      );

  Widget _notFound() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [_backButton(), const Text('Task Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 80),
          Icon(Icons.search_off, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          const Text('This task could not be found. It may have been deleted.', textAlign: TextAlign.center),
        ],
      );

  Widget _content(Task t) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final now = DateTime.now();
    final status = SlaService.computeStatus(t, now);
    final slaColor = _slaColor(status);
    final timeUsed = SlaService.timeUsedPercent(t, now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            _backButton(),
            Expanded(
              child: Text('Task Details',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              tooltip: 'Delete task',
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: AppTheme.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(t.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(t.description.trim().isEmpty ? 'No description' : t.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: slaColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('SLA Status',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                            ),
                            StatusPill(status: status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _progressLine('Time used', timeUsed, slaColor),
                        const SizedBox(height: 10),
                        _progressLine('Work done', t.progress, AppTheme.purple),
                        const SizedBox(height: 12),
                        Text(SlaService.message(t, now), style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow('Assigned to', _member?.name ?? 'Unassigned'),
                const SizedBox(height: 10),
                _infoRow('Due', DateFormat('MMM d, yyyy').format(t.dueDate)),
                const SizedBox(height: 10),
                _infoRow('Priority', t.priority.label),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<TaskStatus>(
            showSelectedIcon: false,
            segments: [
              for (final s in TaskStatus.values)
                ButtonSegment(value: s, label: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
            selected: {t.status},
            onSelectionChanged: (s) => _changeStatus(s.first),
          ),
        ),
        const SizedBox(height: 16),
        Text('Work done: ${t.progress.round()}%',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        Slider(
          value: t.progress,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${t.progress.round()}%',
          onChanged: _onProgressChanged,
          onChangeEnd: _onProgressEnd,
        ),
        const SizedBox(height: 8),
        Text('Notes', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          focusNode: _notesFocus,
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          onEditingComplete: () => _notesFocus.unfocus(),
          decoration: const InputDecoration(hintText: 'Add a note...'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: _edit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Edit Task →', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Row(
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      );

  Widget _progressLine(String label, double percent, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(label)),
            Text('${percent.round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: .15),
            ),
          ),
        ],
      );
}
