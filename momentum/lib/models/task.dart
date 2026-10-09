// TEMPORARY stand-in so SLA tests can run. Kamikazi owns the real file.
// Do not commit this. Replace it when her Task model arrives.

enum Priority { low, medium, high }

enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final String assigneeId;
  final DateTime createdAt;
  final DateTime dueDate;
  final Priority priority;
  final TaskStatus status;
  final int progress;
  final String notes;
  final DateTime? completedAt;

  const Task({
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
    this.completedAt,
  });

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
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        assigneeId: json['assigneeId'],
        createdAt: DateTime.parse(json['createdAt']),
        dueDate: DateTime.parse(json['dueDate']),
        priority: Priority.values.byName(json['priority']),
        status: TaskStatus.values.byName(json['status']),
        progress: json['progress'] ?? 0,
        notes: json['notes'] ?? '',
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt']),
      );
}
