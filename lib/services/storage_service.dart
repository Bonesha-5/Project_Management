import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/task.dart';

class StorageService {
  static const _tasksKey = 'momentum_tasks';
  static const _membersKey = 'momentum_members';
  static const _userKey = 'momentum_current_user';
  static const _themeKey = 'momentum_dark_mode';
  static const _seededKey = 'momentum_seeded';

  Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tasksKey);
      if (raw == null || raw.isEmpty) return [];
      return Task.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tasksKey, Task.encodeList(tasks));
    } catch (e) {
      throw StorageException('Could not save tasks. Please try again.');
    }
  }

  Future<List<Member>> getMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_membersKey);
      if (raw == null || raw.isEmpty) return [];
      return Member.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMembers(List<Member> members) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_membersKey, Member.encodeList(members));
    } catch (_) {
      throw StorageException('Could not save the member. Please try again.');
    }
  }

  Future<String?> currentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setCurrentUserId(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id == null) {
        await prefs.remove(_userKey);
      } else {
        await prefs.setString(_userKey, id);
      }
    } catch (_) {
      throw StorageException('Could not update the session.');
    }
  }

  Future<bool> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themeKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  Future<bool> getSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seededKey) ?? false;
  }

  Future<void> setSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_membersKey);
    await prefs.remove(_userKey);
    await prefs.remove(_seededKey);
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => message;
}
