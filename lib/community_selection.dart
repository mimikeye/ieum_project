import 'package:flutter/material.dart';
import 'package:ieum_project/community_service.dart';

Future<Map<String, dynamic>?> showCommunitySelection({
  required BuildContext context,
}) async {
  return await showModalBottomSheet<Map<String, dynamic>>(
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
  final List<String> _selectedCommunityIds = [];

  bool _isPublicSelected = false;

  List<Map<String, dynamic>> _joinedCommunities = [];

  bool _isLoadingCommunities = true;

  final String _publicCommunity = '이음 기도 게시판';

  @override
  void initState() {
    super.initState();
    _loadJoinedCommunities();
  }

  Future<void> _loadJoinedCommunities() async {
    try {
      final communities =
          await CommunityService.getMyJoinedCommunities();

      if (!mounted) return;

      setState(() {
        _joinedCommunities = communities;
        _isLoadingCommunities = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCommunities = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('가입한 커뮤니티를 불러오지 못했습니다.'),
        ),
      );
    }
  }

  void _toggleCommunity(String communityId) {
    setState(() {
      if (_selectedCommunityIds.contains(communityId)) {
        _selectedCommunityIds.remove(communityId);
      } else {
        _selectedCommunityIds.add(communityId);
      }
    });
  }

  void _togglePublicCommunity() {
    setState(() {
      _isPublicSelected = !_isPublicSelected;
    });
  }

  void _confirmSelection() {
    if (_selectedCommunityIds.isEmpty &&
        !_isPublicSelected) {
      return;
    }

    Navigator.pop(
      context,
      {
        'communityIds':
            List<String>.from(_selectedCommunityIds),
        'publishToPublic': _isPublicSelected,
      },
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
                        onTap: (_selectedCommunityIds.isEmpty &&
                                !_isPublicSelected)
                            ? () {
                                Navigator.pop(context);
                              }
                            : _confirmSelection,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: (_selectedCommunityIds.isEmpty &&
                                  !_isPublicSelected)
                              ? 40
                              : 68,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (_selectedCommunityIds.isEmpty &&
                                    !_isPublicSelected)
                                ? const Color(0xFFD9D9D9)
                                : const Color(0xFFEAF8CB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: (_selectedCommunityIds.isEmpty &&
                                  !_isPublicSelected)
                              ? const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 26,
                                )
                              : Text(
                                  '${_selectedCommunityIds.length +
                                      (_isPublicSelected ? 1 : 0)} 확인',
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
                  20,
                  22,
                  22,
                  40,
                ),
                child: SizedBox(
                  width: double.infinity,
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
                        child: GestureDetector(
                          onTap: _togglePublicCommunity,
                          child: _buildCommunityCard(
                            name: _publicCommunity,
                            isSelected: _isPublicSelected,
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
                  
                      if (_isLoadingCommunities)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_joinedCommunities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            '가입한 커뮤니티가 없습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        )
                      else
                        Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          spacing: 14,
                          runSpacing: 14,
                          children: _joinedCommunities.map((community) {
                            final communityId =
                                community['communityId'] as String;
                  
                            final communityName =
                                community['communityName'] as String? ?? '';
                  
                            return SizedBox(
                              width: 110,
                              height: 110,
                              child: _buildCommunityCard(
                                name: communityName,
                                isSelected:
                                    _selectedCommunityIds.contains(
                                  communityId,
                                ),
                                onTap: () {
                                  _toggleCommunity(communityId);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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