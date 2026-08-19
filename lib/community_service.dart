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
  /// 전체 커뮤니티의 게시글 가져오기
  ///
  /// communities/{communityId}/posts
  /// 하위의 모든 posts를 한 번에 조회
  ///
  /// sortBy:
  /// - 'latest' : 최신순
  /// - 'popular': 아멘 개수순
  /// ============================================================
  static Future<List<Map<String, dynamic>>> getAllPosts({
    String sortBy = 'latest',
    String? category,
  }) async {
    Query query = _firestore
        .collectionGroup('posts');

    // ------------------------------------------------------------
    // 카테고리 필터
    // ------------------------------------------------------------
    if (category != null && category.isNotEmpty) {
      query = query.where(
        'category',
        isEqualTo: category,
      );
    }

    // ------------------------------------------------------------
    // 정렬
    // ------------------------------------------------------------
    if (sortBy == 'popular') {
      query = query.orderBy(
        'amenCount',
        descending: true,
      );
    } else {
      query = query.orderBy(
        'createdAt',
        descending: true,
      );
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data =
          doc.data() as Map<String, dynamic>;

      return {
        'postId': doc.id,

        // 어느 커뮤니티의 글인지 알아야
        // 상세 페이지로 이동할 때 사용할 수 있음
        'communityId':
            doc.reference.parent.parent?.id,

        ...data,
      };
    }).toList();
  }

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

  static Future<String> createPost({
    required String title,
    required String content,
    required String category,
    required List<String> imageUrls,
  }) async {
    final uid = UserService.currentUid;

    if (uid == null) {
      throw Exception('로그인한 사용자를 찾을 수 없습니다.');
    }

    final nickname =
        await UserService.getCurrentNickname();

    final postRef =
        _firestore.collection('posts').doc();

    final now = Timestamp.now();

    await postRef.set({
      'title': title.trim(),
      'content': content.trim(),
      'authorUid': uid,
      'authorNickname': nickname,
      'category': category,
      'imageUrls': imageUrls,
      'createdAt': now,
      'updatedAt': now,
    });

    return postRef.id;
  }

  static Future<void> publishPost({
    required String postId,
    required List<String> communityIds,
    required bool publishToPublic,
  }) async {
    final postSnapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .get();

    if (!postSnapshot.exists) {
      throw Exception('게시글을 찾을 수 없습니다.');
    }

    final postData = postSnapshot.data();

    if (postData == null) {
      throw Exception('게시글 데이터를 읽을 수 없습니다.');
    }

    final batch = _firestore.batch();

    for (final communityId in communityIds) {
      final ref = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId);

      batch.set(ref, {
        ...postData,
        'originalPostId': postId,
        'amenCount': 0,
        'isNotice': false,
      });
    }

    if (publishToPublic) {
      final publicRef = _firestore
          .collection('publicPosts')
          .doc(postId);

      batch.set(publicRef, {
        ...postData,
        'originalPostId': postId,
        'amenCount': 0,
      });
    }

    await batch.commit();
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

  /// ============================================================
  /// 이음 기도 게시판 최신 글 3개
  ///
  /// 모든 커뮤니티의 posts를 대상으로
  /// 최신순으로 최대 3개를 가져옵니다.
  /// ============================================================
  static Future<List<Map<String, dynamic>>>
      getLatestPublicPosts() async {
    final snapshot = await _firestore
        .collection('publicPosts')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(3)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'postId': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  /// ============================================================
  /// 이음 기도 게시판 전체 글 가져오기
  ///
  /// publicPosts에 게시된 모든 글을 가져옵니다.
  /// sortBy:
  /// - 'latest' : 최신순
  /// - 'popular': 아멘 개수순
  /// category:
  /// - 특정 카테고리만 조회
  /// - null이면 전체 카테고리
  /// ============================================================
  static Future<List<Map<String, dynamic>>>
      getAllPublicPosts({
    String sortBy = 'latest',
    String? category,
  }) async {
    Query query = _firestore
        .collection('publicPosts');

    // ------------------------------------------------------------
    // 카테고리 필터
    // ------------------------------------------------------------
    if (category != null && category.isNotEmpty) {
      query = query.where(
        'category',
        isEqualTo: category,
      );
    }

    // ------------------------------------------------------------
    // 정렬
    // ------------------------------------------------------------
    if (sortBy == 'popular') {
      query = query.orderBy(
        'amenCount',
        descending: true,
      );
    } else {
      query = query.orderBy(
        'createdAt',
        descending: true,
      );
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data =
          doc.data() as Map<String, dynamic>;

      return {
        'postId': doc.id,
        ...data,
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>>
      getMyJoinedCommunities() async {
    final uid = UserService.currentUid;

    if (uid == null) {
      throw Exception('로그인한 사용자를 찾을 수 없습니다.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('joinedCommunities')
        .orderBy('joinedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'communityId': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

    /// ============================================================
  /// 현재 사용자가 해당 커뮤니티에 가입했는지 확인
  /// ============================================================
  static Future<bool> isMember({
    required String communityId,
  }) async {
    final uid = UserService.currentUid;

    if (uid == null) {
      return false;
    }

    final memberDoc = await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(uid)
        .get();

    return memberDoc.exists;
  }

    /// ============================================================
  /// 커뮤니티 가입
  ///
  /// 처리:
  /// 1. 현재 사용자가 이미 가입했는지 확인
  /// 2. members에 사용자 추가
  /// 3. memberCount +1
  /// 4. users/{uid}/joinedCommunities에 추가
  /// ============================================================
  static Future<void> joinCommunity({
    required String communityId,
  }) async {
    final uid = UserService.currentUid;

    if (uid == null) {
      throw Exception('로그인한 사용자를 찾을 수 없습니다.');
    }

    final communityRef = _firestore
        .collection('communities')
        .doc(communityId);

    final memberRef = communityRef
        .collection('members')
        .doc(uid);

    final joinedCommunityRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('joinedCommunities')
        .doc(communityId);

    await _firestore.runTransaction((transaction) async {
      // ----------------------------------------------------------
      // 현재 커뮤니티 정보
      // ----------------------------------------------------------
      final communitySnapshot =
          await transaction.get(communityRef);

      if (!communitySnapshot.exists) {
        throw Exception('존재하지 않는 커뮤니티입니다.');
      }

      // ----------------------------------------------------------
      // 이미 가입했는지 확인
      // ----------------------------------------------------------
      final memberSnapshot =
          await transaction.get(memberRef);

      if (memberSnapshot.exists) {
        return;
      }

      final communityData =
          communitySnapshot.data() as Map<String, dynamic>;

      final currentMemberCount =
          (communityData['memberCount'] ?? 0) as num;

      final now = Timestamp.now();

      // ----------------------------------------------------------
      // members/{uid} 추가
      // ----------------------------------------------------------
      transaction.set(memberRef, {
        'role': 'member',
        'joinedAt': now,
      });

      // ----------------------------------------------------------
      // memberCount +1
      // ----------------------------------------------------------
      transaction.update(communityRef, {
        'memberCount': currentMemberCount + 1,
        'updatedAt': now,
      });

      // ----------------------------------------------------------
      // users/{uid}/joinedCommunities/{communityId} 추가
      // ----------------------------------------------------------
      transaction.set(joinedCommunityRef, {
        'communityName': communityData['name'] ?? '',
        'coverImageUrl':
            communityData['coverImageUrl'],
        'joinedAt': now,
      });
    });
  }

    /// ============================================================
  /// 커뮤니티 탈퇴
  ///
  /// 처리:
  /// 1. 현재 사용자의 가입 정보 확인
  /// 2. members에서 삭제
  /// 3. memberCount -1
  /// 4. users/{uid}/joinedCommunities에서 삭제
  /// ============================================================
  static Future<void> leaveCommunity({
    required String communityId,
  }) async {
    final uid = UserService.currentUid;

    if (uid == null) {
      throw Exception('로그인한 사용자를 찾을 수 없습니다.');
    }

    final communityRef = _firestore
        .collection('communities')
        .doc(communityId);

    final memberRef = communityRef
        .collection('members')
        .doc(uid);

    final joinedCommunityRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('joinedCommunities')
        .doc(communityId);

    await _firestore.runTransaction((transaction) async {
      final communitySnapshot =
          await transaction.get(communityRef);

      if (!communitySnapshot.exists) {
        throw Exception('존재하지 않는 커뮤니티입니다.');
      }

      final memberSnapshot =
          await transaction.get(memberRef);

      if (!memberSnapshot.exists) {
        return;
      }

      final communityData =
          communitySnapshot.data() as Map<String, dynamic>;

      final currentMemberCount =
          (communityData['memberCount'] ?? 0) as num;

      final now = Timestamp.now();

      // ----------------------------------------------------------
      // members/{uid} 삭제
      // ----------------------------------------------------------
      transaction.delete(memberRef);

      // ----------------------------------------------------------
      // memberCount -1
      // ----------------------------------------------------------
      transaction.update(communityRef, {
        'memberCount':
            currentMemberCount > 0
                ? currentMemberCount - 1
                : 0,
        'updatedAt': now,
      });

      // ----------------------------------------------------------
      // users/{uid}/joinedCommunities/{communityId} 삭제
      // ----------------------------------------------------------
      transaction.delete(joinedCommunityRef);
    });
  }

  /// ============================================================
  /// 커뮤니티 검색
  ///
  /// 커뮤니티 이름을 기준으로 검색
  /// - nameLower를 사용하여 대소문자 구분 없이 검색
  /// - 검색어로 시작하는 커뮤니티를 최대 20개 가져옴
  /// ============================================================
  static Future<List<Map<String, dynamic>>> searchCommunities({
    required String keyword,
  }) async {
    final searchKeyword = keyword.trim().toLowerCase();

    if (searchKeyword.isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection('communities')
        .where(
          'nameLower',
          isGreaterThanOrEqualTo: searchKeyword,
        )
        .where(
          'nameLower',
          isLessThan: '$searchKeyword\uf8ff',
        )
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'communityId': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  /// ============================================================
  /// 추천 커뮤니티 가져오기
  ///
  /// - 전체 communities 중 최대 6개
  /// - randomKey 기준으로 랜덤에 가깝게 선택
  /// ============================================================
  static Future<List<Map<String, dynamic>>>
      getRecommendedCommunities() async {
    final randomValue =
        DateTime.now().microsecondsSinceEpoch % 1000000 / 1000000;

    final snapshot = await _firestore
        .collection('communities')
        .where(
          'randomKey',
          isGreaterThanOrEqualTo: randomValue,
        )
        .orderBy('randomKey')
        .limit(6)
        .get();

    final results = snapshot.docs.map((doc) {
      return {
        'communityId': doc.id,
        ...doc.data(),
      };
    }).toList();

    // randomValue 이후에 6개가 안 나오는 경우
    // 처음부터 다시 가져와 부족한 수를 보충
    if (results.length < 6) {
      final remaining = 6 - results.length;

      final firstSnapshot = await _firestore
          .collection('communities')
          .orderBy('randomKey')
          .limit(remaining)
          .get();

      final existingIds =
          results.map((e) => e['communityId']).toSet();

      for (final doc in firstSnapshot.docs) {
        if (!existingIds.contains(doc.id) &&
            results.length < 6) {
          results.add({
            'communityId': doc.id,
            ...doc.data(),
          });
        }
      }
    }

    return results;
  }
}

