import 'dart:convert';

enum Priority { low, medium, high }

enum TaskStatus { todo, inProgress, done }

extension PriorityLabel on Priority {
  String get label => switch (this) {
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
  };
}

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.done => 'Done',
  };
}

class Task {
  final String id;
  String title;
  String description;
  String assigneeId;
  DateTime createdAt;
  DateTime dueDate;
  Priority priority;
  TaskStatus _status;
  double _progress;
  String notes;

  /// When the task was marked Done (used for the on-time rate).
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.assigneeId,
    required this.createdAt,
    required this.dueDate,
    this.priority = Priority.medium,
    TaskStatus status = TaskStatus.todo,
    double progress = 0,
    this.notes = '',
    this.completedAt,
  }) : _status = status,
       _progress = status == TaskStatus.done
           ? 100
           : progress.clamp(0, 100).toDouble();

  TaskStatus get status => _status;
  set status(TaskStatus value) {
    if (value == TaskStatus.done && _status != TaskStatus.done) {
      completedAt = DateTime.now();
    } else if (value != TaskStatus.done) {
      completedAt = null;
    }
    _status = value;
    if (value == TaskStatus.done) _progress = 100;
  }

  double get progress => _status == TaskStatus.done ? 100 : _progress;
  set progress(double value) => _progress = value.clamp(0, 100).toDouble();

  bool get isDone => _status == TaskStatus.done;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assigneeId,
    DateTime? createdAt,
    DateTime? dueDate,
    Priority? priority,
    TaskStatus? status,
    double? progress,
    String? notes,
    DateTime? completedAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    assigneeId: assigneeId ?? this.assigneeId,
    createdAt: createdAt ?? this.createdAt,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    notes: notes ?? this.notes,
    completedAt: completedAt ?? this.completedAt,
  );

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
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Untitled task',
    description: json['description']?.toString() ?? '',
    assigneeId: json['assigneeId']?.toString() ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    dueDate:
        DateTime.tryParse(json['dueDate']?.toString() ?? '') ??
        DateTime.now().add(const Duration(days: 1)),
    priority: Priority.values.firstWhere(
      (e) => e.name == json['priority']?.toString(),
      orElse: () => Priority.medium,
    ),
    status: TaskStatus.values.firstWhere(
      (e) => e.name == json['status']?.toString(),
      orElse: () => TaskStatus.todo,
    ),
    progress: (json['progress'] is num)
        ? (json['progress'] as num).toDouble()
        : double.tryParse(json['progress']?.toString() ?? '') ?? 0,
    notes: json['notes']?.toString() ?? '',
    completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
  );

  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
