import '../models/member.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService storage;
  AuthService(this.storage);

  Future<List<Member>> _members() => storage.getMembers();

  Future<Member?> currentUser() async {
    final id = await storage.currentUserId();
    if (id == null) return null;
    final members = await _members();
    for (final m in members) {
      if (m.id == id) return m;
    }
    await storage.setCurrentUserId(null);
    return null;
  }

  Future<Member> signUp({
    required String name,
    required String email,
    required String title,
    required String password,
  }) async {
    final members = await _members();
    if (members.any((m) => m.email.toLowerCase() == email.toLowerCase())) {
      throw AuthException('An account with this email already exists.');
    }
    final member = Member(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      title: title.trim(),
      password: password,
      hasLogin: true,
    );
    members.add(member);
    await storage.saveMembers(members);
    await storage.setCurrentUserId(member.id);
    return member;
  }

  Future<Member> signIn(String email, String password) async {
    final members = await _members();
    final matches = members.where(
      (m) => m.email.toLowerCase() == email.trim().toLowerCase() && m.password == password,
    );
    if (matches.isEmpty) throw AuthException('Wrong email or password');
    final member = matches.first;
    await storage.setCurrentUserId(member.id);
    return member;
  }

  Future<void> signOut() => storage.setCurrentUserId(null);

  Future<Member> updateProfile(Member user, {
    required String name,
    required String email,
    required String title,
  }) async {
    final members = await _members();
    if (members.any((m) => m.id != user.id && m.email.toLowerCase() == email.toLowerCase())) {
      throw AuthException('That email is already in use.');
    }
    user.name = name.trim();
    user.email = email.trim();
    user.title = title.trim();
    await storage.saveMembers(members);
    return user;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
