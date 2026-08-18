import 'package:flutter/material.dart';

Future<List<String>?> showCommunitySelection({
  required BuildContext context,
}) async {
  return await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const CommunitySelectionSheet();
    },
  );
}

class CommunitySelectionSheet extends StatefulWidget {
  const CommunitySelectionSheet({
    super.key,
  });

  @override
  State<CommunitySelectionSheet> createState() =>
      _CommunitySelectionSheetState();
}

class _CommunitySelectionSheetState
    extends State<CommunitySelectionSheet> {
  final List<String> _selectedCommunities = [];

  // 현재는 Firebase 연결 전이므로 임시 데이터 사용
  final List<String> _joinedCommunities = [
    '22학번 한동기도클럽',
    '북한 중보기도 커뮤니티',
    '장성 교회 청년부',
    '애국자 기도모임',
  ];

  final String _publicCommunity = '이음 기도 게시판';
  

  void _toggleCommunity(String community) {
    setState(() {
      if (_selectedCommunities.contains(community)) {
        _selectedCommunities.remove(community);
      } else {
        _selectedCommunities.add(community);
      }
    });
  }

  void _confirmSelection() {
    if (_selectedCommunities.isEmpty) {
      return;
    }

    Navigator.pop(
      context,
      List<String>.from(_selectedCommunities),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =========================
            // 상단 헤더
            // =========================
            SizedBox(
              height: 64,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      '커뮤니티 선택',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: GestureDetector(
                        onTap: _selectedCommunities.isEmpty
                            ? () {
                                Navigator.pop(context);
                              }
                            : _confirmSelection,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: _selectedCommunities.isEmpty ? 40 : 68,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedCommunities.isEmpty
                                ? const Color(0xFFD9D9D9)
                                : const Color(0xFFEAF8CB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _selectedCommunities.isEmpty
                              ? const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 26,
                                )
                              : Text(
                                  '${_selectedCommunities.length} 확인',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // 내용
            // =========================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  22,
                  22,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------
                    // 전체 커뮤니티
                    // -------------------------
                    const Text(
                      '전체 커뮤니티',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: 110,
                      height: 110,
                      child: _buildCommunityCard(
                        name: _publicCommunity,
                        isSelected:
                            _selectedCommunities.contains(
                          _publicCommunity,
                        ),
                      ),
                    ),

                    const SizedBox(height: 58),

                    // -------------------------
                    // 내가 가입한 커뮤니티
                    // -------------------------
                    const Text(
                      '내가 가입한 커뮤니티',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: _joinedCommunities.map((community) {
                        return SizedBox(
                          width: 110,
                          height: 110,
                          child: _buildCommunityCard(
                            name: community,
                            isSelected:
                                _selectedCommunities.contains(
                              community,
                            ),
                          ),
                        );
                      }).toList(),
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

  String _formatCommunityName(String name) {
    const maxCharsPerLine = 7;

    final words = name.split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (final word in words) {
      final testLine = currentLine.isEmpty
          ? word
          : '$currentLine $word';

      if (testLine.length <= maxCharsPerLine) {
        currentLine = testLine;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }

        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.join('\n');
  }

  Widget _buildCommunityCard({
    required String name,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _toggleCommunity(name),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEAF8CB)
              : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _formatCommunityName(name),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1.3,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),

            // 선택된 경우 오른쪽 위 체크
            if (isSelected)
              Positioned(
                top: 4,
                right: 5,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB3CA83),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}