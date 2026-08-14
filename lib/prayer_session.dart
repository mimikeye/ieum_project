import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 날짜를 yyyy-MM-dd 형식으로 변환
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 기도 기록 저장
  ///
  /// 저장되는 데이터
  /// 1. prayerSessions/{uid}/sessions/{sessionId}
  /// 2. dailyActivities/{uid}/dates/{yyyy-MM-dd}
  Future<void> savePrayerSession({
    required String uid,
    required String username,
    required DateTime startedAt,
    required int durationSeconds,
  }) async {
    final String date = _formatDate(startedAt);

    // 새로운 기도 세션의 문서 ID
    final sessionRef = _firestore
        .collection('prayerSessions')
        .doc(username)
        .collection('sessions')
        .doc();

    // 해당 날짜의 활동 문서
    final activityRef = _firestore
        .collection('dailyActivities')
        .doc(username)
        .collection('dates')
        .doc(date);

    // 현재 해당 날짜의 활동 데이터 가져오기
    final activitySnapshot = await activityRef.get();

    int previousPrayerTime = 0;

    if (activitySnapshot.exists) {
      final data = activitySnapshot.data();

      if (data != null) {
        previousPrayerTime =
            (data['prayerTime'] ?? 0) as int;
      }
    }

    // 기존 기도시간 + 이번 기도시간
    final newTotalPrayerTime =
        previousPrayerTime + durationSeconds;

    // 두 데이터를 한 번에 저장
    final batch = _firestore.batch();

    // -----------------------------------------
    // 1. 실제 기도 세션 저장
    // -----------------------------------------
    batch.set(sessionRef, {
      'date': date,
      'startedAt': Timestamp.fromDate(startedAt),
      'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // -----------------------------------------
    // 2. 하루 활동 정보 업데이트
    // -----------------------------------------
    batch.set(
      activityRef,
      {
        'prayed': true,
        'prayerTime': newTotalPrayerTime,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// 특정 날짜의 기도 기록 가져오기
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getPrayerSessions({
    required String username,
    required String date,
  }) async {
    final snapshot = await _firestore
        .collection('prayerSessions')
        .doc(username)
        .collection('sessions')
        .where('date', isEqualTo: date)
        .orderBy('startedAt', descending: true)
        .get();

    return snapshot.docs;
  }

  /// 특정 날짜의 총 기도 시간
  Future<int> getTotalPrayerSeconds({
    required String username,
    required String date,
  }) async {
    final sessions = await getPrayerSessions(
      username: username,
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