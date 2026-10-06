import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 40,
  });

  /// Colours a new member can get (from the design palette).
  static const List<int> palette = [
    0xFF7C3AED, // Primary Purple
    0xFFEC4899, // Pink
    0xFF14B8A6, // Teal
    0xFFF59E0B, // Amber
    0xFF4C1D95, // Deep Purple
    0xFFEF4444, // Red
  ];

  /// Picks a palette colour from the name, so the same name always gets
  /// the same colour. Used when creating a member: avatarColor: ...
  static int colorValueForName(String name) {
    final sum = name.trim().codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[sum % palette.length];
  }

  /// The initials shown inside the circle.
  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsOf(name);
    final isEmpty = initials == '?';
    final background = isEmpty ? const Color(0xFFEDE9FE) : color;
    final foreground = isEmpty ? const Color(0xFF7C3AED) : Colors.white;

    return Semantics(
      label: isEmpty ? 'No name yet' : name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Text(
          initials,
          style: TextStyle(
            color: foreground,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
