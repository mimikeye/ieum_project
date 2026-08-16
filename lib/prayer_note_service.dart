import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'user_service.dart';

class PrayerNoteService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseStorage _storage =
      FirebaseStorage.instance;

  static Future<String?> savePrayerNote({
    required String title,
    required String content,
    required List<String> categories,
    File? image,
  }) async {
    final username = await UserService.getCurrentUsername();

    if (username == null || username.isEmpty) {
      throw Exception('로그인한 사용자의 username을 찾을 수 없습니다.');
    }

    // -----------------------------------------
    // 1. 기도문 문서 생성
    // -----------------------------------------

    final notesRef = _firestore
        .collection('prayerNotes')
        .doc(username)
        .collection('notes');

    final noteRef = notesRef.doc();

    final noteId = noteRef.id;

    final now = Timestamp.now();

    final date = DateTime.now();

    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    // -----------------------------------------
    // 2. 이미지 Storage 업로드
    // -----------------------------------------

    List<String> imageUrls = [];

    if (image != null) {
      final storageRef = _storage
          .ref()
          .child('prayerImages')
          .child(username)
          .child(noteId)
          .child('image.jpg');

      await storageRef.putFile(image);

      final downloadUrl =
          await storageRef.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    // -----------------------------------------
    // 3. Firestore에 기도문 저장
    // -----------------------------------------

    await noteRef.set({
      'title': title.trim(),
      'content': content.trim(),
      'categories': categories,
      'imageUrls': imageUrls,
      'date': dateString,
      'visibility': 'private',
      'createdAt': now,
      'updatedAt': now,
    });

    return noteId;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>>
      getPrayerNotes({int? limit}) async {
    final username = await UserService.getCurrentUsername();

    if (username == null || username.isEmpty) {
      throw Exception('로그인한 사용자의 username을 찾을 수 없습니다.');
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection('prayerNotes')
        .doc(username)
        .collection('notes')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      getPrayerNotesStream({int? limit}) async* {
    final username = await UserService.getCurrentUsername();

    if (username == null || username.isEmpty) {
      throw Exception('로그인한 사용자의 username을 찾을 수 없습니다.');
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection('prayerNotes')
        .doc(username)
        .collection('notes')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    yield* query.snapshots();
  }
}