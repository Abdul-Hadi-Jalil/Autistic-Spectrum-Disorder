import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child_profile.dart';
import 'notification_service.dart';

class ChildService {
  ChildService._();
  static final ChildService instance = ChildService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _childrenCol {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('children');
  }

  Stream<List<ChildProfile>> watchChildren() {
    final col = _childrenCol;
    if (col == null) return Stream.value([]);
    return col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(ChildProfile.fromDoc).toList(),
        );
  }

  Future<String> addChild({
    required String name,
    required int ageYears,
    String? gender,
  }) async {
    final col = _childrenCol;
    if (col == null) throw StateError('Not signed in');

    final code = _generateCode();
    final doc = await col.add({
      'name': name,
      'ageYears': ageYears,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await NotificationService.instance.addNotification(
      title: 'New child profile added',
      body: '$name ($code) was added to your records.',
      type: 'profile_added',
    );

    return doc.id;
  }

  String _generateCode() {
    final n = 1000 + Random().nextInt(9000);
    return 'CH-$n';
  }

  Future<void> recordScreening({
    required String childId,
    required String childName,
    required String riskLevel,
    required String summary,
    String screeningType = 'M-CHAT-R Screening',
  }) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final next = now.add(const Duration(days: 90));

      await _db.collection('users').doc(uid).collection('screenings').add({
        'childId': childId,
        'childName': childName,
        'type': screeningType,
        'riskLevel': riskLevel,
        'summary': summary,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _childrenCol?.doc(childId).update({
        'lastScreeningDate': Timestamp.fromDate(now),
        'nextScreeningDate': Timestamp.fromDate(next),
        'lastRiskLevel': riskLevel,
      });

      final notifType = riskLevel == 'high'
          ? 'high_risk'
          : riskLevel == 'moderate'
              ? 'screening_complete'
              : 'low_risk';

      await NotificationService.instance.addNotification(
        title: riskLevel == 'high'
            ? 'High Risk — $childName'
            : 'Screening complete',
        body: riskLevel == 'high'
            ? 'Screening result indicates high risk. Clinical review recommended.'
            : "$childName's $screeningType has been processed.",
        type: notifType,
      );
    } catch (_) {
      // Firestore may be unavailable (API disabled, offline, etc.).
      // Screening results are still shown — cloud sync is best-effort.
    }
  }

  Stream<List<Map<String, dynamic>>> watchRecentScreenings({int limit = 5}) {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              final ts = data['createdAt'];
              return {
                ...data,
                'id': d.id,
                'createdAt': ts is Timestamp ? ts.toDate() : null,
              };
            }).toList());
  }
}
