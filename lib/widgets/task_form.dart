import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';

class TaskForm extends StatefulWidget {
  final Task? initialTask;
  final List<Member> members;
  final String submitLabel;
  final Future<void> Function(Task task) onSubmit;

  const TaskForm({
    super.key,
    this.initialTask,
    required this.members,
    required this.onSubmit,
    this.submitLabel = 'Create Task',
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateFieldKey = GlobalKey<FormFieldState<DateTime>>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _dateText;

  String? _assigneeId;
  DateTime? _dueDate;
  Priority _priority = Priority.medium;
  TaskStatus? _status;
  double _progress = 0;
  bool _saving = false;

  bool get _isEdit => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _dueDate = t?.dueDate;
    _dateText = TextEditingController(text: _format(t?.dueDate));
    _priority = t?.priority ?? Priority.medium;
    _status = t?.status;
    _progress = t?.progress ?? 0;
    if (t != null && widget.members.any((m) => m.id == t.assigneeId)) {
      _assigneeId = t.assigneeId;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _dateText.dispose();
    super.dispose();
  }

  String _format(DateTime? d) => d == null ? '' : DateFormat('MMM d, yyyy').format(d);

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _pickDate() async {
    final today = _dateOnly(DateTime.now());
    final existing = widget.initialTask?.dueDate;
    var first = today;
    if (existing != null && _dateOnly(existing).isBefore(today)) {
      first = _dateOnly(existing);
    }
    var initial = _dueDate ?? today;
    if (initial.isBefore(first)) initial = first;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(today.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _dueDate = picked;
      _dateText.text = _format(picked);
    });
    _dateFieldKey.currentState?.didChange(picked);
  }

  String? _validateDate(DateTime? value) {
    if (value == null) return 'Please select a due date';
    final existing = widget.initialTask?.dueDate;
    final unchanged = existing != null && _dateOnly(existing) == _dateOnly(value);
    if (!unchanged && _dateOnly(value).isBefore(_dateOnly(DateTime.now()))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  void _onStatusChanged(TaskStatus? value) {
    setState(() {
      _status = value;
      if (value == TaskStatus.done) _progress = 100;
    });
  }

  void _onProgressChanged(double value) {
    setState(() {
      _progress = value;
      if (_status == TaskStatus.done && value < 100) {
        _status = TaskStatus.inProgress;
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final old = widget.initialTask;
    final status = _status ?? TaskStatus.todo;
    final task = Task(
      id: old?.id ?? '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      assigneeId: _assigneeId!,
      createdAt: old?.createdAt ?? DateTime.now(),
      dueDate: _dueDate!,
      priority: _priority,
      status: status,
      progress: _isEdit ? _progress : 0,
      notes: old?.notes ?? '',
    );
    setState(() => _saving = true);
    try {
      await widget.onSubmit(task);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title *', style: labelStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'e.g. Build settings screen'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          Text('Description', style: labelStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: _description,
            minLines: 3,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(hintText: 'What needs to be done?'),
          ),
          const SizedBox(height: 16),
          Text('Assign to *', style: labelStyle),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _assigneeId,
            isExpanded: true,
            hint: const Text('Select team member'),
            items: [
              for (final m in widget.members)
                DropdownMenuItem(
                  value: m.id,
                  child: Text(m.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _assigneeId = v),
            validator: (v) => v == null ? 'Please select a team member' : null,
          ),
          const SizedBox(height: 16),
          Text('Due date *', style: labelStyle),
          const SizedBox(height: 6),
          FormField<DateTime>(
            key: _dateFieldKey,
            initialValue: _dueDate,
            validator: _validateDate,
            builder: (state) => TextField(
              controller: _dateText,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: 'Select date',
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                errorText: state.errorText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Priority', style: labelStyle),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Priority>(
              showSelectedIcon: false,
              segments: [
                for (final p in Priority.values)
                  ButtonSegment(value: p, label: Text(p.label)),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
          ),
          const SizedBox(height: 16),
          Text('Status', style: labelStyle),
          const SizedBox(height: 6),
          DropdownButtonFormField<TaskStatus>(
            initialValue: _status,
            isExpanded: true,
            hint: const Text('Select status'),
            items: [
              for (final s in TaskStatus.values)
                DropdownMenuItem(value: s, child: Text(s.label)),
            ],
            onChanged: _onStatusChanged,
          ),
          if (_isEdit) ...[
            const SizedBox(height: 16),
            Text('Work done: ${_progress.round()}%', style: labelStyle),
            Slider(
              value: _progress,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_progress.round()}%',
              onChanged: _onProgressChanged,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
