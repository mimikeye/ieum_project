//커뮤니티 하나 홈

import 'package:flutter/material.dart';
import 'package:ieum_project/community_latestpray.dart';
import 'dart:io';

import 'package:ieum_project/community_notice.dart';
import 'package:ieum_project/community_service.dart';

class CommunityDetailScreen extends StatefulWidget {
  final File? coverImage;
  final String communityName;
  final String description;
  final String communityId;

  const CommunityDetailScreen({
    super.key,
    this.coverImage,
    required this.communityName,
    required this.description,
    required this.communityId,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  // 💡 설명글이 펼쳐졌는지(더보기 상태인지) 확인하는 변수
  bool _isDescriptionExpanded = false;

  bool _isLoading = true;

  Map<String, dynamic>? _communityData;
  Map<String, dynamic>? _noticeData;
  List<Map<String, dynamic>> _latestPosts = [];

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  Future<void> _loadCommunityData() async {
    try {
      final community =
          await CommunityService.getCommunity(
        communityId: widget.communityId,
      );

      final notice =
          await CommunityService.getLatestNotice(
        communityId: widget.communityId,
      );

      final latestPosts =
          await CommunityService.getLatestPosts(
        communityId: widget.communityId,
      );

      if (!mounted) return;

      setState(() {
        _communityData = community;
        _noticeData = notice;
        _latestPosts = latestPosts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('커뮤니티 정보를 불러오지 못했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final description =
      (_communityData?['description'] as String?)?.isNotEmpty == true
          ? _communityData!['description']
          : widget.description;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. 상단 이미지 영역 ---
            Stack(
              children: [
                // 💡 이미지 높이를 180으로 유지
                Container(
                  width: double.infinity,
                  height: 210,
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  child: widget.coverImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(widget.coverImage!, fit: BoxFit.cover),
                            Container(color: Colors.white.withOpacity(0.4)),
                          ],
                        )
                      : null,
                ),
                // 안전 영역 내 뒤로가기/설정 버튼
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ), // 💡 핵심: 여기서 Stack을 닫아서 사진 영역을 끝냅니다!
            // --- 2. 커뮤니티 제목 및 인원수 영역 (사진 밖, 흰색 배경) ---
            Padding(
              // 💡 사진 영역 바로 아래에 여백을 주고 텍스트 배치
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                            (_communityData?['name'] as String?)?.isNotEmpty == true
                                ? _communityData!['name']
                                : widget.communityName,
                      style: const TextStyle(
                        fontSize: 25, // 제목 폰트 크기 살짝 키움
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Petendard',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_communityData?['memberCount'] ?? 0}명',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),

            

            // --- 3. 커뮤니티 소개글 영역 (흰색 배경) ---
            Padding(
              // 💡 위쪽 여백(top)을 0으로 주어 제목과 자연스럽게 붙게 함
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      description.isNotEmpty ? description : '소개글이 없습니다.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(64, 64, 64, 1),
                        height: 1.5,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(224, 224, 224, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isDescriptionExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            _buildSectionHeader(
              '공지',
              onMoreTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoticeListScreen(),
                  ),
                );
              },
            ),
            if (_noticeData != null)
              _buildListItem(
                title: _noticeData!['title'] ?? '',
                content: _noticeData!['content'] ?? '',
                date: '공지',
                tag: '공지',
              ),

            Center(
              child: Container(
                height: 0.5,
                width: 340,
                color: const Color.fromRGBO(219, 219, 219, 1),
              ),
            ),

            _buildSectionHeader(
              '최신순',
              onMoreTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LatestListScreen(),
                  ),
                );
              },
            ),
            if (_latestPosts.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(31, 16, 20, 16),
                child: Text(
                  '아직 작성된 기도문이 없습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Pretendard',
                  ),
                ),
              )
            else
              ..._latestPosts.map(
                (post) => _buildListItem(
                  title: post['title'] ?? '',
                  content: post['content'] ?? '',
                  date: '최근',
                  tag: post['category'] ?? '기도',
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 💡 수정됨: onMoreTap 속성을 추가하여 터치 이벤트를 받을 수 있게 함
  Widget _buildSectionHeader(String title, {VoidCallback? onMoreTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Pretendard',
            ),
          ),
          // 💡 더보기 글자를 GestureDetector로 감싸서 터치 가능하게 만듦
          GestureDetector(
            onTap: onMoreTap, // 👈 클릭 시 넘겨받은 함수 실행
            child: const Text(
              '더보기 >',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 2. 리스트 아이템 (리스트만 오른쪽으로 밀어내기)
  Widget _buildListItem({
    required String title,
    required String content,
    required String date,
    required String tag,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 31, right: 20, top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Pretendard',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  '|',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
