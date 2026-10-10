import '../models/member.dart';
import 'storage_service.dart';

/// Simulated local authentication.
///
/// This is NOT production security. Passwords are compared as plain text
/// against locally stored Member records, because the assignment explicitly
/// says sign-in does not need a real authentication service. This is fine for
/// a coursework demo but must not be used for anything real.
///
/// All methods are static so any screen can call them without managing an
/// instance, matching the StorageService pattern agreed with the team.
class AuthService {
  AuthService._(); // no instances

  // ---------------------------------------------------------------------------
  // Sign Up
  // ---------------------------------------------------------------------------

  /// Creates a new login account.
  ///
  /// Throws:
  ///  * `Exception('Email already in use')` if a member with the same email
  ///    (case-insensitive) exists.
  ///  * `Exception('Could not save the account. Please try again.')` if the
  ///    underlying StorageService fails to write.
  static Future<Member> signUp(Member member) async {
    final members = await StorageService.getMembers();
    final email = member.email.trim().toLowerCase();

    final exists = members.any((m) => m.email.trim().toLowerCase() == email);
    if (exists) {
      throw Exception('Email already in use');
    }

    // Give the new account an id if it does not have one, and mark it as a
    // login account so it appears in AuthService.currentUser / signIn.
    final newMember = member.copyWith(
      id: member.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : member.id,
      hasLogin: true,
    );

    final updated = [...members, newMember];
    final ok = await StorageService.saveMembers(updated);
    if (!ok) {
      throw Exception('Could not save the account. Please try again.');
    }

    // Sign the new user in immediately.
    await StorageService.setCurrentUserId(newMember.id);
    return newMember;
  }

  // ---------------------------------------------------------------------------
  // Sign In
  // ---------------------------------------------------------------------------

  /// Returns the matching Member on success, or `null` on wrong credentials.
  /// The UI turns `null` into the message "Wrong email or password".
  static Future<Member?> signIn(String email, String password) async {
    final members = await StorageService.getMembers();
    final emailLower = email.trim().toLowerCase();

    for (final m in members) {
      if (!m.hasLogin) continue;
      if (m.email.trim().toLowerCase() == emailLower &&
          m.password == password) {
        await StorageService.setCurrentUserId(m.id);
        return m;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Clears the saved session. The next app start goes to Sign In.
  static Future<void> signOut() async {
    await StorageService.setCurrentUserId(null);
  }

  // ---------------------------------------------------------------------------
  // Current user
  // ---------------------------------------------------------------------------

  /// Returns the currently signed-in Member, or `null` if nobody is signed in.
  /// If the saved id no longer points to an existing Member, the session is
  /// cleared and `null` is returned so the app falls back to Sign In instead
  /// of crashing.
  static Future<Member?> currentUser() async {
    final id = await StorageService.getCurrentUserId();
    if (id == null) return null;

    final members = await StorageService.getMembers();
    for (final m in members) {
      if (m.id == id) return m;
    }

    // Stale session — clean it up.
    await StorageService.setCurrentUserId(null);
    return null;
  }

  // ---------------------------------------------------------------------------
  // Update profile
  // ---------------------------------------------------------------------------

  /// Saves edits to the currently signed-in member.
  ///
  /// Throws:
  ///  * `Exception('Member not found')` if the id does not exist.
  ///  * `Exception('Email already in use')` if another member already uses
  ///    the new email (case-insensitive).
  ///  * `Exception('Could not save your profile. Please try again.')` if the
  ///    underlying StorageService fails to write.
  static Future<void> updateProfile(Member member) async {
    final members = await StorageService.getMembers();
    final idx = members.indexWhere((m) => m.id == member.id);
    if (idx == -1) {
      throw Exception('Member not found');
    }

    final emailLower = member.email.trim().toLowerCase();
    for (var i = 0; i < members.length; i++) {
      if (i != idx && members[i].email.trim().toLowerCase() == emailLower) {
        throw Exception('Email already in use');
      }
    }

    final updated = [...members];
    updated[idx] = member;
    final ok = await StorageService.saveMembers(updated);
    if (!ok) {
      throw Exception('Could not save your profile. Please try again.');
    }
  }
}
