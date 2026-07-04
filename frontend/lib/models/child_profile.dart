import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  final String id;
  final String name;
  final int ageYears;
  final String? gender;
  final String code;
  final DateTime? lastScreeningDate;
  final DateTime? nextScreeningDate;
  final String? lastRiskLevel;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.ageYears,
    this.gender,
    required this.code,
    this.lastScreeningDate,
    this.nextScreeningDate,
    this.lastRiskLevel,
  });

  String get ageLabel => '$ageYears years old';

  factory ChildProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChildProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      ageYears: data['ageYears'] as int? ?? 0,
      gender: data['gender'] as String?,
      code: data['code'] as String? ?? '',
      lastScreeningDate: (data['lastScreeningDate'] as Timestamp?)?.toDate(),
      nextScreeningDate: (data['nextScreeningDate'] as Timestamp?)?.toDate(),
      lastRiskLevel: data['lastRiskLevel'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'ageYears': ageYears,
        if (gender != null) 'gender': gender,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
