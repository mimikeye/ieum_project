import 'package:flutter/material.dart';
import 'pray_write_page.dart';
import 'prayer_note_service.dart';

class PrayerNoteDetailPage extends StatefulWidget {
  final Map<String, dynamic> note;
  final String noteId;

  const PrayerNoteDetailPage({
    super.key,
    required this.note,
    required this.noteId,
  });

    @override
  State<PrayerNoteDetailPage> createState() =>
      _PrayerNoteDetailPageState();
}

class _PrayerNoteDetailPageState
    extends State<PrayerNoteDetailPage> {

  late Map<String, dynamic> _note;

  @override
  void initState() {
    super.initState();

    _note = Map<String, dynamic>.from(widget.note);
  }


  Future<void> _reloadNote() async {
    final updatedNote = await PrayerNoteService.getPrayerNote(
      noteId: widget.noteId,
    );

    if (updatedNote == null || !mounted) return;

    setState(() {
      _note = updatedNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = _note['title'] ?? '';
    final String content = _note['content'] ?? '';

    final List<String> categories =
        List<String>.from(_note['categories'] ?? []);

    final List<String> imageUrls =
        List<String>.from(_note['imageUrls'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ), // 👇 이 숫자를 키울수록 버튼이 오른쪽으로 밀려납니다!
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          '나의 이음 기도문',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
          ),
        ),
        centerTitle: false,
        titleSpacing: 4,

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 21),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD9E7BF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrayerWriteScreen(
                        noteId: widget.noteId,
                        initialNote: _note,
                      ),
                    ),
                  );

                  await _reloadNote();
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 247, 247, 1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double areaHeight = constraints.maxHeight;

                        return Stack(
                          children: [
                            // 배경 밑줄과 글자가 함께 스크롤되도록 구조 변경
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  // 글이 짧아도 전체 화면에 줄이 그어지도록 최소 높이를 areaHeight로 설정
                                  minHeight: areaHeight,
                                ),
                                child: Stack(
                                  children: [
                                    // 💡 [수정됨] 1. 배경 선 그리기: 카테고리 유무에 따라 굵은 선의 위치를 동적으로 조절
                                    // 💡 [수정됨] 1. 배경 선 그리기: Positioned.fill을 사용해 글 길이에 맞춰 도화지를 무한히 늘립니다.
                                    Positioned.fill(
                                      child: CustomPaint(
                                        // 💡 고정된 size 옵션을 아예 삭제합니다!
                                        painter: LinedPaperPainter(
                                          lineHeight: 36.0,
                                          titleHeight: 90.0,
                                        ),
                                      ),
                                    ),

                                    // 제목, 카테고리, 본문 입력창 Column
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // 1. 제목 입력창
                                        SizedBox(
                                          height: 50.0,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                title,
                                                style: const TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontFamily: 'Pretendard',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 💡 [수정됨] 2. 카테고리 태그를 제목 밑으로 이동 및 가로 스크롤 적용
                                        if (categories.isNotEmpty)
                                          Container(
                                            height: 40.0, // 카테고리 영역 고정 높이
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              bottom: 8,
                                            ),
                                            alignment: Alignment
                                                .centerLeft, // 태그를 왼쪽 정렬
                                            child: SingleChildScrollView(
                                              scrollDirection:
                                                  Axis.horizontal, // 가로 스크롤
                                              // ... 카테고리 가로 스크롤 부분 ...
                                              child: Row(
                                                children: categories.map((
                                                  category,
                                                ) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 6.0,
                                                        ),
                                                    child: Stack(
                                                      children: [
                                                        // 👇 1. 카테고리 글자를 감싸는 둥근 껍데기
                                                        Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                top: 6,
                                                                right: 6,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .grey
                                                                  .shade300,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            category,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Color.fromRGBO(
                                                                    166,
                                                                    166,
                                                                    166,
                                                                    1,
                                                                  ),
                                                              fontFamily:
                                                                  'Pretendard',
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              content,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 36.0 / 14,
                                                color: Colors.black87,
                                                fontFamily: 'Pretendard',
                                              ),
                                            ),
                                          ),
                                        ),

                                        if (imageUrls.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 20,
                                              bottom: 20,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                imageUrls.first,
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinedPaperPainter extends CustomPainter {
  final double lineHeight;
  final double titleHeight;

  LinedPaperPainter({required this.lineHeight, required this.titleHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final normalPaint = Paint()
      ..color = const Color.fromRGBO(224, 224, 224, 1)
      ..strokeWidth = 1;

    final thickPaint = Paint()
      ..color = const Color.fromRGBO(206, 206, 206, 1)
      ..strokeWidth = 2.0;

    // 1. 제목 첫 줄 굵은 선
    canvas.drawLine(
      Offset(20, titleHeight),
      Offset(size.width - 20, titleHeight),
      thickPaint,
    );

    // 2. 그 밑으로 본문 밑줄 그리기
    double currentY = titleHeight + lineHeight;

    // 💡 [이 부분 수정!]
    // size.height 에서 숫자를 빼주면, 바닥에서 그 숫자만큼 띄우고 선 그리기를 멈춥니다.
    // 숫자를 크게 할수록 밑줄이 일찍 끊겨서 밑줄의 마지막 위치가 위로 올라갑니다! (예: 60, 80, 100 등 자유롭게 조절)
    final double stopY = size.height + 20.0;

    while (currentY < stopY) {
      canvas.drawLine(
        Offset(20, currentY),
        Offset(size.width - 20, currentY),
        normalPaint,
      );
      currentY += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.lineHeight != lineHeight ||
        oldDelegate.titleHeight != titleHeight;
  }
}