import 'package:flutter/material.dart';
import 'category_selection.dart';
import 'community_service.dart';
import 'community_post_detail.dart';

class PrayerDetailScreen extends StatefulWidget {
  const PrayerDetailScreen({super.key});

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState
    extends State<PrayerDetailScreen>
    with SingleTickerProviderStateMixin {
  // 💡 디폴트 상태: 아무것도 선택되지 않은 상태("")로 시작합니다.
  List<String> selectedTags = [];
  String _currentSort = 'popular';

  late TabController _tabController;

  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }

      setState(() {
        _currentSort =
            _tabController.index == 0
                ? 'popular'
                : 'latest';
      });

      _loadPosts();
    });

    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await CommunityService.getAllPublicPosts(
        sortBy: _currentSort,
        categories: selectedTags,
      );

      if (!mounted) return;

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('이음 기도 게시판 불러오기 오류: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게시글을 불러오지 못했습니다.'),
        ),
      );
    }
  }

  final List<String> tags = ["묵상", "감사", "회개", "중보", "간구", "개인"];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭 개수 (인기순, 최신순)
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // 플러터 기본 뒤로가기 버튼 영역 비활성화
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0, 

          title: Padding(
            padding: const EdgeInsets.only(
              left: 20,
            ), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                // --- 뒤로 가기 버튼 (<) ---
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: 20,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // --- 이음 기도문 텍스트 ---
                const Text(
                  "이음 기도문",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w500, 
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                    height: 1.1, 
                  ),
                ),
              ],
            ),
          ),

          // 하단 탭 바 (인기순 / 최신순)
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0), // 기본 탭 바 높이
            child: Padding(
              // 뒤로 가기 버튼(X: 21.8)과 거의 동일하게 좌우 여백을 설정합니다.
              padding: const EdgeInsets.symmetric(horizontal: 21.8),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab, // 인디케이터 바가 탭 영역 끝까지 차도록 설정
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelPadding: EdgeInsets.zero, // 탭 내부 기본 패딩 제거하여 깔끔하게 양분
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),
                tabs: [
                  Tab(text: "인기순"),
                  Tab(text: "최신순"),
                ],
              ),
            ),
          ),
        ), 
        body: TabBarView(
          controller: _tabController,
          children: [
            // 💡 1. 인기순 탭의 화면
            _buildPrayerListTab(),
            // 💡 2. 최신순 탭의 화면 (인기순과 동일하게 적용)
            _buildPrayerListTab(),
          ],
        ),
      ),
    );
  }

  // 인기순/최신순 탭 내부 빌드
Widget _buildPrayerListTab() {

    return Column(
      children: [
        // 상단 가로 카테고리 영역 (기존 코드 유지)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...tags.map((tag) => _buildTagChip(tag)).toList(),
                
                // --- 드롭다운 아이콘 (가장 우측) ---
                GestureDetector(
                  onTap: () async {
                    final List<String>? result = await showCategorySelectionSheet(
                      context: context,
                      initialSelectedCategories: selectedTags, 
                    );

                    if (result != null) {
                      setState(() {
                        selectedTags = List<String>.from(result);
                        _isLoading = true;
                      });

                      await _loadPosts();
                    }
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromRGBO(166, 166, 166, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right:10,bottom:10),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: Color.fromRGBO(166, 166, 166, 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 하단 기도문 리스트 및 구분선 (좌우 여백 21.8 정렬)
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _posts.isEmpty
                  ? const Center(
                      child: Text(
                        '아직 작성된 기도문이 없습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        8,
                        0,
                        16,
                      ),
                      itemCount: _posts.length,
                      separatorBuilder: (context, index) =>
                          Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 21.8,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          height: 1,
                          color: const Color.fromRGBO(
                            238,
                            238,
                            238,
                            1,
                          ),
                        ),
                      ),
                      itemBuilder: (context, index) {
                        return _buildDetailPrayerCard(
                          _posts[index],
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // 💡 카테고리 태그 칩 빌드 (토글 기능 포함)
  Widget _buildTagChip(String title) {
    bool isSelected = selectedTags.contains(title);
    
    return GestureDetector(
      onTap: () async {
        setState(() {
          if (selectedTags.contains(title)) {
            selectedTags.remove(title);
          } else {
            selectedTags.add(title);
          }

          _isLoading = true;
        });

        await _loadPosts();
      },
      child: Container(
        width: 48,
        height: 24,
        alignment: Alignment.center, 
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color.fromRGBO(166, 166, 166, 1) 
              : Colors.white,
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : const Color.fromRGBO(166, 166, 166, 1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20), 
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : const Color.fromRGBO(166, 166, 166, 1),
            fontSize: 14, 
            fontWeight: FontWeight.w400,
            fontFamily: 'Pretendard',
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPrayerCard(
    Map<String, dynamic> prayer,
  ) {

    final String title =
    prayer['title'] as String? ?? '';

    final String content =
        prayer['content'] as String? ?? '';

    final int amenCount =
        prayer['amenCount'] as int? ?? 0;

    final List<String> categories =
        (prayer['categories'] as List<dynamic>? ?? [])
            .map((category) => category.toString())
            .where((category) => category.isNotEmpty)
            .toList();

    if (categories.isEmpty) {
      final String oldCategory =
          (prayer['category'] ?? '').toString();

      if (oldCategory.isNotEmpty) {
        categories.add(oldCategory);
      }
    }

    final List<String> imageUrls =
    (prayer['imageUrls'] as List<dynamic>? ?? [])
        .map((image) => image.toString())
        .where((image) => image.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () async {
        final communityId =
            prayer['communityId'] as String? ?? '';

        final postId =
            prayer['postId'] as String? ?? '';

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CommunityPostDetailScreen(
              communityId: '',
              postId: postId,
              communityName: '이음 기도 게시판',
              title: title,
              content: content,
              categories: categories,
              amenCount: amenCount,
              imageUrls: imageUrls,
              isPublicPost: true,
            ),
          ),
        );

        if (mounted) {
          await _loadPosts();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 21.8,
        ),
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
                    prayer['title'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    prayer['content'] as String? ?? '',
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
                    children: [
                      const Text(
                        '최근',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF717171),
                          fontFamily: 'Pretendard',
                        ),
                      ),

                      if (categories.isNotEmpty) ...[
                        const SizedBox(width: 8),

                        Container(
                          width: 1,
                          height: 11,
                          color: const Color(0xFF717171),
                        ),

                        const SizedBox(width: 5),

                        Container(
                          width: 35,
                          height: 17,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFA6A6A6),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(13.4),
                          ),
                          child: Text(
                            categories.first,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA6A6A6),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),

                        if (categories.length > 1) ...[
                          const SizedBox(width: 2),

                          Text(
                            '+${categories.length - 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFA6A6A6),
                              fontFamily: 'Pretendard',
                            ),
                          ),
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
                      const SizedBox(width: 8),

                      Image.asset(
                        'assets/images/amen_list_icon.png',
                        width: 22,
                        height: 22,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        amenCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
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
  }
}