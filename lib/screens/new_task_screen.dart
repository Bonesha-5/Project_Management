import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_form.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  List<Member> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final members = await StorageService.getMembers();
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Could not load team members. Please try again.');
    }
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _create(Task draft) async {
    try {
      final now = DateTime.now();
      final task = draft.copyWith(
        id: 'task_${now.microsecondsSinceEpoch}',
        createdAt: now,
        progress: draft.status == TaskStatus.done ? 100 : 0,
      );
      final tasks = await StorageService.getTasks();
      tasks.add(task);
      await StorageService.saveTasks(tasks);
      if (!mounted) return;
      _snack('Task created');
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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Text('←', style: TextStyle(fontSize: 24)),
                        ),
                        Text('New Task',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TaskForm(
                      members: _members,
                      submitLabel: 'Create Task',
                      onSubmit: _create,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
