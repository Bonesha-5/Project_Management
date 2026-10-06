import 'package:flutter/material.dart';

import '../services/sla_service.dart';

const Color _teal = Color(0xFF14B8A6);
const Color _amber = Color(0xFFF59E0B);
const Color _red = Color(0xFFEF4444);
const Color _purple = Color(0xFF7C3AED);

class StatusPill extends StatelessWidget {
  final SlaStatus status;

  const StatusPill({super.key, required this.status});

  /// The main colour for a status
  static Color colorFor(SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return _teal;
      case SlaStatus.atRisk:
        return _amber;
      case SlaStatus.overdue:
        return _red;
      case SlaStatus.completed:
        return _purple;
    }
  }

  /// The text shown for a status.
  static String labelFor(SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return 'On Track';
      case SlaStatus.atRisk:
        return 'At Risk';
      case SlaStatus.overdue:
        return 'Overdue';
      case SlaStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Pill(label: labelFor(status), color: colorFor(status));
  }
}

class WorkloadBadge extends StatelessWidget {
  final Workload workload;

  const WorkloadBadge({super.key, required this.workload});

  static Color colorFor(Workload workload) {
    switch (workload) {
      case Workload.balanced:
        return _teal;
      case Workload.heavy:
        return _amber;
      case Workload.overloaded:
        return _red;
    }
  }

  static String labelFor(Workload workload) {
    switch (workload) {
      case Workload.balanced:
        return 'Balanced';
      case Workload.heavy:
        return 'Heavy';
      case Workload.overloaded:
        return 'Overloaded';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Pill(label: labelFor(workload), color: colorFor(workload));
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Color.lerp(color, Colors.white, 0.35)!
        : Color.lerp(color, Colors.black, 0.30)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 56 : 40),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
