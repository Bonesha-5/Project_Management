import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/models/task.dart';
import 'package:momentum/services/sla_service.dart';

Task makeTask({required DateTime created, required DateTime due, TaskStatus status=TaskStatus.todo, double progress=0}) =>
    Task(id:'x',title:'Test',assigneeId:'m',createdAt:created,dueDate:due,status:status,progress:progress);

void main() {
  final now = DateTime(2026, 10, 5, 12);
  test('completed when status is Done', () => expect(SlaService.computeStatus(makeTask(created:now.subtract(const Duration(days:2)),due:now.add(const Duration(days:2)),status:TaskStatus.done,progress:100),now),SlaStatus.completed));
  test('completed at 100 percent', () => expect(SlaService.computeStatus(makeTask(created:now.subtract(const Duration(days:2)),due:now.add(const Duration(days:2)),progress:100),now),SlaStatus.completed));
  test('overdue after due date', () => expect(SlaService.computeStatus(makeTask(created:now.subtract(const Duration(days:2)),due:now.subtract(const Duration(minutes:1))),now),SlaStatus.overdue));
  test('at risk exactly 48 hours', () => expect(SlaService.computeStatus(makeTask(created:now.subtract(const Duration(days:2)),due:now.add(const Duration(hours:48))),now),SlaStatus.atRisk));
  test('at risk below 48 hours', () => expect(SlaService.computeStatus(makeTask(created:now.subtract(const Duration(days:2)),due:now.add(const Duration(hours:12))),now),SlaStatus.atRisk));
  test('on track above 48 hours', () => expect(SlaService.computeStatus(makeTask(created:now,due:now.add(const Duration(days:4))),now),SlaStatus.onTrack));
  test('time used clamps to zero before start', () => expect(SlaService.timeUsedPercent(makeTask(created:now.add(const Duration(days:1)),due:now.add(const Duration(days:3))),now),0));
  test('time used reaches 100 at due date', () => expect(SlaService.timeUsedPercent(makeTask(created:now.subtract(const Duration(days:2)),due:now),now),100));
  test('empty project progress is zero', () => expect(SlaService.projectProgress([]),0));
  test('100 percent project progress', () => expect(SlaService.projectProgress([makeTask(created:now,due:now.add(const Duration(days:1)),progress:100)]),100));
}
