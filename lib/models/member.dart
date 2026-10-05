import 'dart:convert';

class Member {
  final String id;
  String name;
  String email;
  String title;
  String password;
  int avatarColor;
  bool hasLogin;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.title,
    this.password = '',
    this.avatarColor = 0xFF7C3AED,
    this.hasLogin = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'title': title,
        'password': password,
        'avatarColor': avatarColor,
        'hasLogin': hasLogin,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown',
        email: json['email']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Team Member',
        password: json['password']?.toString() ?? '',
        avatarColor: (json['avatarColor'] as num?)?.toInt() ?? 0xFF7C3AED,
        hasLogin: json['hasLogin'] == true,
      );

  static String encodeList(List<Member> members) =>
      jsonEncode(members.map((m) => m.toJson()).toList());

  static List<Member> decodeList(String raw) {
    final data = jsonDecode(raw);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Member.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
