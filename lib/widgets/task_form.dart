import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/task.dart';
import 'app_text_field.dart';

class TaskForm extends StatefulWidget {
  final List<Member> members;
  final Task? initialTask;
  final GlobalKey<FormState> formKey;
  final void Function({
    required String title,
    required String description,
    required String assigneeId,
    required DateTime dueDate,
    required Priority priority,
    required TaskStatus status,
    required double progress,
    required String notes,
  }) onSubmit;

  const TaskForm({
    super.key,
    required this.members,
    required this.formKey,
    required this.onSubmit,
    this.initialTask,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController notes;
  String? assignee;
  DateTime? dueDate;
  Priority priority = Priority.medium;
  TaskStatus status = TaskStatus.todo;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    title = TextEditingController(text: t?.title ?? '');
    description = TextEditingController(text: t?.description ?? '');
    notes = TextEditingController(text: t?.notes ?? '');
    assignee = t?.assigneeId;
    dueDate = t?.dueDate;
    priority = t?.priority ?? Priority.medium;
    status = t?.status ?? TaskStatus.todo;
    progress = t?.progress ?? 0;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: widget.formKey,
        child: Column(
          children: [
            AppTextField(controller: title, label: 'Title', hint: 'e.g. Implement login flow'),
            const SizedBox(height: 14),
            AppTextField(controller: description, label: 'Description', maxLines: 3, validator: (_) => null),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: widget.members.any((m) => m.id == assignee) ? assignee : null,
              decoration: const InputDecoration(labelText: 'Assign to', prefixIcon: Icon(Icons.person_outline)),
              hint: const Text('Select team member'),
              items: widget.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
              validator: (v) => v == null ? 'Assignee is required' : null,
              onChanged: (v) => setState(() => assignee = v),
            ),
            const SizedBox(height: 14),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: dueDate == null ? '' : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'),
              validator: (_) => dueDate == null ? 'Due date is required' : null,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => dueDate = picked);
              },
              decoration: const InputDecoration(labelText: 'Due date', hintText: 'Select date', prefixIcon: Icon(Icons.calendar_month_rounded)),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<Priority>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: Priority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name[0].toUpperCase() + p.name.substring(1)))).toList(),
                  onChanged: (v) => setState(() => priority = v ?? Priority.medium),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TaskStatus>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s)))).toList(),
                  onChanged: (v) => setState(() {
                    status = v ?? TaskStatus.todo;
                    if (status == TaskStatus.done) progress = 100;
                  }),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Work done: ${progress.round()}%', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Slider(
              value: progress,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${progress.round()}%',
              onChanged: (v) => setState(() => progress = v),
            ),
            const SizedBox(height: 4),
            AppTextField(controller: notes, label: 'Notes', maxLines: 3, validator: (_) => null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (!widget.formKey.currentState!.validate()) return;
                  if (dueDate!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Due date cannot be in the past.')));
                    return;
                  }
                  widget.onSubmit(
                    title: title.text,
                    description: description.text,
                    assigneeId: assignee!,
                    dueDate: dueDate!,
                    priority: priority,
                    status: status,
                    progress: status == TaskStatus.done ? 100 : progress,
                    notes: notes.text,
                  );
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(widget.initialTask == null ? 'Create Task' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      );

  String _statusLabel(TaskStatus s) => switch (s) {
        TaskStatus.todo => 'To Do',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
      };
}
