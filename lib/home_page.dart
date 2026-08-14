import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:math';
import 'pray_time.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _primaryLightGreen = const Color.fromRGBO(234, 248, 203, 1);
  final Color _greyBackground = const Color.fromRGBO(242, 242, 247, 1);

  String _nickname = '소세기';

  final List<Map<String, String>> _verses = [
    {'text': '아무 것도 염려하지 말고 다만 모든 일에 기도와 간구로, 너희 구할 것을 감사함으로 하나님께 아뢰라', 'ref': '빌 4:6'},
    {'text': '모든 기도와 간구를 하되 항상 성령 안에서 기도하고 이를 위하여 깨어 구하기를 항상 힘쓰며', 'ref': '엡 6:18'},
    {'text': '너는 내게 부르짖으라 내가 네게 응답하겠고 네가 알지 못하는 크고 은밀한 일을 네게 보이리라', 'ref': '렘 33:3'},
    {'text': '구하라 그리하면 너희에게 주실 것이요 찾으라 그리하면 찾아낼 것이요 문을 두드리라', 'ref': '마 7:7'},
    {'text': '구하라 그러면 너희에게 주실 것이요 찾으라 그러면 찾아낼 것이요 문을 두드리라 그러면 너희에게 열릴 것이니', 'ref': '눅 11:9'},
    {'text': '예수께서 그들에게 항상 기도하고 낙심하지 말아야 할 것을 비유로 말씀하여', 'ref': '눅 18:1'},
    {'text': '너희는 내게 부르짖으며 와서 내게 기도하면 내가 너희들의 기도를 들을 것이요', 'ref': '렘 29:12'},
    {'text': '의인이 부르짖으매 여호와께서 들으시고 그들의 모든 환난에서 건지셨도다', 'ref': '시 34:17'},
    {'text': '여호와께서는 자기에게 간구하는 모든 자 곧 진실하게 간구하는 모든 자에게 가까이 하시는도다', 'ref': '시 145:18'},
    {'text': '여호와와 그의 능력을 구할지어다 항상 그의 얼굴을 찾을지어다', 'ref': '대상 16:11'},
    {'text': '네 짐을 여호와께 맡기라 그가 너를 붙드시고 의인의 요동함을 영원히 허락하지 아니하시리로다', 'ref': '시 55:22'},
  ];

  late Map<String, String> _todayVerse;

  @override
  void initState() {
    super.initState();
    _todayVerse = _verses[Random().nextInt(_verses.length)];
    _loadUserNickname();
  }

  Future<void> _loadUserNickname() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data();

    if (data != null && data['nickname'] != null) {
      if (!mounted) return;

      setState(() {
        _nickname = data['nickname'] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 21, right: 21, bottom: 13, top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        '$_nickname님,\n좋은 아침입니다',
                        style: TextStyle(fontSize: 32, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, height: 1.3, color: Colors.black),
                      ),
                      const SizedBox(height: 14.5),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${_todayVerse['text']} ',
                              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Colors.black, height: 1.5, fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: _todayVerse['ref'],
                              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Colors.black, height: 1.5, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 3,
                    right: 0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Image.asset('assets/images/alert.png', width: 19, height: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                '이번주 기도 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDayStatus('Sun', false, false),
                  _buildDayStatus('Mon', false, false),
                  _buildDayStatus('Tue', true, false),
                  _buildDayStatus('Wed', false, false),
                  _buildDayStatus('Thu', false, false),
                  _buildDayStatus('Fri', true, true),
                  _buildDayStatus('Sat', false, false),
                ],
              ),
              const SizedBox(height: 35),

              // 👈 여기서 버튼 클릭 시 widget.onNavigateToPrayer를 실행하여 탭을 넘깁니다!
              _buildSectionButton(
                '오늘의 이음 기도 시간',
                '시작',
                () {
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
              ),

              const SizedBox(height: 23.3),
              _buildSectionButton('기도문 작성', '작성하기', () {}), // 이건 아직 동작 없음
              const SizedBox(height: 40),

              const Text(
                '내가 가입한 커뮤니티',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCommunityCard('북한 중보기도\n커뮤니티', Colors.blue.shade100),
                    const SizedBox(width: 16),
                    _buildCommunityCard('22학번\n한동기도클럽', Colors.grey.shade300),
                    const SizedBox(width: 16),
                    _buildCommunityCard('애국자\n기도모임', Colors.red.shade100),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ); // Scaffold 없이 내용물만 반환합니다.
  }

  Widget _buildDayStatus(String day, bool isAttended, bool isToday) {
    Widget circleWidget = Container(
      width: isToday ? 48 : 42,
      height: isToday ? 48 : 42,
      decoration: BoxDecoration(
        color: isAttended ? _primaryLightGreen : _greyBackground,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: const Color.fromRGBO(72, 95, 63, 1), width: 1.5) : null,
      ),
    );
    if (!isToday) {
      circleWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: circleWidget,
      );
    }
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? const Color.fromRGBO(72, 95, 63, 1) : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        circleWidget,
      ],
    );
  }

  // onTap을 매개변수로 받아 클릭 동작을 유연하게 처리
  Widget _buildSectionButton(String title, String buttonText, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.black,
              backgroundColor: _primaryLightGreen,
              elevation: 0.7,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: onTap, // 전달받은 동작 실행
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCard(String title, Color bgColor) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
