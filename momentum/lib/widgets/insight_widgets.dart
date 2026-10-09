import 'package:flutter/material.dart';

import '../services/sla_service.dart';

/// One colour per SLA status. Used by the bars, dots and chart.
Color statusColor(SlaStatus status) {
  switch (status) {
    case SlaStatus.onTrack:
      return const Color(0xFF14B8A6); // Teal
    case SlaStatus.atRisk:
      return const Color(0xFFF59E0B); // Amber
    case SlaStatus.overdue:
      return const Color(0xFFEF4444); // Red
    case SlaStatus.completed:
      return const Color(0xFF7C3AED); // Purple
  }
}

/// A rounded card surface used on Dashboard and Statistics.
class InsightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InsightCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// A small card with a big number and a label (for example "At Risk: 3").
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InsightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A label, a value on the right and a thin progress bar underneath.
/// [percent] is 0 to 100. If [valueText] is null it shows the percent.
class LabeledBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final String? valueText;

  const LabeledBar({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
    this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final safePercent = percent.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ),
            Text(
              valueText ?? '${safePercent.round()}%',
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: safePercent / 100,
            minHeight: 8,
            color: color,
            backgroundColor: color.withOpacity(0.15),
          ),
        ),
      ],
    );
  }
}
