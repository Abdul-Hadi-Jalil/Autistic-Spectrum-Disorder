import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('notifications');
  }

  Stream<List<AppNotification>> watchNotifications() {
    final col = _col;
    if (col == null) return Stream.value([]);
    return col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(AppNotification.fromDoc).toList(),
        );
  }

  Stream<int> watchUnreadCount() {
    final col = _col;
    if (col == null) return Stream.value(0);
    return col.where('read', isEqualTo: false).snapshots().map((s) => s.size);
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    final col = _col;
    if (col == null) return;
    await col.add({
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllRead() async {
    final col = _col;
    if (col == null) return;
    final batch = _db.batch();
    final unread = await col.where('read', isEqualTo: false).get();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  static String formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      if (diff.inHours < 1) return '${diff.inMinutes.clamp(1, 59)} minutes ago';
      return '${diff.inHours} hours ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return _formatDate(date);
  }

  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifDay = DateTime(date.year, date.month, date.day);
    if (notifDay == today) return 'Today';
    if (notifDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return _formatDate(date);
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static (Color, Color) colorsForType(String type) {
    switch (type) {
      case 'high_risk':
        return (const Color(0xFFD64545), const Color(0xFFFBE0E0));
      case 'low_risk':
        return (const Color(0xFF2E7D5B), const Color(0xFFDDF0E6));
      case 'screening_due':
        return (const Color(0xFF2A3F9D), const Color(0xFFFBF0CF));
      case 'profile_added':
        return (const Color(0xFFE2E8F0), const Color(0xFFE7EEFB));
      default:
        return (const Color(0xFF2A3F9D), const Color(0xFFE7EEFB));
    }
  }
}
