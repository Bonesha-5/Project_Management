import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/auth_service.dart';

/// Screen 4.1 — Sign In
///
/// The first screen most users see. On app start, `main.dart`'s startup
/// gate checks for a saved session and sends the user straight to the
/// Dashboard if one exists. Otherwise it lands here.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────── Validators ───────────────────────────

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w\.\-]+@[\w\-]+(\.[\w\-]+)+$');
    if (!pattern.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return null;
  }

  // ─────────────────────────── Submit ───────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final user = await AuthService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user == null) {
        // Wrong email OR wrong password — same message, on purpose, so we
        // do not leak which accounts exist.
        _showSnack('Wrong email or password');
        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (_) => false);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Illustration ──
                // Built from plain widgets (no asset file needed). Two
                // stacked circles plus an upward arrow — a simple visual
                // metaphor for progress.
                Center(
                  child: SizedBox(
                    height: 140,
                    width: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: AppColors.softLavender,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: AppColors.lightPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 56,
                          color: AppColors.primaryPurple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Brand + tagline ──
                Center(
                  child: Text(
                    'Momentum',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Make Progress Visible',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

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

                // ── Password ──
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                const SizedBox(height: 24),

                // ── Sign In button ──
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
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 20),

                // ── Link to Sign Up ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pushNamed('/sign-up'),
                      child: const Text('Sign Up →'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}