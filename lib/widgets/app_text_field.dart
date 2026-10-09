import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  // Agreed in the shared contract:
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  // Optional extras (safe to ignore):
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.onChanged,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark ? const Color(0xFF0D0A17) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2A2340)
        : const Color(0xFFE4DDF7);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          textInputAction: textInputAction,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(110),
              fontSize: 14,
            ),
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: fillColor,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: border(borderColor),
            enabledBorder: border(borderColor),
            focusedBorder: border(theme.colorScheme.primary, 1.5),
            errorBorder: border(theme.colorScheme.error),
            focusedErrorBorder: border(theme.colorScheme.error, 1.5),
          ),
        ),
      ],
    );
  }
}

/// Shared input checks. Each returns an error message, or null if valid.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Required field. Use as: validator: Validators.required('Full name')
  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }

  /// Required email with a valid format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email, for example name@email.com';
    }
    return null;
  }

  /// Email that may be left empty, but must be valid if typed.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }

  /// Required password with at least 6 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Confirm password must match the first password field.
  /// Use as: validator: Validators.confirmPassword(_passwordController)
  static String? Function(String?) confirmPassword(
    TextEditingController passwordController,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != passwordController.text) return 'Passwords do not match';
      return null;
    };
  }

  /// Quick check outside a Form (for example in a service).
  static bool isValidEmail(String value) =>
      _emailPattern.hasMatch(value.trim());
}
