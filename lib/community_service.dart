import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'user_service.dart';

class CommunityService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseStorage _storage =
      FirebaseStorage.instance;

  /// ============================================================
  /// 커뮤니티 생성
  ///
  /// 처리 순서:
  /// 1. 현재 로그인 사용자 확인
  /// 2. communities 문서 ID 생성
  /// 3. 대표 이미지가 있으면 Storage 업로드
  /// 4. communities/{communityId} 저장
  /// 5. 만든 사람을 owner로 등록
  /// 6. users/{uid}/joinedCommunities에 저장
  /// 7. 환영 공지 자동 생성
  ///
  /// 반환값:
  /// 생성된 communityId
  /// ============================================================
  static Future<String> createCommunity({
    required String name,
    required String description,
    File? coverImage,
  }) async {
    final uid = UserService.currentUid;

    if (uid == null) {
      throw Exception('로그인한 사용자를 찾을 수 없습니다.');
    }

    final nickname = await UserService.getCurrentNickname();

    // ------------------------------------------------------------
    // 1. 커뮤니티 문서 ID 생성
    // ------------------------------------------------------------
    final communityRef =
        _firestore.collection('communities').doc();

    final communityId = communityRef.id;

    // ------------------------------------------------------------
    // 2. 랜덤 추천용 값
    // ------------------------------------------------------------
    final randomKey =
        DateTime.now().microsecondsSinceEpoch % 1000000 / 1000000;

    // ------------------------------------------------------------
    // 3. 대표 이미지 업로드
    // ------------------------------------------------------------
    String? coverImageUrl;

    if (coverImage != null) {
      final storageRef = _storage
          .ref()
          .child('communities')
          .child(communityId)
          .child('cover')
          .child('cover.jpg');

      await storageRef.putFile(coverImage);

      coverImageUrl =
          await storageRef.getDownloadURL();
    }

    final now = Timestamp.now();

    // ------------------------------------------------------------
    // 4. communities/{communityId} 생성
    // ------------------------------------------------------------
    await communityRef.set({
      'name': name.trim(),
      'nameLower': name.trim().toLowerCase(),
      'description': description.trim(),
      'coverImageUrl': coverImageUrl,
      'ownerUid': uid,
      'memberCount': 1,
      'randomKey': randomKey,
      'createdAt': now,
      'updatedAt': now,
    });

    // ------------------------------------------------------------
    // 5. 만든 사람을 owner로 자동 가입
    // communities/{communityId}/members/{uid}
    // ------------------------------------------------------------
    await communityRef
        .collection('members')
        .doc(uid)
        .set({
      'role': 'owner',
      'joinedAt': now,
    });

    // ------------------------------------------------------------
    // 6. 사용자 쪽에도 가입 커뮤니티 저장
    // users/{uid}/joinedCommunities/{communityId}
    // ------------------------------------------------------------
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('joinedCommunities')
        .doc(communityId)
        .set({
      'communityName': name.trim(),
      'coverImageUrl': coverImageUrl,
      'joinedAt': now,
    });

    // ------------------------------------------------------------
    // 7. 환영 공지 자동 생성
    //
    // communities/{communityId}/posts/{postId}
    // ------------------------------------------------------------
    final noticeRef =
        communityRef.collection('posts').doc();

    await noticeRef.set({
      'title': '환영합니다!',
      'content': '새로운 커뮤니티가 개설되었습니다.',
      'authorUid': uid,
      'authorNickname': nickname,
      'category': '공지',
      'imageUrls': <String>[],
      'amenCount': 0,
      'isNotice': true,
      'createdAt': now,
      'updatedAt': now,
    });

    return communityId;
  }

  /// ============================================================
  /// 커뮤니티 1개 가져오기
  /// ============================================================
  static Future<Map<String, dynamic>?> getCommunity({
    required String communityId,
  }) async {
    final doc = await _firestore
        .collection('communities')
        .doc(communityId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return {
      'communityId': doc.id,
      ...data,
    };
  }

  /// ============================================================
  /// 커뮤니티 공지 가져오기
  ///
  /// 가장 최근 공지 1개를 가져옴
  /// ============================================================
  static Future<Map<String, dynamic>?> getLatestNotice({
    required String communityId,
  }) async {
    final snapshot = await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .where('isNotice', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;

    return {
      'postId': doc.id,
      ...doc.data(),
    };
  }

  /// ============================================================
  /// 커뮤니티 최신 기도문 가져오기
  ///
  /// 공지는 제외하고 최신 게시글 최대 3개
  /// ============================================================
  static Future<List<Map<String, dynamic>>> getLatestPosts({
    required String communityId,
  }) async {
    final snapshot = await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .where('isNotice', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'postId': doc.id,
        ...doc.data(),
      };
    }).toList();
  }
}