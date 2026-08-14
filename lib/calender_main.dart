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

  // 💡 main.dart에서 통합 관리하므로 _selectedIndex 와 _primaryDarkGreen 관련 변수는 삭제했습니다.

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
  // 연도 / 월 선택창
  // ==========================================

  void _showMonthYearPicker() {
    int selectedYear = _displayedMonth.year;
    int selectedMonth = _displayedMonth.month;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text(
                '날짜 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 연도 선택
                  DropdownButton<int>(
                    borderRadius: BorderRadius.circular(10),
                    value: selectedYear,
                    focusColor: Color(0xFFCBCBCB),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(
                      7,
                      (index) => DateTime.now().year - 3 + index,
                    ).map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          '$year년',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedYear = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // 월 선택
                  DropdownButton<int>(
                    borderRadius: BorderRadius.circular(12),
                    focusColor: Color(0xFFCBCBCB),
                    value: selectedMonth,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(
                      12,
                      (index) => index + 1,
                    ).map((month) {
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(
                          '$month월',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedMonth = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFCBCBCB)
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB3CA83)
                  ),
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(
                        selectedYear,
                        selectedMonth,
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 날짜 그리드용 데이터 계산
  // ==========================================

  List<int?> _buildDayCells() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

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
                  // ====================================
                  // 왼쪽: 현재 월
                  // ====================================
                  Transform.translate(
                    offset: const Offset(0, 12),
                    child: Text(
                      '${_displayedMonth.month}',
                      style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ),

                  // ====================================
                  // 오른쪽: 연도 + 아래 화살표 + 이전/다음
                  // ====================================
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 연도 + 아래 화살표
                        GestureDetector(
                          onTap: _showMonthYearPicker,
                          child: Row(
                            children: [
                              Text(
                                '${_displayedMonth.year}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(width: 3),

                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 이전 달
                        GestureDetector(
                          onTap: _goToPreviousMonth,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Image(
                              image: AssetImage(
                                'assets/images/calender_last.png',
                              ),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),

                        // 이전 / 다음 화살표 사이 6px
                        const SizedBox(width: 20),

                        // 다음 달
                        GestureDetector(
                          onTap: _goToNextMonth,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Image(
                              image: AssetImage(
                                'assets/images/calender_next.png',
                              ),
                              width: 20,
                              height: 20,
                            ),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final day = dayCells[index];

                  if (day == null) {
                    return const SizedBox.shrink();
                  }

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
      // 💡 여기에 있던 bottomNavigationBar 전체를 깔끔하게 지웠습니다!
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