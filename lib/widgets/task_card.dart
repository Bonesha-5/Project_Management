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

  const TaskCard({
    super.key,
    required this.task,
    required this.member,
    required this.onTap,
  });

  Color get _priorityColor => switch (task.priority) {
    Priority.high => AppTheme.red,
    Priority.medium => AppTheme.amber,
    Priority.low => AppTheme.teal,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final status = SlaService.computeStatus(task, DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (member != null)
                          UserAvatar(
                            name: member!.name,
                            color: Color(member!.avatarColor),
                            size: 26,
                          )
                        else
                          CircleAvatar(
                            radius: 13,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_outline,
                              size: 14,
                              color: muted,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            member == null
                                ? 'Unassigned'
                                : 'Due ${DateFormat('MMM d').format(task.dueDate)}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (member == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Due ${DateFormat('MMM d').format(task.dueDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusPill(status: status),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 16, color: _priorityColor),
                      const SizedBox(width: 4),
                      Text(
                        task.priority.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
