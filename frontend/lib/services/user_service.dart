import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  Stream<UserProfile?> watchProfile() {
    final doc = _userDoc;
    if (doc == null) return Stream.value(null);
    return doc.snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(snap.data()!);
    });
  }

  Future<UserProfile?> getProfile() async {
    final doc = _userDoc;
    if (doc == null) return null;
    final snap = await doc.get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(snap.data()!);
  }

  Future<void> updateSettings({
    bool? pushNotifications,
    bool? emailAlerts,
    bool? highRiskAlerts,
    bool? screeningReminders,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;
    final updates = <String, dynamic>{};
    if (pushNotifications != null) {
      updates['settings.pushNotifications'] = pushNotifications;
    }
    if (emailAlerts != null) {
      updates['settings.emailAlerts'] = emailAlerts;
    }
    if (highRiskAlerts != null) {
      updates['settings.highRiskAlerts'] = highRiskAlerts;
    }
    if (screeningReminders != null) {
      updates['settings.screeningReminders'] = screeningReminders;
    }
    if (updates.isNotEmpty) await doc.update(updates);
  }

  Future<int> childrenCount() async {
    final uid = _uid;
    if (uid == null) return 0;
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> screeningsCount() async {
    final uid = _uid;
    if (uid == null) return 0;
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .count()
        .get();
    return snap.count ?? 0;
  }
}
