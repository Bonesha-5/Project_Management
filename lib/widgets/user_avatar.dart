import 'package:flutter/material.dart';
import '../models/member.dart';

class UserAvatar extends StatelessWidget {
  final Member member;
  final double radius;
  const UserAvatar({super.key, required this.member, this.radius = 22});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: Color(member.avatarColor),
        child: Text(_initials(member.name),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      );
}
