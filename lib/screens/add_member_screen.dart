import 'package:flutter/material.dart';

import '../models/member.dart';
import '../services/storage_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/user_avatar.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSaving = false;
  String? _duplicateEmailError;

  @override
  void dispose() {
    // Controllers must be cleaned up when the screen closes.
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Checks the form, then saves the new member through StorageService.
  Future<void> _saveMember() async {
    setState(() => _duplicateEmailError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    try {
      // An email can only belong to one member.
      if (email.isNotEmpty) {
        final members = await StorageService.getMembers();
        final used = members.any(
          (m) => m.email.toLowerCase() == email.toLowerCase(),
        );
        if (used) {
          setState(() {
            _duplicateEmailError = 'This email is already used by a member';
            _isSaving = false;
          });
          _formKey.currentState!.validate(); // show the message under Email
          return;
        }
      }

      final member = Member(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        title: _titleController.text.trim(),
        password: '',
        avatarColor: UserAvatar.colorValueForName(name),
        hasLogin: false,
      );

      final saved = await StorageService.addOrUpdateMember(member);
      if (!mounted) return;

      if (saved) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$name was added to the team')));
        Navigator.pop(context, true); // true = "something changed"
      } else {
        _showSaveError();
      }
    } catch (e) {
      if (!mounted) return;
      _showSaveError();
    }
  }

  void _showSaveError() {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save the member. Please try again.'),
      ),
    );
  }

  /// Email check: format first, then the duplicate message if needed.
  String? _validateEmail(String? value) {
    final formatError = Validators.optionalEmail(value);
    if (formatError != null) return formatError;
    return _duplicateEmailError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Member',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: UserAvatar(
                    name: _nameController.text,
                    color: Color(
                      UserAvatar.colorValueForName(_nameController.text),
                    ),
                    size: 72,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full name *',
                  controller: _nameController,
                  hint: 'e.g. Grace Uwase',
                  validator: Validators.required('Full name'),
                  textInputAction: TextInputAction.next,
                  // Redraw so the avatar preview shows the new initials.
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Role / Title',
                  controller: _titleController,
                  hint: 'e.g. Backend Developer',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'name@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                  onChanged: (_) {
                    if (_duplicateEmailError != null) {
                      setState(() => _duplicateEmailError = null);
                    }
                  },
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Save Member',
                  onPressed: _saveMember,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
