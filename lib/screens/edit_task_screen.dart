import 'package:flutter/material.dart';

import '../models/member.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_form.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  Task? _task;
  List<Member> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tasks = await StorageService.getTasks();
      final members = await StorageService.getMembers();
      Task? found;
      for (final t in tasks) {
        if (t.id == widget.taskId) found = t;
      }
      if (!mounted) return;
      setState(() {
        _task = found;
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Could not load the task. Please try again.');
    }
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save(Task edited) async {
    try {
      final tasks = await StorageService.getTasks();
      final i = tasks.indexWhere((t) => t.id == widget.taskId);
      if (i < 0) throw Exception('missing');
      tasks[i] = edited.copyWith(notes: tasks[i].notes);
      await StorageService.saveTasks(tasks);
      if (!mounted) return;
      _snack('Task updated');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) _snack('Could not save the task. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Text(
                            '←',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Text(
                          'Edit Task',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_task == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text('This task could not be found.'),
                        ),
                      )
                    else
                      TaskForm(
                        initialTask: _task,
                        members: _members,
                        submitLabel: 'Save Changes',
                        onSubmit: _save,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
