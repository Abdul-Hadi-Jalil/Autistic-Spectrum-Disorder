import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Credentials collected on the signup screen, carried through mode selection
/// and consent where the account is actually created.
class SignupData {
  final String fullName;
  final String email;
  final String password;
  final String mode;

  const SignupData({
    required this.fullName,
    required this.email,
    required this.password,
    this.mode = 'parent',
  });

  SignupData copyWith({String? mode}) => SignupData(
        fullName: fullName,
        email: email,
        password: password,
        mode: mode ?? this.mode,
      );
}

/// Thin wrapper around [FirebaseAuth] (and a Firestore user profile doc)
/// used by the login and signup screens.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String fullName,
    required String email,
    required String password,
    String mode = 'parent',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(fullName.trim());
      await _db.collection('users').doc(user.uid).set({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'mode': mode,
        'plan': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
          'pushNotifications': true,
          'emailAlerts': true,
          'highRiskAlerts': true,
          'screeningReminders': false,
        },
      });
    }
    return credential;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
