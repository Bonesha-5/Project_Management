import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_management/services/seed_data.dart';
import 'package:project_management/services/sla_service.dart';
import 'package:project_management/services/storage_service.dart';

void main() {
  // Every test starts from fresh fake storage.
  void startWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    StorageService.resetCacheForTests();
  }

  test('first run loads 5 sample members and 12 sample tasks', () async {
    startWith({});
    expect((await StorageService.getMembers()).length, 5);
    expect((await StorageService.getTasks()).length, 12);
  });

  test('sample tasks cover all four SLA statuses (5/3/2/2)', () {
    final now = DateTime.now();
    final counts = SlaService.countByStatus(SeedData.tasks(now), now);
    expect(counts[SlaStatus.onTrack], 5);
    expect(counts[SlaStatus.atRisk], 3);
    expect(counts[SlaStatus.overdue], 2);
    expect(counts[SlaStatus.completed], 2);
  });

  test('sample data is not loaded again after the first run', () async {
    startWith({'seeded': true});
    expect(await StorageService.getTasks(), isEmpty);
    expect(await StorageService.getMembers(), isEmpty);
  });

  test(
    'corrupted task data returns an empty list instead of crashing',
    () async {
      startWith({'seeded': true, 'tasks': 'this is {not json'});
      expect(await StorageService.getTasks(), isEmpty);
    },
  );

  test('saved tasks survive a reload', () async {
    startWith({'seeded': true});
    final tasks = SeedData.tasks(DateTime.now()).take(3).toList();
    expect(await StorageService.saveTasks(tasks), isTrue);
    final loaded = await StorageService.getTasks();
    expect(loaded.map((t) => t.id), tasks.map((t) => t.id));
  });

  test('deleteTask removes only that task', () async {
    startWith({});
    await StorageService.deleteTask('seed-task-01');
    final ids = (await StorageService.getTasks()).map((t) => t.id);
    expect(ids, isNot(contains('seed-task-01')));
    expect(ids.length, 11);
  });

  test('current user is remembered and cleared on sign out', () async {
    startWith({});
    expect(await StorageService.getCurrentUserId(), isNull);
    await StorageService.setCurrentUserId('abc');
    expect(await StorageService.getCurrentUserId(), 'abc');
    await StorageService.setCurrentUserId(null);
    expect(await StorageService.getCurrentUserId(), isNull);
  });

  test('dark mode defaults to false and is remembered', () async {
    startWith({});
    expect(await StorageService.getDarkMode(), isFalse);
    await StorageService.setDarkMode(true);
    expect(await StorageService.getDarkMode(), isTrue);
  });
}
