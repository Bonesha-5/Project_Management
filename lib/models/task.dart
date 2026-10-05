import 'dart:convert';

enum Priority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  String title;
  String description;
  String assigneeId;
  DateTime createdAt;
  DateTime dueDate;
  Priority priority;
  TaskStatus status;
  double progress;
  String notes;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.assigneeId,
    required this.createdAt,
    required this.dueDate,
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    this.progress = 0,
    this.notes = '',
  });

  bool get isDone => status == TaskStatus.done;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'assigneeId': assigneeId,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'progress': progress,
        'notes': notes,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled task',
        description: json['description']?.toString() ?? '',
        assigneeId: json['assigneeId']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? '') ??
            DateTime.now().add(const Duration(days: 1)),
        priority: Priority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => Priority.medium,
        ),
        status: TaskStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TaskStatus.todo,
        ),
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        notes: json['notes']?.toString() ?? '',
      );

  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String raw) {
    final data = jsonDecode(raw);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
