import 'package:flutter/material.dart';

import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/status_pill.dart';
import '../widgets/user_avatar.dart';
import 'add_member_screen.dart';
import 'member_tasks_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Member> _members = [];
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads members and tasks, then redraws the screen with setState.
  Future<void> _loadData() async {
    try {
      final members = await StorageService.getMembers();
      final tasks = await StorageService.getTasks();
      if (!mounted) return;
      setState(() {
        _members = members;
        _tasks = tasks;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load the team. Pull down to try again.';
        _isLoading = false;
      });
    }
  }

  /// Opens Add Member and reloads when the user comes back.
  Future<void> _openAddMember() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMemberScreen()),
    );
    await _loadData();
  }

  /// Opens one member's tasks and reloads when the user comes back.
  Future<void> _openMember(Member member) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberTasksScreen(member: member)),
    );
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Team Members',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton.filled(
                  onPressed: _openAddMember,
                  tooltip: 'Add member',
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _scrollableMessage(
        icon: Icons.error_outline_rounded,
        title: _errorMessage!,
        actionLabel: 'Try again',
        onAction: () {
          setState(() => _isLoading = true);
          _loadData();
        },
      );
    }
    if (_members.isEmpty) {
      return _scrollableMessage(
        icon: Icons.group_add_rounded,
        title: 'No team members yet',
        subtitle: 'Tap + to add the first person to your team.',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF15102A) : Colors.white;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (final member in _members)
                  _MemberRow(
                    member: member,
                    openTasks: SlaService.openTaskCount(member.id, _tasks),
                    workload: SlaService.workloadFor(member.id, _tasks),
                    onTap: () => _openMember(member),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty and error states. Scrollable so pull-to-refresh still works.
  Widget _scrollableMessage({
    required IconData icon,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 80, 32, 24),
        children: [
          Icon(icon, size: 48, color: muted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(onPressed: onAction, child: Text(actionLabel)),
            ),
          ],
        ],
      ),
    );
  }
}

/// One member: avatar, name, "title · N open" and the workload badge.
/// The whole row can be tapped to see the member's tasks.
class _MemberRow extends StatelessWidget {
  final Member member;
  final int openTasks;
  final Workload workload;
  final VoidCallback onTap;

  const _MemberRow({
    required this.member,
    required this.openTasks,
    required this.workload,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(150);
    final title = member.title.trim().isEmpty ? 'Team member' : member.title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              UserAvatar(name: member.name, color: Color(member.avatarColor)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$title · $openTasks open',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              WorkloadBadge(workload: workload),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
