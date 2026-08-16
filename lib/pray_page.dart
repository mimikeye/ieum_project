import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pray_time.dart';
import 'pray_write_page.dart';
import 'prayer_note_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'prayer_note_list.dart';

class PrayerScreen extends StatelessWidget {
  PrayerScreen({super.key});

  final Color _primaryLightGreen = const Color.fromRGBO(234, 248, 203, 1);
  final Color _primaryDarkGreen = const Color.fromRGBO(72, 95, 63, 1);
  final Color _tagTextColor = const Color.fromRGBO(166, 166, 166, 1);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '기도',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: Colors.black,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '3',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard',
                            color: _primaryDarkGreen,
                          ),
                        ),
                        const TextSpan(
                          text: '일 연속 기도중',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Pretendard',
                            color: Color.fromRGBO(72, 95, 63, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 서브 타이틀
              const Text(
                '오늘의 이음기도를 시작해보세요',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // 2. 메인 기도 시작 카드
              Container(
                width: double.infinity,
                height: 191,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/pray_start_back.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 8),
                          Text(
                            '지금, 하나님께\n마음을 온전히 드려보세요',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '기도 시간은 하나님과\n함께한 소중한 순간이 됩니다.',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Pretendard',
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 32),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              final user = FirebaseAuth.instance.currentUser;

                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('로그인 정보가 없습니다.'),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrayerTimerPage(
                                    uid: user.uid,
                                  ),
                                ),
                              );
                            },
                            child: Ink.image(
                              image: const AssetImage(
                                'assets/images/pray_start.png',
                              ),
                              width: 103,
                              height: 103,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Material(
                color: const Color.fromRGBO(249, 251, 241, 1),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrayerWriteScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 67,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primaryLightGreen, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '새로운 기도문을 작성해보세요',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            Text(
                              '마음에 담긴 기도를 글로 기록해보세요.',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Pretendard',
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Image.asset('assets/images/right_arrow.png', width: 9, height: 15),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 4. 나의 이음 기도문 리스트 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '나의 이음 기도문',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrayerNotesPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        children: const [
                          Text(
                            '더보기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 5. 기도문 리스트 
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: PrayerNoteService.getPrayerNotesStream(limit: 3),
                builder: (context, snapshot) {
                  // 로딩 중
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // 오류
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        '기도문을 불러오지 못했습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  final notes = snapshot.data?.docs ?? [];

                  // 기도문이 하나도 없을 때
                  if (notes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          '작성한 기도문이 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }

                  // 실제 기도문 표시
                  return Column(
                    children: [
                      for (int i = 0; i < notes.length; i++) ...[
                        _buildPrayerListItemFromFirebase(
                          notes[i],
                        ),

                        if (i != notes.length - 1)
                          const Divider(
                            height: 24,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerListItemFromFirebase(
    QueryDocumentSnapshot<Map<String, dynamic>> note,
  ) {
    final data = note.data();

    final String title =
        (data['title'] ?? '').toString();

    final String content =
        (data['content'] ?? '').toString();

    final String date =
        (data['date'] ?? '').toString();

    final List<String> categories =
        List<String>.from(data['categories'] ?? []);

    final List<String> imageUrls =
        List<String>.from(data['imageUrls'] ?? []);

    String displayDate = date;

    // yyyy-MM-dd → MM.dd
    if (date.length >= 10) {
      displayDate =
          '${date.substring(5, 7)}.${date.substring(8, 10)}';
    }

    final String tag =
        categories.isNotEmpty ? categories.first : '';

    final String? imageUrl =
        imageUrls.isNotEmpty ? imageUrls.first : null;

    return _buildPrayerListItem(
      title: title,
      content: content,
      date: displayDate,
      tag: tag,
      imageUrl: imageUrl,
      onTap: () {
        // 나중에 상세 페이지 연결
      },
    );
  }

  Widget _buildPrayerListItem({
    required String title,
    required String content,
    required String date,
    required String tag,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Pretendard',
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 0.5,
                            height: 11,
                            color: const Color.fromRGBO(113, 113, 113, 100),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromRGBO(166, 166, 166, 1),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: _tagTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 95,
                    height: 95,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 95,
                          height: 95,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}