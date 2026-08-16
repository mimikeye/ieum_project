import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class PrayerNoteService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<String?> savePrayerNote({
    required String title,
    required String content,
    required List<String> categories,
  }) async {
    final username = await UserService.getCurrentUsername();

    if (username == null || username.isEmpty) {
      throw Exception('로그인한 사용자의 username을 찾을 수 없습니다.');
    }

    final notesRef = _firestore
        .collection('prayerNotes')
        .doc(username)
        .collection('notes');

    final noteRef = notesRef.doc();

    final now = Timestamp.now();

    final date = DateTime.now();

    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await noteRef.set({
      'title': title.trim(),
      'content': content.trim(),
      'categories': categories,
      'imageUrls': [],
      'date': dateString,
      'visibility': 'private',
      'createdAt': now,
      'updatedAt': now,
    });

    return noteRef.id;
  }
}