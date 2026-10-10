// ⚠️  TEMPORARY PLACEHOLDER — REPLACE WITH UWINEZA KEVINE'S storage_service.dart
//
// This file exists only so Byusa Martin's screens can compile and be tested
// before Kevine's real StorageService is merged. It matches the method
// signatures in the shared contract (section 3 of the team docs) but does
// NOT include her seed data, seed-once logic, or corruption tests.
//
// When the real file is merged from her branch, delete this file and let
// hers take its place. Nothing in Byusa's code needs to change as long as
// the method names match.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/member.dart';
import '../models/task.dart';

class StorageService {
  StorageService._();

  static const _kMembers = 'members';
  static const _kTasks = 'tasks';
  static const _kCurrentUserId = 'currentUserId';
  static const _kDarkMode = 'darkMode';

  // ─────────────────────────── Members ───────────────────────────

  static Future<List<Member>> getMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kMembers);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> saveMembers(List<Member> members) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(members.map((m) => m.toJson()).toList());
      return await prefs.setString(_kMembers, raw);
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────── Tasks (stubs) ───────────────────────────
  //
  // If Kamikazi's task.dart does not exist yet, comment out these two
  // methods AND the `import '../models/task.dart';` line above.

  static Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kTasks);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
      return await prefs.setString(_kTasks, raw);
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────── Session ───────────────────────────

  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kCurrentUserId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setCurrentUserId(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id == null) {
        await prefs.remove(_kCurrentUserId);
      } else {
        await prefs.setString(_kCurrentUserId, id);
      }
    } catch (_) {
      // silently ignore — see the error-handling rules in the brief
    }
  }

  // ─────────────────────────── Theme ───────────────────────────

  static Future<bool> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kDarkMode) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDarkMode, value);
    } catch (_) {
      // silently ignore
    }
  }
}