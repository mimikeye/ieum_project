import 'package:flutter/material.dart';
import 'community_search.dart';
import 'community_public_list.dart';
import 'create_community.dart';
import 'community_post_detail.dart';
import 'community_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

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

                const SizedBox(height: 30),

                // Firebase 커뮤니티 테스트용 임시 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CommunityDetailScreen(
                            communityId: '8URUbE1LFEmlZK8GN5Hk',
                            communityName: 'asdf',
                            description: 'asdfasdfasdfasdfasdfasdfasfasdfasdfasdfasdf',
                          ),
                        ),
                      );
                    },
                    child: const Text('Firebase 테스트 커뮤니티 열기'),
                  ),
                ),

                const SizedBox(height: 40), // 하단 여유 공간
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
              onTap: () {
                // 💡 더보기 버튼 클릭 시 상세 화면으로 이동하도록 수정!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // PrayerDetailScreen은 새로 만들 파일의 클래스 이름입니다.
                    builder: (context) => const PrayerDetailScreen(), 
                  ),
                );
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

  // 이음 기도문 리스트 (마지막 구분선 추가 완벽 반영)
  Widget _buildPrayerList() {
    final List<Map<String, String>> prayers = [
      {
        'title': '가족을 위한 기도',
        'content': '사랑이 많으신 하나님 아버지,\n오늘도 저희 가족을 지켜주시고...',
        'date': '08.04',
        'tag': '가족',
      },
      {
        'title': '회개 기도',
        'content': '죄인인 저를 사랑한다 말하시는 하나님 아버지, 저의 죄를 고백합니다. 오늘...',
        'date': '08.04',
        'tag': '회개',
      },
      {
        'title': '교회를 위한 기도',
        'content': '하나님 아버지, 주님이 세우신 교회를 위해 기도합니다. 주님, 주님의 인도...',
        'date': '08.04',
        'tag': '교회',
      },
    ];

    // 💡 1. 전체를 Column으로 감싸줍니다.
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prayers.length,
          separatorBuilder: (context, index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            color: const Color.fromRGBO(238, 238, 238, 1),
          ),
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityPostDetailScreen(
                      communityName: '이음 기도문 게시판',
                      title: prayer['title']!,
                      content: prayer['content']!,
                      tag: prayer['tag']!,
                      amenCount: 52,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          prayer['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          prayer['content']!,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              prayer['date']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(113, 113, 113, 1),
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 11,
                              color: const Color.fromRGBO(113, 113, 113, 1),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 35,
                              height: 17,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromRGBO(166, 166, 166, 1),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(13.4),
                              ),
                              child: Text(
                                prayer['tag']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(166, 166, 166, 1),
                                  fontFamily: 'Pretendard',
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 13),
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        ),

        // 💡 2. 마지막 리스트 밑에 들어가는 구분선을 수동으로 하나 더 추가합니다!
        Container(
          // 기존 symmetric(vertical: 16)에서 top: 16으로 변경하여 아래쪽 숨은 여백을 없앱니다!
          margin: const EdgeInsets.only(top: 16),
          height: 1,
          color: const Color.fromRGBO(238, 238, 238, 1),
        ),
      ],
    );
  }

  // 추천 커뮤니티 그리드
  // 추천 커뮤니티 그리드 (110x110 정사각형 비율 적용)
  Widget _buildCommunityGrid() {
    final List<Map<String, String>> communities = [
      {'title': '마마기도클럽'},
      {'title': '북한 중보기도\n커뮤니티'},
      {'title': '동행'},
      {'title': '청년부 모임'},
      {'title': '새벽 기도회'},
      {'title': '중보 기도방'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 한 줄에 3개 배치
        crossAxisSpacing: 9, // 💡 가로 간격 (일반적인 스마트폰 너비에서 아이템 가로가 110이 되도록 간격 조절)
        mainAxisSpacing: 16, // 세로 줄 간격
        childAspectRatio: 1.0, // 💡 1:1 비율을 적용하여 완벽한 110x110 정사각형 모양 유지!
      ),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10,
            ), // (모서리 반경: 피그마 수치가 있다면 알려주세요!)
            // (외곽선: 피그마 수치가 있다면 알려주세요!)
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 상단 이미지 영역
              Expanded(
                flex: 5, // 이미지와 텍스트 박스의 세로 비율 (수치가 있다면 조절 가능)
                child: Container(
                  color: Colors.grey.shade400,
                  width: double.infinity,
                  // 실제 이미지 연결 시 아래 코드 사용
                  // child: Image.network('URL', fit: BoxFit.cover),
                ),
              ),
              // 하단 텍스트 영역
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  child: Text(
                    communities[index]['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      height: 1.2,
                      fontWeight: .w400,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
