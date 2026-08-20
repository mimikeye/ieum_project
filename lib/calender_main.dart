import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'prayer_note_service.dart';
import 'prayer_note_detail_page.dart';

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

  // ==========================================
  // 기도/활동 기록이 있는 날짜
  // ==========================================

  Set<String> _activityDates = {};

  String? _selectedDate;

  int _selectedDatePrayerTime = 0;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _selectedDateNotes = [];

  // 💡 main.dart에서 통합 관리하므로 _selectedIndex 와 _primaryDarkGreen 관련 변수는 삭제했습니다.

  Future<void> _loadPrayerTime(String dateKey) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userSnapshot.data();

    if (userData == null) return;

    final username = userData['username'] as String?;

    if (username == null || username.isEmpty) return;

    final doc = await FirebaseFirestore.instance
        .collection('dailyActivities')
        .doc(username)
        .collection('dates')
        .doc(dateKey)
        .get();

    if (!doc.exists) {
      if (!mounted) return;

      setState(() {
        _selectedDatePrayerTime = 0;
      });

      return;
    }

    final data = doc.data();

    final prayerTime =
        (data?['prayerTime'] as num?)?.toInt() ?? 0;

    if (!mounted) return;

    setState(() {
      _selectedDatePrayerTime = prayerTime;
    });
  }

  Future<void> _loadPrayerNotes(String dateKey) async {
    try {
      final snapshot = await PrayerNoteService.getPrayerNotes();

      final notes = snapshot.docs.where((note) {
        final data = note.data();

        final date = (data['date'] ?? '').toString();

        return date == dateKey;
      }).toList();

      if (!mounted) return;

      setState(() {
        _selectedDateNotes = notes;
      });
    } catch (e) {
      debugPrint('기도문 불러오기 오류: $e');

      if (!mounted) return;

      setState(() {
        _selectedDateNotes = [];
      });
    }
  }

  Widget _buildCalendarPrayerItem(
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

    if (date.length >= 10) {
      displayDate =
          '${date.substring(5, 7)}.${date.substring(8, 10)}';
    }

    final String tag =
    categories.isNotEmpty ? categories.first : '';

    final int additionalCategoryCount =
        categories.length > 1 ? categories.length - 1 : 0;

    final String? imageUrl =
        imageUrls.isNotEmpty ? imageUrls.first : null;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrayerNoteDetailPage(
                note: data,
                noteId: note.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          Text(
                            displayDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              color: Colors.grey.shade600,
                            ),
                          ),

                          if (tag.isNotEmpty) ...[
                          const SizedBox(width: 8),

                          Container(
                            width: 0.5,
                            height: 11,
                            color: const Color.fromRGBO(
                              113,
                              113,
                              113,
                              100,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromRGBO(
                                  166,
                                  166,
                                  166,
                                  1,
                                ),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: Color.fromRGBO(
                                  166,
                                  166,
                                  166,
                                  1,
                                ),
                              ),
                            ),
                          ),
                          if (additionalCategoryCount > 0) ...[
                            const SizedBox(width: 2),

                            Text(
                              '+$additionalCategoryCount',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Pretendard',
                                color: Color.fromRGBO(
                                  166,
                                  166,
                                  166,
                                  1,
                                ),
                              ),
                            ),
                          ],
                        ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: SizedBox(
                    width: 95,
                    height: 95,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
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

  String _formatPrayerTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 $seconds초';
    }

    if (minutes > 0) {
      return '$minutes분 $seconds초';
    }

    return '$seconds초';
  }

  // ==========================================
  // Firestore 활동 날짜 가져오기
  // ==========================================

  Future<void> _loadActivityDates() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // users/{uid}에서 username 가져오기
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userSnapshot.data();

    if (userData == null) return;

    final username = userData['username'] as String?;

    if (username == null || username.isEmpty) return;

    // dailyActivities/{username}/dates 가져오기
    final snapshot = await FirebaseFirestore.instance
        .collection('dailyActivities')
        .doc(username)
        .collection('dates')
        .get();

    final activityDates = <String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data['prayed'] == true ||
          data['wrotePrayer'] == true ||
          ((data['prayerTime'] ?? 0) as num) > 0) {
        activityDates.add(doc.id);
      }
    }

    if (!mounted) return;

    setState(() {
      _activityDates = activityDates;
    });
  }

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    _selectedDate = todayKey;

    _loadActivityDates();
    _loadPrayerTime(todayKey);
    _loadPrayerNotes(todayKey);
  }

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

                  final today = DateTime.now();

                  final isToday =
                      _displayedMonth.year == today.year &&
                      _displayedMonth.month == today.month &&
                      day == today.day;

                  final dateKey =
                      '${_displayedMonth.year.toString().padLeft(4, '0')}-'
                      '${_displayedMonth.month.toString().padLeft(2, '0')}-'
                      '${day.toString().padLeft(2, '0')}';

                  final hasActivity = _activityDates.contains(dateKey);
                  final isSelected = _selectedDate == dateKey;

                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = dateKey;
                        });

                        _loadPrayerTime(dateKey);
                        _loadPrayerNotes(dateKey);
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasActivity
                              ? const Color(0xFFEAF8CB)
                              : Colors.transparent,
                          border: isToday
                              ? Border.all(
                                  color: Colors.black,
                                  width: 1,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 312,
                        height: 41,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          '${_formatPrayerTime(_selectedDatePrayerTime)} 기도했어요.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEEEEEE),
                      ),

                      const SizedBox(height: 8),

                      if (_selectedDateNotes.isEmpty)
                        const Padding(
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
                        )
                      else
                        Column(
                          children: [
                            for (int i = 0;
                                i < _selectedDateNotes.length;
                                i++) ...[
                              _buildCalendarPrayerItem(
                                _selectedDateNotes[i],
                              ),

                              if (i != _selectedDateNotes.length - 1)
                                const Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: Color(0xFFEEEEEE),
                                ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
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