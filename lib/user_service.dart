import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// 현재 로그인한 사용자의 Firebase UID 가져오기
  static String? get currentUid {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// 현재 로그인한 사용자의 username 가져오기
  static Future<String?> getCurrentUsername() async {
    final uid = currentUid;

    if (uid == null) {
      return null;
    }

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return data['username'] as String?;
  }

  /// 현재 로그인한 사용자의 nickname 가져오기
  static Future<String?> getCurrentNickname() async {
    final uid = currentUid;

    if (uid == null) {
      return null;
    }

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return data['nickname'] as String?;
  }
}