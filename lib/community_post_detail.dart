import 'package:flutter/material.dart';
import 'package:ieum_project/community_service.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final String communityId;
  final String postId;
  final bool isPublicPost;
  final String communityName;
  final String title;
  final String content;
  final String tag;
  final int amenCount;

  final List<String> imageUrls;

  const CommunityPostDetailScreen({
    super.key,
    required this.communityId,
    required this.postId,
    required this.isPublicPost,
    required this.communityName,
    required this.title,
    required this.content,
    required this.tag,
    required this.amenCount,
    this.imageUrls = const [],
  });

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState
    extends State<CommunityPostDetailScreen> {
  late int _amenCount;
  bool _isAmen = false;

  @override
  void initState() {
    super.initState();
    _amenCount = widget.amenCount;
  }

  Future<void> _toggleAmen() async {
    final previousIsAmen = _isAmen;

    // 먼저 화면을 즉시 변경
    setState(() {
      _isAmen = !_isAmen;

      if (_isAmen) {
        _amenCount++;
      } else {
        _amenCount--;
      }
    });

    try {
      if (_isAmen) {
        await CommunityService.addAmen(
          postId: widget.postId,
        );
      } else {
        await CommunityService.removeAmen(
          postId: widget.postId,
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Firebase 저장에 실패하면 화면도 원래대로 복구
      setState(() {
        _isAmen = previousIsAmen;

        if (_isAmen) {
          _amenCount++;
        } else {
          _amenCount--;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('아멘 처리에 실패했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // 상단
            // ============================================================
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                  ),
                ),

                Text(
                  widget.communityName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),

            // ============================================================
            // 게시글 + 아멘 버튼
            // ============================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  21,
                  18,
                  21,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ======================================================
                    // 기도문 카드
                    // ======================================================
                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: const Color(0x33D9D9D9),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          20,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // 제목
                            // ==================================================
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 8.4),

                            // ==================================================
                            // 카테고리
                            // ==================================================
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFA6A6A6),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.tag,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFA6A6A6),
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),

                            const SizedBox(height: 11),

                            // ==================================================
                            // 제목 / 카테고리 아래 굵은 선
                            // ==================================================
                            Container(
                              width: double.infinity,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCECECE),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(height: 3.5),

                            // ==================================================
                            // 본문 + 줄
                            // ==================================================
                            SizedBox(
                              width: double.infinity,
                              child: CustomPaint(
                                painter: CommunityLinedPaperPainter(
                                  lineHeight: 36.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    widget.content,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 2.25,
                                      fontFamily: 'Pretendard',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ==================================================
                            // 이미지
                            // ==================================================
                            if (widget.imageUrls.isNotEmpty) ...[
                              const SizedBox(height: 16),

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children:
                                    widget.imageUrls.map((imageUrl) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }

                                          return const SizedBox(
                                            height: 180,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            // ==================================================
                            // 아멘 개수
                            // ==================================================
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/amen_icon.png',
                                  width: 24,
                                  height: 24,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  '$_amenCount',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ========================================================
                    // 아멘 버튼
                    //
                    // 카드 아래에서 13px 떨어지도록 배치
                    // ========================================================
                    const SizedBox(height: 13),

                    GestureDetector(
                      onTap: _toggleAmen,
                      child: SizedBox(
                        width: 75,
                        height: 30,
                        child: Image.asset(
                          _isAmen
                              ? 'assets/images/amen_on.png'
                              : 'assets/images/amen_off.png',
                          width: 75,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 본문 줄 그리기
// ==========================================================================

class CommunityLinedPaperPainter extends CustomPainter {
  final double lineHeight;

  CommunityLinedPaperPainter({
    required this.lineHeight,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1.5;

    // 본문 한 줄의 아래쪽에 맞춤
    double y = 35;

    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );

      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(
    covariant CommunityLinedPaperPainter oldDelegate,
  ) {
    return oldDelegate.lineHeight != lineHeight;
  }
}