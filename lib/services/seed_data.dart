import '../models/member.dart';
import '../models/task.dart';

class SeedData {
  static List<Member> members() => [
        Member(id: 'm1', name: 'Byusa Martin', email: 'byusa@momentum.dev', title: 'Flutter Developer', password: 'password', hasLogin: true),
        Member(id: 'm2', name: 'Jospin Nganji', email: 'jospin@momentum.dev', title: 'SLA & Insights Lead'),
        Member(id: 'm3', name: 'Uwineza Kevine', email: 'uwineza@momentum.dev', title: 'Data & Tasks Lead'),
        Member(id: 'm4', name: 'Aline Mukamana', email: 'aline@momentum.dev', title: 'UI Designer'),
        Member(id: 'm5', name: 'Eric Habimana', email: 'eric@momentum.dev', title: 'QA Engineer'),
      ];

  static List<Task> tasks() {
    final now = DateTime.now();
    return [
      Task(id: 't1', title: 'Design authentication flow', description: 'Prepare sign-in and sign-up UX.', assigneeId: 'm1', createdAt: now.subtract(const Duration(days: 4)), dueDate: now.add(const Duration(days: 3)), priority: Priority.high, status: TaskStatus.inProgress, progress: 70, notes: 'UI flow is nearly complete.'),
      Task(id: 't2', title: 'Implement SLA service', description: 'Build status and time-used calculations.', assigneeId: 'm2', createdAt: now.subtract(const Duration(days: 5)), dueDate: now.add(const Duration(days: 2)), priority: Priority.high, status: TaskStatus.inProgress, progress: 60),
      Task(id: 't3', title: 'Create task storage layer', description: 'Persist tasks and members locally.', assigneeId: 'm3', createdAt: now.subtract(const Duration(days: 6)), dueDate: now.subtract(const Duration(hours: 5)), priority: Priority.high, status: TaskStatus.inProgress, progress: 55),
      Task(id: 't4', title: 'Prepare dashboard cards', description: 'Build project overview and attention cards.', assigneeId: 'm2', createdAt: now.subtract(const Duration(days: 2)), dueDate: now.add(const Duration(hours: 30)), priority: Priority.medium, status: TaskStatus.todo, progress: 20),
      Task(id: 't5', title: 'Write unit tests', description: 'Cover SLA boundary conditions.', assigneeId: 'm5', createdAt: now.subtract(const Duration(days: 7)), dueDate: now.add(const Duration(days: 6)), priority: Priority.medium, status: TaskStatus.todo, progress: 10),
      Task(id: 't6', title: 'Build task cards', description: 'Reusable task list card.', assigneeId: 'm3', createdAt: now.subtract(const Duration(days: 3)), dueDate: now.add(const Duration(days: 5)), priority: Priority.low, status: TaskStatus.inProgress, progress: 45),
      Task(id: 't7', title: 'Create profile screen', description: 'Profile and settings screens.', assigneeId: 'm1', createdAt: now.subtract(const Duration(days: 8)), dueDate: now.subtract(const Duration(days: 2)), priority: Priority.medium, status: TaskStatus.done, progress: 100),
      Task(id: 't8', title: 'Review visual system', description: 'Review purple palette and components.', assigneeId: 'm4', createdAt: now.subtract(const Duration(days: 5)), dueDate: now.add(const Duration(days: 4)), priority: Priority.low, status: TaskStatus.done, progress: 100),
      Task(id: 't9', title: 'Test persistence', description: 'Verify data after restart.', assigneeId: 'm5', createdAt: now.subtract(const Duration(days: 2)), dueDate: now.add(const Duration(days: 1)), priority: Priority.high, status: TaskStatus.todo, progress: 0),
      Task(id: 't10', title: 'Add team member flow', description: 'Member creation and assignment.', assigneeId: 'm2', createdAt: now.subtract(const Duration(days: 2)), dueDate: now.add(const Duration(hours: 18)), priority: Priority.medium, status: TaskStatus.todo, progress: 25),
      Task(id: 't11', title: 'Prepare technical report', description: 'Challenges, solutions and citations.', assigneeId: 'm2', createdAt: now.subtract(const Duration(days: 10)), dueDate: now.add(const Duration(days: 7)), priority: Priority.medium, status: TaskStatus.inProgress, progress: 50),
      Task(id: 't12', title: 'Demo rehearsal', description: 'Practice the 10-15 minute demo.', assigneeId: 'm5', createdAt: now.subtract(const Duration(days: 1)), dueDate: now.add(const Duration(days: 2)), priority: Priority.high, status: TaskStatus.todo, progress: 0),
    ];
  }
}
