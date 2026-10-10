import '../models/task.dart';

/// The four SLA statuses a task can have.
enum SlaStatus { onTrack, atRisk, overdue, completed }

/// Workload level of a team member (based on open tasks).
enum Workload { balanced, heavy, overloaded }

extension SlaStatusLabel on SlaStatus {
  String get label {
    switch (this) {
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
}

extension WorkloadLabel on Workload {
  String get label {
    switch (this) {
      case Workload.balanced:
        return 'Balanced';
      case Workload.heavy:
        return 'Heavy';
      case Workload.overloaded:
        return 'Overloaded';
    }
  }
}

/// All SLA rules and project statistics live here.
/// Screens never calculate SLA themselves, they call this class.
class SlaService {
  SlaService._();

  /// A task is "At Risk" when it is open and due in this many hours or less.
  /// Change this one number to change the rule (for example 24).
  static const int atRiskHours = 48;

  // ---------------------------------------------------------------- SLA

  /// The date picker only gives a date, so a task is due at the END of
  /// its due day (23:59:59). This stops a task due "today" from being
  /// overdue at 00:00 today.
  static DateTime deadlineOf(Task task) {
    final d = task.dueDate;
    return DateTime(d.year, d.month, d.day, 23, 59, 59);
  }

  /// Completed: status is Done.
  /// Overdue: deadline passed and not Done.
  /// At Risk: not Done and due in [atRiskHours] hours or less.
  /// On Track: everything else.
  static SlaStatus computeStatus(Task task, DateTime now) {
    if (task.status == TaskStatus.done) return SlaStatus.completed;
    final deadline = deadlineOf(task);
    if (now.isAfter(deadline)) return SlaStatus.overdue;
    if (deadline.difference(now) <= const Duration(hours: atRiskHours)) {
      return SlaStatus.atRisk;
    }
    return SlaStatus.onTrack;
  }

  /// Share of the time between creation and deadline already used (0 to 100).
  /// Calculated automatically, nobody types it.
  static double timeUsedPercent(Task task, DateTime now) {
    final total = deadlineOf(task).difference(task.createdAt).inSeconds;
    if (total <= 0) return 100;
    final used = now.difference(task.createdAt).inSeconds;
    return (used / total * 100).clamp(0, 100).toDouble();
  }

  /// A short sentence for the SLA card, for example
  /// "Due in 1 day and only 40% of work is done".
  static String message(Task task, DateTime now) {
    final status = computeStatus(task, now);
    if (status == SlaStatus.completed) return 'Task completed';
    final work = 'only ${task.progress}% of work is done';
    final deadline = deadlineOf(task);
    if (status == SlaStatus.overdue) {
      return 'Overdue by ${_span(now.difference(deadline))} and $work';
    }
    return 'Due in ${_span(deadline.difference(now))} and $work';
  }

  static String _span(Duration d) {
    if (d.inHours >= 24) {
      final days = d.inDays;
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
    if (d.inHours >= 1) {
      final hours = d.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return 'less than an hour';
  }

  // --------------------------------------------------------- statistics

  /// Number of tasks per SLA status (all four keys always present).
  static Map<SlaStatus, int> countByStatus(List<Task> tasks, DateTime now) {
    final counts = {for (final s in SlaStatus.values) s: 0};
    for (final task in tasks) {
      final status = computeStatus(task, now);
      counts[status] = counts[status]! + 1;
    }
    return counts;
  }

  /// Average "work done" of all tasks (0 to 100). A Done task counts as 100.
  /// Returns 0 when there are no tasks (no divide-by-zero).
  static double projectProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    final total = tasks.fold<double>(
      0,
      (sum, t) => sum + (t.status == TaskStatus.done ? 100 : t.progress),
    );
    return total / tasks.length;
  }

  static int completedCount(List<Task> tasks) =>
      tasks.where((t) => t.status == TaskStatus.done).length;

  /// Completed tasks finished by their deadline, divided by all completed
  /// tasks, as a percentage. Returns 0 when nothing is completed.
  /// A Done task with no completedAt (old or sample data) counts as on time.
  static double onTimeRate(List<Task> tasks) {
    final done = tasks.where((t) => t.status == TaskStatus.done).toList();
    if (done.isEmpty) return 0;
    final onTime = done.where(_finishedOnTime).length;
    return onTime / done.length * 100;
  }

  static bool _finishedOnTime(Task task) {
    final finished = task.completedAt;
    if (finished == null) return true;
    return !finished.isAfter(deadlineOf(task));
  }

  /// Open (not Done) tasks with High priority.
  static int openHighPriorityCount(List<Task> tasks) => tasks
      .where((t) => t.status != TaskStatus.done && t.priority == Priority.high)
      .length;

  /// Open tasks per assignee id.
  static Map<String, int> openTasksPerMember(List<Task> tasks) {
    final result = <String, int>{};
    for (final task in tasks) {
      if (task.status == TaskStatus.done) continue;
      result[task.assigneeId] = (result[task.assigneeId] ?? 0) + 1;
    }
    return result;
  }

  static int openTaskCount(String memberId, List<Task> tasks) => tasks
      .where((t) => t.assigneeId == memberId && t.status != TaskStatus.done)
      .length;

  /// 0 to 2 open tasks is Balanced, 3 to 4 is Heavy, 5 or more is Overloaded.
  static Workload workloadFor(String memberId, List<Task> tasks) {
    final open = openTaskCount(memberId, tasks);
    if (open >= 5) return Workload.overloaded;
    if (open >= 3) return Workload.heavy;
    return Workload.balanced;
  }

  /// At Risk and Overdue tasks, most urgent first (earliest deadline first,
  /// so the most overdue task is at the top).
  static List<Task> needsAttention(List<Task> tasks, DateTime now) {
    final list = tasks.where((t) {
      final s = computeStatus(t, now);
      return s == SlaStatus.atRisk || s == SlaStatus.overdue;
    }).toList();
    list.sort((a, b) => deadlineOf(a).compareTo(deadlineOf(b)));
    return list;
  }

  /// Open tasks whose deadline has not passed yet, soonest first.
  static List<Task> upcomingDeadlines(
    List<Task> tasks,
    DateTime now, {
    int limit = 5,
  }) {
    final list = tasks
        .where(
          (t) => t.status != TaskStatus.done && !now.isAfter(deadlineOf(t)),
        )
        .toList();
    list.sort((a, b) => deadlineOf(a).compareTo(deadlineOf(b)));
    return list.take(limit).toList();
  }

  // ------------------------------------------------------------ helpers

  /// Monday to Friday of the week that contains [now].
  static List<DateTime> weekDays(DateTime now) {
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return List.generate(
      5,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<Task> tasksDueOn(List<Task> tasks, DateTime day) =>
      tasks.where((t) => isSameDay(t.dueDate, day)).toList();

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
