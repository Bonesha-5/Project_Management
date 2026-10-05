import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/sla_service.dart';
import '../models/task.dart';

class StatusPill extends StatelessWidget {
  final SlaStatus status;
  const StatusPill({super.key, required this.status});

  Color get color => switch (status) {
        SlaStatus.onTrack => AppTheme.teal,
        SlaStatus.atRisk => AppTheme.amber,
        SlaStatus.overdue => AppTheme.red,
        SlaStatus.completed => AppTheme.purple,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          SlaService.statusLabel(status),
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
        ),
      );
}
