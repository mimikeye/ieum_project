import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // ==========================================
  // 현재 화면에 표시 중인 월
  // ==========================================

  DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  int _selectedIndex = 1; // 캘린더 탭이 기본 선택

  static const Color _primaryDarkGreen = Color(0xFF485F3F);

  // ==========================================
  // 월 이동
  // ==========================================

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  // ==========================================
  // 날짜 그리드용 데이터 계산
  //
  // 맨 앞 빈 칸(null) + 1일~말일 + 뒤쪽 7의 배수를
  // 채우기 위한 빈 칸(null)
  // ==========================================

  List<int?> _buildDayCells() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    // DateTime.weekday: 월=1 ... 일=7
    // 일요일을 0으로 맞추기 위한 변환
    final leadingEmptyCount = firstDayOfMonth.weekday % 7;

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final cells = <int?>[
      ...List.filled(leadingEmptyCount, null),
      ...List.generate(daysInMonth, (index) => index + 1),
    ];

    // 마지막 줄을 7의 배수로 맞춤
    final trailingEmptyCount = (7 - cells.length % 7) % 7;

    cells.addAll(List.filled(trailingEmptyCount, null));

    return cells;
  }

  // ==========================================
  // 화면
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final dayCells = _buildDayCells();

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ====================================
            // 월 표시 + 화살표
            // ====================================

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_displayedMonth.month}',
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _goToPreviousMonth,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Image(
                              image: AssetImage(
                                'assets/images/calender_last.png',
                              ),
                              width: 12,
                              height: 12,
                            )
                          ),
                        ),

                        const SizedBox(width: 6),

                        GestureDetector(
                          onTap: _goToNextMonth,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Image(
                              image: AssetImage(
                                'assets/images/calender_next.png',
                              ),
                              width: 12,
                              height: 12,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ====================================
            // 요일 행
            // ====================================

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  _WeekdayLabel('Sun'),
                  _WeekdayLabel('Mon'),
                  _WeekdayLabel('Tue'),
                  _WeekdayLabel('Wed'),
                  _WeekdayLabel('Thu'),
                  _WeekdayLabel('Fri'),
                  _WeekdayLabel('Sat'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ====================================
            // 날짜 그리드
            // ====================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayCells.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final day = dayCells[index];

                  if (day == null) {
                    return const SizedBox.shrink();
                  }

                  // ----------------------------
                  // 원(기도 기록 표시)은 아직
                  // 데이터가 없으므로 항상 없음.
                  // 나중에 실제 기록 여부에 따라
                  // 이 부분에 초록 원 + 탭 이벤트를
                  // 조건부로 추가할 예정.
                  // ----------------------------

                  return Center(
                    child: Text(
                      '$day',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xFFE8E8E8),
                width: 1
              )
            )
          ),
        child: BottomNavigationBar(
            backgroundColor: Color(0xFFF9F9F9),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: _primaryDarkGreen,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Image.asset('assets/images/0_home_icon.png', width: 20, height: 20),
                ),
                label: '홈',
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Image.asset('assets/images/1_home_icon.png', width: 20, height: 20),
                ),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Image.asset(
                    'assets/images/0_calender_icon.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                label: '캘린더',
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Image.asset(
                    'assets/images/1_calender_icon.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Image.asset('assets/images/0_pray_icon.png', width: 20, height: 20),
                ),
                label: '기도',
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Image.asset('assets/images/1_pray_icon.png', width: 20, height: 20),
                ),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: Image.asset(
                    'assets/images/0_community_icon.png',
                    width: 22.5,
                    height: 22.5,
                  ),
                ),
                label: '커뮤니티',
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: Image.asset(
                    'assets/images/1_community_icon.png',
                    width: 22.5,
                    height: 22.5,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2, top: 1),
                  child: Image.asset('assets/images/0_user_icon.png', width: 20, height: 20),
                ),
                label: '프로필',
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2, top: 1),
                  child: Image.asset('assets/images/1_user_icon.png', width: 20, height: 20),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

// ==========================================
// 요일 라벨
// ==========================================

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}