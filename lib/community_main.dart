import 'package:flutter/material.dart';
import 'community_search.dart';
import 'community_public_list.dart';
import 'create_community.dart';
import 'community_post_detail.dart';
import 'community_screen.dart';
import 'community_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() =>
      _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {

  bool _isRecommendedLoading = true;

  List<Map<String, dynamic>> _recommendedCommunities = [];

  bool _isPrayerLoading = true;

  List<Map<String, dynamic>> _latestPublicPosts = [];

  @override
  void initState() {
    super.initState();

    _loadRecommendedCommunities();
    _loadLatestPublicPosts();
  }

  Future<void> _loadRecommendedCommunities() async {
    try {
      final communities =
          await CommunityService.getRecommendedCommunities();

      if (!mounted) return;

      setState(() {
        _recommendedCommunities = communities;
        _isRecommendedLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecommendedLoading = false;
      });
    }
  }

  Future<void> _loadLatestPublicPosts() async {
    try {
      final posts =
          await CommunityService.getLatestPublicPosts();

      if (!mounted) return;

      setState(() {
        _latestPublicPosts = posts;
        _isPrayerLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPrayerLoading = false;
      });

      debugPrint('최신 기도문 불러오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // 1. 상단 검색바 & 추가 버튼
                _buildSearchBar(context),

                // 💡 검색창과 Y축으로 24만큼 떨어짐
                const SizedBox(height: 24),

                // 2. 이음 기도문 섹션
                _buildSectionHeader(context, '이음 기도 게시판', hasMore: true),
                const SizedBox(height: 16),
                _buildPrayerList(),

                const SizedBox(height: 28.09),

                // 3. 추천 커뮤니티 섹션
                _buildSectionHeader(context, '추천 커뮤니티', hasMore: false),
                const SizedBox(height: 16),
                _buildCommunityGrid(),
 // 하단 여유 공간
              ],
            ),
          ), // 👈 Padding 끝
        ),
      ),
    );
  }
  // --- 위젯 빌드 메서드 ---

  Widget _buildSearchBar(BuildContext context) {
    // 💡 매개변수로 context를 받아야 이동 가능합니다!
    return Row(
      children: [
        // 💡 1. 검색창 영역을 GestureDetector로 감싸기
        Expanded(
          child: GestureDetector(
            onTap: () {
              // 💡 클릭 시 CommunitySearchScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunitySearchScreen(),
                ),
              );
            },
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromRGBO(234, 248, 203, 1),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                // 자식들 변경 없음
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '커뮤니티 검색',
                    style: TextStyle(
                      color: Color.fromRGBO(138, 136, 136, 1),
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  Icon(Icons.search, color: Colors.black, size: 21),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 3. + 동그라미 버튼 (크기 고정)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCommunityScreen(),
              ),
            );
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(234, 248, 203, 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(234, 248, 203, 1),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 14,
              height: 14,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 1.7,
                    color: const Color.fromRGBO(34, 34, 34, 1),
                  ),
                  Container(
                    width: 1.7,
                    height: 14,
                    color: const Color.fromRGBO(34, 34, 34, 1),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required bool hasMore}) { 
    return Padding(
      // 화면 전체 기본 패딩이 21이므로, 왼쪽에 1을 더해 정확히 X: 22 위치로 맞춤
      padding: const EdgeInsets.only(left: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- 메인 제목 (이음 기도문 등) ---
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Pretendard',
            ),
          ),
          // --- 더보기 버튼 ---
          if (hasMore)
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrayerDetailScreen(),
                  ),
                );

                if (result == true && mounted) {
                  await _loadLatestPublicPosts();
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 2.0,
                ),
                // 💡 글자와 > 기호를 분리하여 각각 다른 폰트 크기를 적용합니다.
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 가로 공간 차지
                  crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
                  children: [
                    const Text(
                      '더보기',
                      style: TextStyle(
                        fontSize: 15, // 더보기 글자 크기 유지
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(width: 4), // 💡 더보기와 > 사이의 간격
                    Image.asset('assets/images/right_arrow_mini.png',width:10,height:10)
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 이음 기도문 리스트
  // Firebase에서 최신 게시글 최대 3개 표시
  // ============================================================
  Widget _buildPrayerList() {
    // 로딩 중
    if (_isPrayerLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 게시글이 없는 경우
    if (_latestPublicPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          '아직 작성된 기도문이 없습니다.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _latestPublicPosts.length,

          separatorBuilder: (context, index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            color: const Color.fromRGBO(238, 238, 238, 1),
          ),

          itemBuilder: (context, index) {
            final prayer = _latestPublicPosts[index];

            final String postId =
                prayer['postId'] as String? ?? '';

            final String communityId =
                prayer['communityId'] as String? ?? '';

            final String title =
                prayer['title'] as String? ?? '';

            final String content =
                prayer['content'] as String? ?? '';

            final List<String> categories =
                (prayer['categories'] as List<dynamic>? ?? [])
                    .map((category) => category.toString())
                    .where((category) => category.isNotEmpty)
                    .toList();

            // 기존 게시글은 category 하나만 저장되어 있을 수 있으므로
            // categories가 비어 있으면 기존 category 값을 사용
            if (categories.isEmpty) {
              final String oldCategory =
                  (prayer['category'] ?? '').toString();

              if (oldCategory.isNotEmpty) {
                categories.add(oldCategory);
              }
            }

            final String tag =
                categories.isNotEmpty ? categories.first : '';

            final int extraCategoryCount =
                categories.length > 1 ? categories.length - 1 : 0;

            final int amenCount =
                prayer['amenCount'] as int? ?? 0;

            final List<String> imageUrls =
                (prayer['imageUrls'] as List<dynamic>? ?? [])
                    .map((image) => image.toString())
                    .where((image) => image.isNotEmpty)
                    .toList();

            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CommunityPostDetailScreen(
                      communityId: communityId,
                      postId: postId,
                      communityName: '이음 기도문 게시판',
                      title: title,
                      content: content,
                      categories: categories,
                      amenCount: amenCount,
                      imageUrls: imageUrls,
                      isPublicPost: true,
                    ),
                  ),
                );

                if (result == true && mounted) {
                  await _loadLatestPublicPosts();
                }
              },

              child: Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'Pretendard',
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              fontFamily: 'Pretendard',
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                _formatPostDate(
                                  prayer['createdAt'],
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(
                                    113,
                                    113,
                                    113,
                                    1,
                                  ),
                                  fontFamily: 'Pretendard',
                                ),
                              ),

                              if (tag.isNotEmpty) ...[
                              const SizedBox(width: 8),

                              Container(
                                width: 1,
                                height: 11,
                                color: const Color.fromRGBO(
                                  113,
                                  113,
                                  113,
                                  1,
                                ),
                              ),

                              const SizedBox(width: 5),

                              Container(
                                width: 35,
                                height: 17,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromRGBO(
                                      166,
                                      166,
                                      166,
                                      1,
                                    ),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(13.4),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(
                                      166,
                                      166,
                                      166,
                                      1,
                                    ),
                                    fontFamily: 'Pretendard',
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              if (extraCategoryCount > 0) ...[
                                const SizedBox(width: 2),

                                Text(
                                  '+$extraCategoryCount',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(
                                      166,
                                      166,
                                      166,
                                      1,
                                    ),
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                              ],
                            ],

                            const SizedBox(width: 8),

                            Image.asset(
                              'assets/images/amen_list_icon.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              '$amenCount',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF666666),
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (imageUrls.isNotEmpty) ...[
                      const SizedBox(width: 13),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          imageUrls.first,
                          width: 95,
                          height: 95,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),

        // 마지막 구분선
        Container(
          margin: const EdgeInsets.only(top: 16),
          height: 1,
          color: const Color.fromRGBO(238, 238, 238, 1),
        ),
      ],
    );
  }

  String _formatPostDate(dynamic value) {
    if (value == null) {
      return '';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return '';
    }

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '$month.$day';
  }

  // 추천 커뮤니티 그리드
  // 추천 커뮤니티 그리드 (110x110 정사각형 비율 적용)
  Widget _buildCommunityGrid() {
    if (_isRecommendedLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recommendedCommunities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          '추천할 커뮤니티가 없습니다.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: _recommendedCommunities.length,
      itemBuilder: (context, index) {
        final community =
            _recommendedCommunities[index];

        final communityId =
            community['communityId'] as String;

        final communityName =
            community['name'] as String? ?? '';

        final imageUrl =
            community['coverImageUrl'] as String?;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityDetailScreen(
                  communityId: communityId,
                  communityName: communityName,
                  description:
                      community['description'] as String? ?? '',
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // 전체 카드에 사진이 깔림
                Positioned.fill(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade400,
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade400,
                        ),
                ),

                // 아래쪽 반투명 영역
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 49,
                  child: Container(
                    color: Colors.white.withOpacity(0.72),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    child: Text(
                      communityName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.2,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
