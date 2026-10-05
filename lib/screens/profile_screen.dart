import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/user_avatar.dart';
import '../models/member.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  const ProfileScreen({super.key, required this.onThemeToggle, required this.isDark});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  Member? user;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { user = await AuthService(StorageService()).currentUser(); if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      children: [
        const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 22),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          UserAvatar(member: user!, radius: 34), const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user!.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4), Text(user!.title),
          ])),
        ]))),
        const SizedBox(height: 18),
        _row(Icons.edit_outlined, 'Edit Profile', 'Update your name and title', () async {
          await Navigator.pushNamed(context, '/edit-profile'); await _load();
        }),
        _row(Icons.dark_mode_outlined, 'App Settings', widget.isDark ? 'Dark mode is on' : 'Dark mode is off', () {
          Navigator.pushNamed(context, '/settings');
        }),
        _row(Icons.logout_rounded, 'Sign Out', 'End the current session', () async {
          await AuthService(StorageService()).signOut();
          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (_) => false);
        }, destructive: true),
      ],
    );
  }

  Widget _row(IconData icon, String title, String subtitle, VoidCallback onTap, {bool destructive = false}) =>
      Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
        leading: Icon(icon, color: destructive ? Colors.red : null),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: destructive ? Colors.red : null)),
        subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded), onTap: onTap,
      ));
}
