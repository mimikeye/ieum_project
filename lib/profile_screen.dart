import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 메인 연두색
  static const Color _primaryGreen =
      Color.fromRGBO(72, 95, 63, 1);

  // 기본 구분선 색상
  static const Color _dividerColor =
      Color.fromRGBO(219, 219, 219, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // 1. 프로필 영역
            // =========================================================
            const SizedBox(height: 55),

            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(234, 248, 203, 1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/splash_app_logo.png',
                  width: 75,
                  height: 37,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '@soseGi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.black,
                fontFamily: 'Pretendard',
              ),
            ),

            // 프로필 아래 구분선
            const SizedBox(height: 38),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Divider(
                color: _dividerColor,
                thickness: 1,
                height: 1,
              ),
            ),

            const SizedBox(height: 28),

            // =========================================================
            // 2. 활동 메뉴
            // =========================================================
            _buildMenuItem(
              '공감한 기도문',
              onTap: () {},
            ),

            _buildMenuItem(
              '내가 게시한 기도문',
              onTap: () {},
            ),

            _buildMenuItem(
              '가입한 커뮤니티',
              onTap: () {},
            ),

            // 활동 메뉴와 설정 메뉴 사이 간격
            const SizedBox(height: 36),

            // =========================================================
            // 3. 알림 설정
            // =========================================================
            _buildMenuItem(
              '알림 설정',
              onTap: () {},
            ),

            _buildMenuItem(
              '프로필 수정',
              onTap: () {},
            ),

            _buildMenuItem(
              '기도 알림',
              onTap: () {},
            ),

            _buildMenuItem(
              '문의',
              onTap: () {},
            ),

            // =========================================================
            // 아래쪽 공간을 자동으로 채움
            // =========================================================
            const Spacer(),

            // =========================================================
            // 4. 로그아웃 / 회원 탈퇴
            // =========================================================
            _buildMenuItem(
              '로그아웃',
              hasArrow: false,
              onTap: () {},
            ),

            _buildMenuItem(
              '회원 탈퇴',
              hasArrow: false,
              textColor: const Color(0xFFE35446),
              onTap: () {},
            ),

            const SizedBox(height: 38),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 공통 메뉴 한 줄
  // =========================================================
  static Widget _buildMenuItem(
    String title, {
    bool hasArrow = true,
    Color textColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 13,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
                fontFamily: 'Pretendard',
              ),
            ),

            if (hasArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }
}