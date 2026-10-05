import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final role = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    for (final c in [name, email, role, password, confirm]) c.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await AuthService(StorageService()).signUp(
        name: name.text, email: email.text, title: role.text, password: password.text,
      );
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create Account')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(children: [
                AppTextField(controller: name, label: 'Full name', prefixIcon: Icons.person_outline),
                const SizedBox(height: 14),
                AppTextField(controller: email, label: 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) return 'Enter a valid email';
                    return null;
                  }),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
                  items: const ['Flutter Developer','Project Lead','UI Designer','QA Engineer','Data & Tasks Lead']
                      .map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                  validator: (v) => v == null ? 'Role is required' : null,
                  onChanged: (v) => role.text = v ?? '',
                ),
                const SizedBox(height: 14),
                AppTextField(controller: password, label: 'Password', obscureText: true, prefixIcon: Icons.lock_outline,
                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null),
                const SizedBox(height: 14),
                AppTextField(controller: confirm, label: 'Confirm password', obscureText: true, prefixIcon: Icons.lock_reset_outlined,
                  validator: (v) => v != password.text ? 'Passwords do not match' : null),
                const SizedBox(height: 24),
                AppButton(label: 'Create Account', onPressed: submit, loading: loading, icon: Icons.person_add_alt_1),
                const SizedBox(height: 14),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Sign In')),
              ]),
            ),
          ),
        ),
      );
}
