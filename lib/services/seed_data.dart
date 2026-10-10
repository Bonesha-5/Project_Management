import '../models/member.dart';
import '../models/task.dart';

class SeedData {
  SeedData._();

  // Fixed ids so tasks can point to members.
  static const String sarahId = 'seed-member-sarah';
  static const String michaelId = 'seed-member-michael';
  static const String emilyId = 'seed-member-emily';
  static const String davidId = 'seed-member-david';
  static const String johnId = 'seed-member-john';

  /// The five sample team members. Only John Doe has a login.
  static List<Member> members() => [
    Member(
      id: sarahId,
      name: 'Sarah Lee',
      email: 'sarah@email.com',
      title: 'UI/UX Designer',
      password: '',
      avatarColor: 0xFFEC4899, // Pink
      hasLogin: false,
    ),
    Member(
      id: michaelId,
      name: 'Michael Kim',
      email: 'michael@email.com',
      title: 'Mobile Developer',
      password: '',
      avatarColor: 0xFF14B8A6, // Teal
      hasLogin: false,
    ),
    Member(
      id: emilyId,
      name: 'Emily Wong',
      email: 'emily@email.com',
      title: 'QA Tester',
      password: '',
      avatarColor: 0xFFF59E0B, // Amber
      hasLogin: false,
    ),
    Member(
      id: davidId,
      name: 'David Liu',
      email: 'david@email.com',
      title: 'Documentation',
      password: '',
      avatarColor: 0xFF7C3AED, // Primary Purple
      hasLogin: false,
    ),
    Member(
      id: johnId,
      name: 'John Doe',
      email: 'john@email.com',
      title: 'Project Manager',
      password: 'password123', // Simulated sign-in only, not real security.
      avatarColor: 0xFF4C1D95, // Deep Purple
      hasLogin: true,
    ),
  ];

  /// The twelve sample tasks, with dates relative to [now].
  static List<Task> tasks(DateTime now) {
    Task make({
      required String id,
      required String title,
      required String description,
      required String assigneeId,
      required Duration createdAgo,
      required Duration dueIn, // Negative means the due date has passed.
      required Priority priority,
      required TaskStatus status,
      required int progress,
      String notes = '',
    }) {
      return Task(
        id: id,
        title: title,
        description: description,
        assigneeId: assigneeId,
        createdAt: now.subtract(createdAgo),
        dueDate: now.add(dueIn),
        priority: priority,
        status: status,
        progress: progress.toDouble(),
        notes: notes,
      );
    }

    return [
      // ---------- On Track (due in more than 48 hours) ----------
      make(
        id: 'seed-task-01',
        title: 'Design Login Screen',
        description: 'Create the sign in layout in light and dark mode.',
        assigneeId: sarahId,
        createdAgo: const Duration(days: 2),
        dueIn: const Duration(days: 6),
        priority: Priority.high,
        status: TaskStatus.inProgress,
        progress: 30,
      ),
      make(
        id: 'seed-task-02',
        title: 'Build Statistics Charts',
        description: 'Bar chart of tasks by status using plain widgets.',
        assigneeId: michaelId,
        createdAgo: const Duration(days: 1),
        dueIn: const Duration(days: 7),
        priority: Priority.medium,
        status: TaskStatus.todo,
        progress: 0,
      ),
      make(
        id: 'seed-task-03',
        title: 'Write Widget Tests',
        description: 'Cover the shared form fields and buttons.',
        assigneeId: emilyId,
        createdAgo: const Duration(days: 2),
        dueIn: const Duration(days: 5),
        priority: Priority.medium,
        status: TaskStatus.todo,
        progress: 0,
      ),
      make(
        id: 'seed-task-04',
        title: 'Test Sign Up Flow',
        description: 'Check every validation message on Sign Up.',
        assigneeId: emilyId,
        createdAgo: const Duration(days: 1),
        dueIn: const Duration(days: 4),
        priority: Priority.low,
        status: TaskStatus.todo,
        progress: 0,
      ),
      make(
        id: 'seed-task-05',
        title: 'Prepare Demo Script',
        description: 'Order of screens and who speaks when.',
        assigneeId: davidId,
        createdAgo: const Duration(days: 2),
        dueIn: const Duration(days: 8),
        priority: Priority.low,
        status: TaskStatus.inProgress,
        progress: 20,
      ),

      // ---------- At Risk (not done, due in 48 hours or less) ----------
      make(
        id: 'seed-task-06',
        title: 'Implement Local Storage',
        description:
            'Save tasks locally so data persists after the app closes.',
        assigneeId: michaelId,
        // 4.5 days ago, due in 1 day: about 82% of the time is used.
        createdAgo: const Duration(days: 4, hours: 12),
        dueIn: const Duration(days: 1),
        priority: Priority.high,
        status: TaskStatus.inProgress,
        progress: 40,
      ),
      make(
        id: 'seed-task-07',
        title: 'Fix Overflow on Small Phones',
        description: 'Remove the yellow and black stripes on small screens.',
        assigneeId: emilyId,
        createdAgo: const Duration(days: 3),
        dueIn: const Duration(hours: 36),
        priority: Priority.high,
        status: TaskStatus.inProgress,
        progress: 50,
      ),
      make(
        id: 'seed-task-08',
        title: 'Review Pull Requests',
        description: 'Review open pull requests before the merge.',
        assigneeId: michaelId,
        createdAgo: const Duration(days: 2),
        dueIn: const Duration(hours: 40),
        priority: Priority.medium,
        status: TaskStatus.todo,
        progress: 10,
      ),

      // ---------- Overdue (not done, due date passed) ----------
      make(
        id: 'seed-task-09',
        title: 'Create Task Model',
        description: 'Task class with toJson and fromJson.',
        assigneeId: emilyId,
        createdAgo: const Duration(days: 8),
        dueIn: const Duration(days: -3),
        priority: Priority.medium,
        status: TaskStatus.inProgress,
        progress: 70,
      ),
      make(
        id: 'seed-task-10',
        title: 'Test Dark Mode Screens',
        description: 'Open every screen in dark mode and note problems.',
        assigneeId: emilyId,
        createdAgo: const Duration(days: 5),
        dueIn: const Duration(days: -1),
        priority: Priority.medium,
        status: TaskStatus.inProgress,
        progress: 60,
      ),

      // ---------- Completed (status Done, progress 100) ----------
      make(
        id: 'seed-task-11',
        title: 'Test Application',
        description: 'First full test run on the emulator.',
        assigneeId: davidId,
        createdAgo: const Duration(days: 9),
        dueIn: const Duration(days: -4),
        priority: Priority.low,
        status: TaskStatus.done,
        progress: 100,
      ),
      make(
        id: 'seed-task-12',
        title: 'Set Up GitHub Repository',
        description: 'Create the repository, branches and folder structure.',
        assigneeId: johnId,
        createdAgo: const Duration(days: 6),
        dueIn: const Duration(days: -2),
        priority: Priority.high,
        status: TaskStatus.done,
        progress: 100,
      ),
    ];
  }
}
