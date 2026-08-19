import 'package:flutter/material.dart';

import 'community_service.dart';
import 'community_screen.dart';

class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  State<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState
    extends State<CommunitySearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  bool _isSearching = false;

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // 커뮤니티 검색
  // ============================================================

  Future<void> _searchCommunities(String keyword) async {
    final searchKeyword = keyword.trim();

    if (searchKeyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });

      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results =
          await CommunityService.searchCommunities(
        keyword: searchKeyword,
      );

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('커뮤니티 검색에 실패했습니다.'),
        ),
      );
    }
  }

  // ============================================================
  // 커뮤니티 상세 화면 이동
  // ============================================================

  void _openCommunity(
    Map<String, dynamic> community,
  ) {
    final communityId =
        community['communityId'] as String;

    final communityName =
        community['name'] as String? ?? '';

    final description =
        community['description'] as String? ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailScreen(
          communityId: communityId,
          communityName: communityName,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 21.0,
            vertical: 30.0,
          ),

          child: Column(
            children: [

              // ==================================================
              // 검색창
              // ==================================================

              Row(
                children: [

                  // 뒤로가기
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 검색 입력창
                  Expanded(
                    child: SizedBox(
                      height: 40,

                      child: TextField(
                        controller: _searchController,

                        autofocus: true,

                        onSubmitted: _searchCommunities,

                        cursorColor:
                            const Color.fromRGBO(
                          138,
                          136,
                          136,
                          1,
                        ),

                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                        ),

                        decoration: InputDecoration(

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),

                          // 돋보기
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color.fromRGBO(
                              138,
                              136,
                              136,
                              1,
                            ),
                            size: 21,
                          ),

                          // X 버튼
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();

                                        setState(() {
                                          _searchResults = [];
                                        });
                                      },

                                      child: const Icon(
                                        Icons.cancel,
                                        color: Color.fromRGBO(
                                          200,
                                          200,
                                          200,
                                          1,
                                        ),
                                        size: 19,
                                      ),
                                    )
                                  : null,

                          // 기본 테두리
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(25),

                            borderSide:
                                const BorderSide(
                              color: Color.fromRGBO(
                                234,
                                248,
                                203,
                                1,
                              ),
                              width: 1.0,
                            ),
                          ),

                          // 포커스 테두리
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(25),

                            borderSide:
                                const BorderSide(
                              color: Color.fromRGBO(
                                234,
                                248,
                                203,
                                1,
                              ),
                              width: 1.0,
                            ),
                          ),

                          hintText: '커뮤니티 검색',

                          hintStyle:
                              const TextStyle(
                            color: Color.fromRGBO(
                              138,
                              136,
                              136,
                              1,
                            ),
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // 검색 결과
              // ==================================================

              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 검색 결과 UI
  // ============================================================

  Widget _buildSearchResults() {

    // 검색 중
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 검색어가 없는 상태
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Text(
          '찾고 싶은 커뮤니티를 검색해보세요.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    // 검색 결과 없음
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    // 검색 결과 있음
    return ListView.separated(
      itemCount: _searchResults.length,

      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          color: Color(0xFFEEEEEE),
        );
      },

      itemBuilder: (context, index) {

        final community =
            _searchResults[index];

        final name =
            community['name'] as String? ?? '';

        final description =
            community['description']
                as String? ??
            '';

        final imageUrl =
            community['coverImageUrl']
                as String?;

        final memberCount =
            community['memberCount'] ?? 0;

        return GestureDetector(
          onTap: () {
            _openCommunity(community);
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,

              children: [

                // =================================================
                // 커뮤니티 이미지
                // =================================================

                Container(
                  width: 70,
                  height: 70,

                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFD9D9D9,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  clipBehavior:
                      Clip.antiAlias,

                  child:
                      imageUrl != null &&
                              imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  color:
                                      Color(0xFF999999),
                                  size: 28,
                                );
                              },
                            )
                          : const Icon(
                              Icons
                                  .image_not_supported_outlined,
                              color:
                                  Color(0xFF999999),
                              size: 28,
                            ),
                ),

                const SizedBox(width: 14),

                // =================================================
                // 커뮤니티 정보
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        name,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w500,
                          color: Colors.black,
                          fontFamily:
                              'Pretendard',
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        description,

                        maxLines: 2,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              Color(0xFF666666),
                          height: 1.3,
                          fontFamily:
                              'Pretendard',
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '$memberCount명',

                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Color(0xFF999999),
                          fontFamily:
                              'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF999999),
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}