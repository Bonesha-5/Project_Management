import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/member.dart';
import '../models/task.dart';
import 'seed_data.dart';

class StorageService {
  StorageService._();

  // Saved keys
  static const String keyTasks = 'tasks';
  static const String keyMembers = 'members';
  static const String keyCurrentUserId = 'currentUserId';
  static const String keyDarkMode = 'darkMode';
  static const String keySeeded = 'seeded';

  static Future<void>? _seeding;

  static Future<void> ensureSeeded() {
    return _seeding ??= _seedIfFirstRun();
  }

  static Future<void> _seedIfFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(keySeeded) ?? false) return;

      // Never overwrite real data if some already exists.
      if (!prefs.containsKey(keyMembers)) {
        await prefs.setString(
          keyMembers,
          _encode(SeedData.members().map((m) => m.toJson())),
        );
      }
      if (!prefs.containsKey(keyTasks)) {
        await prefs.setString(
          keyTasks,
          _encode(SeedData.tasks(DateTime.now()).map((t) => t.toJson())),
        );
      }
      await prefs.setBool(keySeeded, true);
    } catch (e) {
      debugPrint('StorageService: could not load sample data: $e');
      _seeding = null; // Try again next time instead of giving up forever.
    }
  }

  // ---------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------

  /// Returns every saved task. Returns an empty list if nothing is saved
  /// or the saved text is corrupted. Never throws.
  static Future<List<Task>> getTasks() async {
    await ensureSeeded();
    try {
      final prefs = await SharedPreferences.getInstance();
      return _decodeList(prefs.getString(keyTasks), Task.fromJson, 'task');
    } catch (e) {
      debugPrint('StorageService.getTasks failed: $e');
      return <Task>[];
    }
  }

  /// Saves the whole task list. Returns false if saving failed.
  static Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        keyTasks,
        _encode(tasks.map((t) => t.toJson())),
      );
    } catch (e) {
      debugPrint('StorageService.saveTasks failed: $e');
      return false;
    }
  }

  /// Helper: adds a new task, or replaces the task with the same id.
  /// Returns false if saving failed.
  static Future<bool> addOrUpdateTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      tasks.add(task);
    } else {
      tasks[index] = task;
    }
    return saveTasks(tasks);
  }

  /// Helper: deletes the task with this id. Returns false if saving failed.
  static Future<bool> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    return saveTasks(tasks);
  }

  // ---------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------

  /// Returns every saved member (people who signed up and people added on
  /// Add Member). Empty list if missing or corrupted. Never throws.
  static Future<List<Member>> getMembers() async {
    await ensureSeeded();
    try {
      final prefs = await SharedPreferences.getInstance();
      return _decodeList(
        prefs.getString(keyMembers),
        Member.fromJson,
        'member',
      );
    } catch (e) {
      debugPrint('StorageService.getMembers failed: $e');
      return <Member>[];
    }
  }

  /// Saves the whole member list. Returns false if saving failed.
  static Future<bool> saveMembers(List<Member> members) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        keyMembers,
        _encode(members.map((m) => m.toJson())),
      );
    } catch (e) {
      debugPrint('StorageService.saveMembers failed: $e');
      return false;
    }
  }

  /// Helper: adds a new member, or replaces the member with the same id.
  /// Returns false if saving failed.
  static Future<bool> addOrUpdateMember(Member member) async {
    final members = await getMembers();
    final index = members.indexWhere((m) => m.id == member.id);
    if (index == -1) {
      members.add(member);
    } else {
      members[index] = member;
    }
    return saveMembers(members);
  }

  // ---------------------------------------------------------------------
  // Signed-in user (simulated sign-in)
  // ---------------------------------------------------------------------

  /// The id of the signed-in member, or null when nobody is signed in.
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(keyCurrentUserId);
    } catch (e) {
      debugPrint('StorageService.getCurrentUserId failed: $e');
      return null;
    }
  }

  /// Saves who is signed in. Pass null to sign out.
  static Future<void> setCurrentUserId(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id == null) {
        await prefs.remove(keyCurrentUserId);
      } else {
        await prefs.setString(keyCurrentUserId, id);
      }
    } catch (e) {
      debugPrint('StorageService.setCurrentUserId failed: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Dark mode setting
  // ---------------------------------------------------------------------

  /// Whether dark mode is on. Defaults to false (light mode).
  static Future<bool> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyDarkMode) ?? false;
    } catch (e) {
      debugPrint('StorageService.getDarkMode failed: $e');
      return false;
    }
  }

  /// Remembers the dark mode choice after the app is closed.
  static Future<void> setDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyDarkMode, value);
    } catch (e) {
      debugPrint('StorageService.setDarkMode failed: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Development and testing helpers
  // ---------------------------------------------------------------------

  /// Deletes everything so the sample data loads again on the next read.
  /// Use while testing or before recording the demo. Do not call it from
  /// a normal screen.
  static Future<void> resetAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _seeding = null;
    } catch (e) {
      debugPrint('StorageService.resetAll failed: $e');
    }
  }

  /// Lets unit tests start each test from a clean state.
  @visibleForTesting
  static void resetCacheForTests() => _seeding = null;

  // ---------------------------------------------------------------------
  // Private JSON helpers
  // ---------------------------------------------------------------------

  static String _encode(Iterable<Map<String, dynamic>> items) =>
      jsonEncode(items.toList());

  /// Turns saved JSON text back into objects. If the whole text is broken
  /// it returns an empty list. If only one item is broken, that item is
  /// skipped and the rest are kept, so one bad record cannot lose all data.
  static List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
    String label,
  ) {
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];
      final result = <T>[];
      for (final item in decoded) {
        try {
          if (item is Map) {
            result.add(fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          debugPrint('StorageService: skipped a corrupted $label: $e');
        }
      }
      return result;
    } catch (e) {
      debugPrint('StorageService: saved ${label}s are corrupted: $e');
      return <T>[];
    }
  }
}
