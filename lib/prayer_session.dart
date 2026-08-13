import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 기도 기록 저장
  Future<void> savePrayerSession({
    required String uid,
    required DateTime startedAt,
    required int durationSeconds,
  }) async {
    final String date =
        '${startedAt.year.toString().padLeft(4, '0')}-'
        '${startedAt.month.toString().padLeft(2, '0')}-'
        '${startedAt.day.toString().padLeft(2, '0')}';

    final String documentId =
        '${uid}_${startedAt.millisecondsSinceEpoch}';

    await _firestore
        .collection('prayerSessions')
        .doc(documentId)
        .set({
      'uid': uid,
      'date': date,
      'startedAt': Timestamp.fromDate(startedAt),
      'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 특정 날짜의 기도 기록 가져오기
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getPrayerSessions({
    required String uid,
    required String date,
  }) async {
    final snapshot = await _firestore
        .collection('prayerSessions')
        .where('uid', isEqualTo: uid)
        .where('date', isEqualTo: date)
        .orderBy('startedAt', descending: true)
        .get();

    return snapshot.docs;
  }

  /// 특정 날짜의 총 기도 시간
  Future<int> getTotalPrayerSeconds({
    required String uid,
    required String date,
  }) async {
    final sessions = await getPrayerSessions(
      uid: uid,
      date: date,
    );

    int totalSeconds = 0;

    for (final session in sessions) {
      totalSeconds +=
          (session.data()['durationSeconds'] ?? 0) as int;
    }

    return totalSeconds;
  }
}