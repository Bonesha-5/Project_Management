import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/models/task.dart';
import 'package:momentum/services/sla_service.dart';

// Fixed "today" so tests never depend on the real clock.
final DateTime now = DateTime(2026, 10, 6, 12);

Task makeTask({
  String id = 't1',
  String assigneeId = 'm1',
  DateTime? created,
  required DateTime due,
  TaskStatus status = TaskStatus.todo,
  int progress = 0,
  Priority priority = Priority.medium,
  DateTime? completedAt,
}) {
  return Task(
    id: id,
    title: 'Task $id',
    description: '',
    assigneeId: assigneeId,
    createdAt: created ?? DateTime(2026, 10, 1),
    dueDate: due,
    priority: priority,
    status: status,
    progress: progress,
    notes: '',
    completedAt: completedAt,
  );
}

void main() {
  group('computeStatus', () {
    test('far deadline is On Track', () {
      final task = makeTask(due: DateTime(2026, 10, 20));
      expect(SlaService.computeStatus(task, now), SlaStatus.onTrack);
    });

    test('exactly 48 hours left is At Risk', () {
      // Deadline is 8 Oct 23:59:59, so 6 Oct 23:59:59 is exactly 48h before.
      final task = makeTask(due: DateTime(2026, 10, 8));
      final exactly48 = DateTime(2026, 10, 6, 23, 59, 59);
      expect(SlaService.computeStatus(task, exactly48), SlaStatus.atRisk);
    });

    test('one second more than 48 hours left is On Track', () {
      final task = makeTask(due: DateTime(2026, 10, 8));
      final justOver = DateTime(2026, 10, 6, 23, 59, 58);
      expect(SlaService.computeStatus(task, justOver), SlaStatus.onTrack);
    });

    test('at the exact deadline it is still At Risk, not Overdue', () {
      final task = makeTask(due: DateTime(2026, 10, 8));
      final atDeadline = DateTime(2026, 10, 8, 23, 59, 59);
      expect(SlaService.computeStatus(task, atDeadline), SlaStatus.atRisk);
    });

    test('one second past the deadline is Overdue', () {
      final task = makeTask(due: DateTime(2026, 10, 8));
      final justPast = DateTime(2026, 10, 9);
      expect(SlaService.computeStatus(task, justPast), SlaStatus.overdue);
    });

    test('Done before the due date is Completed', () {
      final task = makeTask(
        due: DateTime(2026, 10, 20),
        status: TaskStatus.done,
        progress: 100,
      );
      expect(SlaService.computeStatus(task, now), SlaStatus.completed);
    });

    test('Done after the due date is still Completed (not Overdue)', () {
      final task = makeTask(
        due: DateTime(2026, 10, 3),
        status: TaskStatus.done,
        progress: 100,
        completedAt: DateTime(2026, 10, 5),
      );
      expect(SlaService.computeStatus(task, now), SlaStatus.completed);
    });
  });

  group('timeUsedPercent', () {
    test('is 0% at the created time', () {
      final created = DateTime(2026, 10, 1);
      final task = makeTask(created: created, due: DateTime(2026, 10, 10));
      expect(SlaService.timeUsedPercent(task, created), 0);
    });

    test('is about 50% halfway to the deadline', () {
      final created = DateTime(2026, 10, 1);
      final task = makeTask(created: created, due: DateTime(2026, 10, 10));
      final total = SlaService.deadlineOf(task).difference(created);
      final halfway = created.add(total ~/ 2);
      expect(SlaService.timeUsedPercent(task, halfway), closeTo(50, 0.01));
    });

    test('is capped at 100% after the deadline', () {
      final task = makeTask(due: DateTime(2026, 10, 3));
      expect(SlaService.timeUsedPercent(task, now), 100);
    });
  });

  group('projectProgress', () {
    test('is 0% with no tasks (no divide by zero)', () {
      expect(SlaService.projectProgress([]), 0);
    });

    test('averages 0% and 100% work done to 50%', () {
      final tasks = [
        makeTask(id: 'a', due: DateTime(2026, 10, 20), progress: 0),
        makeTask(id: 'b', due: DateTime(2026, 10, 20), progress: 100),
      ];
      expect(SlaService.projectProgress(tasks), 50);
    });

    test('a Done task counts as 100% even if progress is lower', () {
      final tasks = [
        makeTask(
          due: DateTime(2026, 10, 20),
          status: TaskStatus.done,
          progress: 60,
        ),
      ];
      expect(SlaService.projectProgress(tasks), 100);
    });
  });

  group('onTimeRate', () {
    test('is 0% when nothing is completed', () {
      final tasks = [makeTask(due: DateTime(2026, 10, 20))];
      expect(SlaService.onTimeRate(tasks), 0);
    });

    test('one on time and one late completion gives 50%', () {
      final tasks = [
        makeTask(
          id: 'a',
          due: DateTime(2026, 10, 3),
          status: TaskStatus.done,
          progress: 100,
          completedAt: DateTime(2026, 10, 2),
        ),
        makeTask(
          id: 'b',
          due: DateTime(2026, 10, 3),
          status: TaskStatus.done,
          progress: 100,
          completedAt: DateTime(2026, 10, 5),
        ),
      ];
      expect(SlaService.onTimeRate(tasks), 50);
    });
  });

  group('workloadFor', () {
    List<Task> openTasks(int n) => List.generate(
          n,
          (i) => makeTask(id: 'x$i', due: DateTime(2026, 10, 20)),
        );

    test('0 to 2 open tasks is Balanced', () {
      expect(SlaService.workloadFor('m1', openTasks(0)), Workload.balanced);
      expect(SlaService.workloadFor('m1', openTasks(2)), Workload.balanced);
    });

    test('3 to 4 open tasks is Heavy', () {
      expect(SlaService.workloadFor('m1', openTasks(3)), Workload.heavy);
      expect(SlaService.workloadFor('m1', openTasks(4)), Workload.heavy);
    });

    test('5 or more open tasks is Overloaded', () {
      expect(SlaService.workloadFor('m1', openTasks(5)), Workload.overloaded);
    });

    test('Done tasks and other members are not counted', () {
      final tasks = [
        ...openTasks(2),
        makeTask(
          id: 'done',
          due: DateTime(2026, 10, 20),
          status: TaskStatus.done,
          progress: 100,
        ),
        makeTask(id: 'other', assigneeId: 'm2', due: DateTime(2026, 10, 20)),
      ];
      expect(SlaService.openTaskCount('m1', tasks), 2);
      expect(SlaService.workloadFor('m1', tasks), Workload.balanced);
    });
  });

  group('needsAttention and message', () {
    test('lists only At Risk and Overdue, most urgent first', () {
      final tasks = [
        makeTask(id: 'ontrack', due: DateTime(2026, 10, 20)),
        makeTask(id: 'atrisk', due: DateTime(2026, 10, 7)),
        makeTask(id: 'overdue', due: DateTime(2026, 10, 4)),
        makeTask(
          id: 'done',
          due: DateTime(2026, 10, 4),
          status: TaskStatus.done,
          progress: 100,
        ),
      ];
      final ids = SlaService.needsAttention(tasks, now).map((t) => t.id);
      expect(ids.toList(), ['overdue', 'atrisk']);
    });

    test('message for a task due in 1 day', () {
      final task = makeTask(due: DateTime(2026, 10, 7), progress: 40);
      expect(
        SlaService.message(task, now),
        'Due in 1 day and only 40% of work is done',
      );
    });

    test('message for an overdue task', () {
      final task = makeTask(due: DateTime(2026, 10, 4), progress: 10);
      expect(
        SlaService.message(task, now),
        'Overdue by 1 day and only 10% of work is done',
      );
    });
  });
}
