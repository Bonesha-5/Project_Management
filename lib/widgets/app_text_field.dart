import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        validator: validator ?? _required,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        ),
      );

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;
}
