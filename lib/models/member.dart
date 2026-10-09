import 'dart:ui' show Color;

/// Represents a person in the Momentum app.
///
/// A Member can be one of two kinds:
///  * A "login" member: created through Sign Up. [hasLogin] is true and
///    [password] is set. These are the accounts used by AuthService.
///  * A "team" member: added on the Add Member screen by Uwineza Kevine.
///    [hasLogin] is false, [password] is empty, and they can only be
///    assigned tasks — they cannot sign in.
///
/// The fields and their JSON keys match the shared contract agreed with
/// the rest of the team, so StorageService can serialize and deserialize
/// this class without modification.
class Member {
  final String id;
  final String name;
  final String email;
  final String title;
  final String password;

  /// Flutter colour value stored as an int so it survives JSON.
  /// Use `Member.avatarColorValue` or `Color(member.avatarColor)` in the UI.
  final int avatarColor;

  /// True if this person has a login account (created via Sign Up).
  /// False if they were added as a team member only.
  final bool hasLogin;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.title,
    this.password = '',
    this.avatarColor = 0xFF7C3AED, // default Primary Purple
    this.hasLogin = false,
  });

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'title': title,
        'password': password,
        'avatarColor': avatarColor,
        'hasLogin': hasLogin,
      };

  /// Safe deserialization: every field falls back to a sensible default
  /// so a corrupted or partial record does not crash the app.
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      title: json['title'] as String? ?? '',
      password: json['password'] as String? ?? '',
      avatarColor: json['avatarColor'] as int? ?? 0xFF7C3AED,
      hasLogin: json['hasLogin'] as bool? ?? false,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  /// A copy with selected fields replaced. Used by Edit Profile.
  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? title,
    String? password,
    int? avatarColor,
    bool? hasLogin,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      title: title ?? this.title,
      password: password ?? this.password,
      avatarColor: avatarColor ?? this.avatarColor,
      hasLogin: hasLogin ?? this.hasLogin,
    );
  }

  /// Up to two uppercase initials from the name — used by the avatar.
  /// "John Doe" -> "JD", "Sarah" -> "S", "" -> "?"
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// The avatar colour as a Flutter [Color].
  Color get avatarColorValue => Color(avatarColor);

  @override
  String toString() =>
      'Member(id: $id, name: $name, email: $email, hasLogin: $hasLogin)';
}