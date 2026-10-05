import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import 'status_pill.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Member? member;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = SlaService.computeStatus(task, DateTime.now());
    final priorityColor = switch (task.priority) {
      Priority.low => AppTheme.teal,
      Priority.medium => AppTheme.amber,
      Priority.high => AppTheme.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                StatusPill(status: status),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                if (member != null) ...[UserAvatar(member: member!, radius: 16), const SizedBox(width: 8)],
                Expanded(child: Text(member?.name ?? 'Unassigned', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                Icon(Icons.calendar_today_rounded, size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d').format(task.dueDate)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Text(task.priority.name[0].toUpperCase() + task.priority.name.substring(1),
                    style: TextStyle(color: priorityColor, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${task.progress.round()}% done', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(value: task.progress / 100, minHeight: 7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
