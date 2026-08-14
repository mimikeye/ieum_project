import 'package:flutter/material.dart';

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
                            onTap: () {},
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
                  onTap: () {},
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '새로운 기도문을 작성해보세요',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
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
                    onTap: () {},
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
              _buildPrayerListItem(
                title: '가족을 위한 기도',
                content: '사랑이 많으신 하나님 아버지,\n오늘도 저희 가족을 지켜주시고...',
                date: '08.04',
                tag: '가족',
                imagePlaceholderColor: Colors.brown.shade200,
                onTap: () {},
              ),
              const Divider(
                height: 24,
                thickness: 1,
                color: Color(0xFFEEEEEE),
              ),
              _buildPrayerListItem(
                title: '회개 기도',
                content: '죄인인 저를 사랑한다 말하시는 하나님 아버지, 저의 죄를 고백합니다. 오늘...',
                date: '08.04',
                tag: '회개',
                imagePlaceholderColor: Colors.black87,
                onTap: () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerListItem({
    required String title,
    required String content,
    required String date,
    required String tag,
    required Color imagePlaceholderColor,
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
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 95,
                  height: 95,
                  color: imagePlaceholderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}