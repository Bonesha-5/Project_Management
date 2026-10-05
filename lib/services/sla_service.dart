import '../models/member.dart';
import '../models/task.dart';

enum SlaStatus { onTrack, atRisk, overdue, completed }

class SlaService {
  static SlaStatus computeStatus(Task task, DateTime now) {
    if (task.status == TaskStatus.done || task.progress >= 100) {
      return SlaStatus.completed;
    }
    if (task.dueDate.isBefore(now)) return SlaStatus.overdue;
    if (!task.dueDate.difference(now).isNegative &&
        task.dueDate.difference(now) <= const Duration(hours: 48)) {
      return SlaStatus.atRisk;
    }
    return SlaStatus.onTrack;
  }

  static double timeUsedPercent(Task task, DateTime now) {
    final total = task.dueDate.difference(task.createdAt).inSeconds;
    if (total <= 0) return 100;
    final used = now.difference(task.createdAt).inSeconds;
    return (used / total * 100).clamp(0, 100).toDouble();
  }

  static String statusLabel(SlaStatus status) => switch (status) {
        SlaStatus.onTrack => 'On Track',
        SlaStatus.atRisk => 'At Risk',
        SlaStatus.overdue => 'Overdue',
        SlaStatus.completed => 'Completed',
      };

  static String message(Task task, DateTime now) {
    final status = computeStatus(task, now);
    if (status == SlaStatus.completed) return 'Completed at ${task.progress.round()}% work done.';
    if (status == SlaStatus.overdue) {
      final days = now.difference(task.dueDate).inDays;
      return 'Overdue by ${days <= 0 ? 1 : days} day(s) and ${task.progress.round()}% of work is done.';
    }
    final hours = task.dueDate.difference(now).inHours;
    if (hours < 24) return 'Due in $hours hour(s) and only ${task.progress.round()}% of work is done.';
    return 'Due in ${hours ~/ 24} day(s) and ${task.progress.round()}% of work is done.';
  }

  static Map<SlaStatus, int> counts(List<Task> tasks, DateTime now) {
    final map = {for (final s in SlaStatus.values) s: 0};
    for (final t in tasks) map[computeStatus(t, now)] = map[computeStatus(t, now)]! + 1;
    return map;
  }

  static double projectProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    return tasks.map((t) => t.progress).reduce((a, b) => a + b) / tasks.length;
  }

  static double onTimeRate(List<Task> tasks) {
    final done = tasks.where((t) => t.status == TaskStatus.done).toList();
    if (done.isEmpty) return 0;
    final onTime = done.where((t) => !t.dueDate.isBefore(t.createdAt) && t.progress >= 100).length;
    return onTime / done.length * 100;
  }

  static int openHighPriority(List<Task> tasks) =>
      tasks.where((t) => t.status != TaskStatus.done && t.priority == Priority.high).length;

  static int openTasksFor(List<Task> tasks, String memberId) =>
      tasks.where((t) => t.assigneeId == memberId && t.status != TaskStatus.done).length;

  static String workloadFor(List<Task> tasks, Member member) {
    final n = openTasksFor(tasks, member.id);
    if (n <= 2) return 'Balanced';
    if (n <= 4) return 'Heavy';
    return 'Overloaded';
  }
}
