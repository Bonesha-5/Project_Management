import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/member.dart';
import '../services/auth_service.dart';

/// Screen 4.3 — Profile
///
/// Shows the currently signed-in user's initials, name, and title, plus
/// three rows: Edit Profile, App Settings, Sign Out. Email is deliberately
/// NOT displayed here (per the brief).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Member? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.currentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  // ─────────────────────────── Actions ───────────────────────────

  Future<void> _openEditProfile() async {
    // await the push, then reload when the user comes back — so any saved
    // change is reflected immediately.
    await Navigator.of(context).pushNamed('/edit-profile');
    await _load();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).pushNamed('/app-settings');
    // Theme is managed by main.dart; nothing to reload here.
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use Momentum.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (_) => false);
  }

  // ─────────────────────────── Build ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Safety: if there is no user for any reason, send to Sign In.
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _user!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            const SizedBox(height: 8),

            // ── Avatar ──
            Center(
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: user.avatarColorValue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Name ──
            Center(
              child: Text(
                user.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // ── Title (NOT email — per the brief) ──
            Center(
              child: Text(
                user.title.isEmpty ? 'Team Member' : user.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Rows ──
            _ProfileRow(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: _openEditProfile,
            ),
            const SizedBox(height: 8),
            _ProfileRow(
              icon: Icons.settings_outlined,
              label: 'App Settings',
              onTap: _openSettings,
            ),
            const SizedBox(height: 8),
            _ProfileRow(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              onTap: _confirmSignOut,
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable row inside the Profile screen.
class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = destructive ? AppTheme.red : theme.colorScheme.onSurface;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: colour),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(color: colour),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
