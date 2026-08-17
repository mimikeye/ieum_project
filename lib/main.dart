import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'calender_main.dart';
import 'pray_page.dart';
import 'splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // Firebase 초기화
  // ==========================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PrayerApp());
}

// =======================================================
// 이음 앱
// =======================================================

class PrayerApp extends StatelessWidget {
  const PrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '이음',

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
        useMaterial3: false,
      ),

      // 앱 실행 시 로그인 화면부터 시작
      home: const SplashPage(),
    );
  }
}

// =======================================================
// 네비게이션 바 + 화면 전환
// =======================================================

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  final Color _primaryDarkGreen =
      const Color(0xFF3B5B39);

  late PageController _pageController;

  // 현재 로그인한 사용자
  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =====================================================
  // 하단 네비게이션 탭
  // =====================================================

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // =====================================================
  // 홈 → 기도 화면
  // =====================================================

  void _goToPrayerTab() {
    _onItemTapped(2);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _currentUser;

    // 로그인하지 않은 상태에서 RootScreen으로 들어온 경우
    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,

        // 필요하면 화면 스와이프를 막을 수 있음
        // physics: const NeverScrollableScrollPhysics(),

        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        children: [
          // =================================================
          // 0. 홈
          // =================================================

          const HomeScreen(),

          // =================================================
          // 1. 캘린더
          // =================================================

          const CalendarPage(),

          // =================================================
          // 2. 기도
          // =================================================

          PrayerScreen(),

          // =================================================
          // 3. 커뮤니티
          // =================================================

          const Center(
            child: Text('커뮤니티 화면'),
          ),

          // =================================================
          // 4. 프로필
          // =================================================

          //const ProfileScreen(),
          const Center(
            child: Text('프로필 화면'),
          ),
        ],
      ),

      // =====================================================
      // 하단 네비게이션 바
      // =====================================================

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFE8E8E8),
              width: 1,
            ),
          ),
        ),

        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFF9F9F9),

          type: BottomNavigationBarType.fixed,

          elevation: 0,

          currentIndex: _selectedIndex,

          selectedItemColor: _primaryDarkGreen,

          unselectedItemColor: Colors.grey,

          selectedFontSize: 10,

          unselectedFontSize: 10,

          onTap: _onItemTapped,

          items: [
            // =================================================
            // 홈
            // =================================================

            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ),

                child: Image.asset(
                  'assets/images/0_home_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),

              label: '홈',

              activeIcon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ),

                child: Image.asset(
                  'assets/images/1_home_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),

            // =================================================
            // 캘린더
            // =================================================

            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ),

                child: Image.asset(
                  'assets/images/0_calender_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),

              label: '캘린더',

              activeIcon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ),

                child: Image.asset(
                  'assets/images/1_calender_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),

            // =================================================
            // 기도
            // =================================================

            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 3,
                ),

                child: Image.asset(
                  'assets/images/0_pray_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),

              label: '기도',

              activeIcon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 3,
                ),

                child: Image.asset(
                  'assets/images/1_pray_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),

            // =================================================
            // 커뮤니티
            // =================================================

            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 1,
                ),

                child: Image.asset(
                  'assets/images/0_community_icon.png',
                  width: 22.5,
                  height: 22.5,
                ),
              ),

              label: '커뮤니티',

              activeIcon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 1,
                ),

                child: Image.asset(
                  'assets/images/1_community_icon.png',
                  width: 22.5,
                  height: 22.5,
                ),
              ),
            ),

            // =================================================
            // 프로필
            // =================================================

            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                  top: 1,
                ),

                child: Image.asset(
                  'assets/images/0_user_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),

              label: '프로필',

              activeIcon: Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                  top: 1,
                ),

                child: Image.asset(
                  'assets/images/1_user_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}