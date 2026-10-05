import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await AuthService(StorageService()).signIn(email.text, password.text);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 50, 28, 28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72, width: 72,
                    decoration: BoxDecoration(color: AppTheme.lightPurple, borderRadius: BorderRadius.circular(22)),
                    child: const Icon(Icons.bolt_rounded, color: AppTheme.purple, size: 42),
                  ),
                  const SizedBox(height: 28),
                  const Text('Momentum', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Make Progress Visible', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 40),
                  AppTextField(controller: email, label: 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) return 'Enter a valid email';
                        return null;
                      }),
                  const SizedBox(height: 16),
                  AppTextField(controller: password, label: 'Password', prefixIcon: Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 22),
                  AppButton(label: 'Sign In', onPressed: submit, loading: loading),
                  const SizedBox(height: 22),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/sign-up'),
                      child: const Text("Don't have an account? Sign Up →"),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text('Demo account: byusa@momentum.dev / password',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
