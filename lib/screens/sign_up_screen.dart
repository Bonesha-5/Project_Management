import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/member.dart';
import '../services/auth_service.dart';

/// Screen 4.2 — Sign Up
///
/// Fields: Full name, Email, Role (dropdown), Password, Confirm password.
/// All fields are required. Email must look like an email and not already
/// exist. Password must be at least 6 characters and match the confirmation.
///
/// On success: the account is saved, the user is signed in, and the app
/// navigates to the Dashboard (using `pushNamedAndRemoveUntil` so back
/// cannot return to Sign Up).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // A GlobalKey ties the Form to its state so `_formKey.currentState!.validate()`
  // runs every field's validator and returns true only if all pass.
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _role; // selected role
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  // Roles shown in the dropdown. Add or remove as the team decides.
  static const _roles = <String>[
    'Developer',
    'Designer',
    'Project Manager',
    'Tester',
    'Team Lead',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ─────────────────────────── Validators ───────────────────────────
  // Each returns null when valid, or a short message that appears under
  // the field. This is the pattern the rubric asks for.

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    // Simple, readable check — good enough for coursework.
    final pattern = RegExp(r'^[\w\.\-]+@[\w\-]+(\.[\w\-]+)+$');
    if (!pattern.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ─────────────────────────── Submit ───────────────────────────

  Future<void> _submit() async {
    // 1. Validate everything at once. If any validator fails, the messages
    //    appear under the failing fields and we stop here.
    if (!_formKey.currentState!.validate()) return;
    if (_role == null) {
      _showSnack('Please select a role');
      return;
    }

    setState(() => _submitting = true);
    try {
      // 2. Build the Member. id is left empty so AuthService assigns one.
      final member = Member(
        id: '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        title: _role!,
        password: _passwordController.text,
        hasLogin: true,
        avatarColor: AppColors.primaryPurple.toARGB32(),
      );

      // 3. Save + sign in via AuthService.
      await AuthService.signUp(member);

      if (!mounted) return;
      // 4. Replace the whole stack so back from Dashboard does not return
      //    to Sign Up. See INTEGRATION POINT #1 in main.dart.
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (_) => false);
    } catch (e) {
      // 5. AuthService throws with a readable message. Strip "Exception: ".
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (!mounted) return;
      _showSnack(msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ─────────────────────────── Build ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // SafeArea keeps content away from the status bar and the notch.
      body: SafeArea(
        child: Column(
          children: [
            // Custom top bar with the ← back button described in the brief.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Create Account',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            // SingleChildScrollView so the keyboard does not overflow the form.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Full name ──
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          hintText: 'e.g. John Doe',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),

                      // ── Email ──
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // ── Role dropdown ──
                      // DropdownButtonFormField integrates with Form validation
                      // and shows the same border/label style as the text fields.
                      DropdownButtonFormField<String>(
                        value: _role,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          hintText: 'Select role',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: _roles
                            .map((r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _role = value),
                        validator: (v) =>
                            v == null ? 'Please select a role' : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Password ──
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'At least 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // ── Confirm password ──
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          hintText: 'Re-enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: _validateConfirm,
                      ),
                      const SizedBox(height: 24),

                      // ── Create Account button ──
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                      const SizedBox(height: 16),

                      // ── Link back to Sign In ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already registered? ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => Navigator.of(context)
                                    .pushReplacementNamed('/sign-in'),
                            child: const Text('Sign In →'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}