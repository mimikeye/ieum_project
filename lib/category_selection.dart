import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// 메인 화면에서 시트를 호출하는 함수
Future<List<String>?> showCategorySelectionSheet({
  required BuildContext context,
  List<String> initialSelectedCategories = const [],
}) async {
  return await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CategorySelectionSheet(
        initialSelectedCategories: initialSelectedCategories,
      );
    },
  );
}

// 바텀 시트의 내용을 구성하는 상태 관리 위젯
class CategorySelectionSheet extends StatefulWidget {
  final List<String> initialSelectedCategories;

  const CategorySelectionSheet({
    super.key,
    required this.initialSelectedCategories,
  });

  @override
  State<CategorySelectionSheet> createState() => _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends State<CategorySelectionSheet> {
  late List<String> _tempSelectedCategories;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategories = List.from(widget.initialSelectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    // 💡 5-4-5-4 개수로 줄바꿈 강제 배열
    final List<List<String>> categoryRows = [
      ['묵상', '감사', '회개', '중보', '간구'],
      ['개인', '가족', '부모님', '배우자'],
      ['공동체', '직장', '동료', '선교', '교회'],
      ['나라', '경제', '학업·진로', '기타'],
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      // 💡 왼쪽 여백 34, 오른쪽 16
      padding: const EdgeInsets.only(top: 24, bottom: 40, left: 34, right: 16),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(247, 247, 247, 1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- 상단 헤더 ---
          Stack(
            alignment: Alignment.center,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(right: 18.0),
                  child: Text(
                    '기도문 카테고리',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, _tempSelectedCategories);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        // 💡 배경색: 선택 시 연두색, 미선택 시 회색
                        color: _tempSelectedCategories.isNotEmpty
                            ? const Color.fromRGBO(234, 248, 203, 1)
                            : const Color.fromRGBO(224, 224, 224, 1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          // 💡 테두리: 선택 시 투명, 미선택 시 짙은 회색
                          color: _tempSelectedCategories.isNotEmpty
                              ? Colors.transparent
                              : const Color.fromRGBO(205, 205, 205, 1),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Colors.white, // 💡 체크 아이콘은 항상 흰색으로 유지
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // --- 카테고리 버튼들 ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: categoryRows.map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.map((category) {
                        final isSelected = _tempSelectedCategories.contains(
                          category,
                        );
                        // 💡 버튼 너비 조건: 학업·진로(69), 3글자 이상(65), 2글자(51)
                        final double buttonWidth = category == '학업·진로'
                            ? 69.0
                            : (category.length >= 3 ? 60.0 : 51.0);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _tempSelectedCategories.remove(category);
                              } else {
                                _tempSelectedCategories.add(category);
                              }
                            });
                          },
                          child: Container(
                            width: buttonWidth,
                            height: 25,
                            margin: const EdgeInsets.only(right: 6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // 💡 선택 시 연두색 대신 rgba(166, 166, 166, 1) 적용
                              color: isSelected
                                  ? const Color.fromRGBO(166, 166, 166, 1)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : const Color.fromRGBO(166, 166, 166, 1),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 15,
                                  // 💡 선택 시 글자색은 흰색으로(배경이 회색이므로), 미선택 시 회색 적용
                                  color: isSelected
                                      ? Colors.white
                                      : const Color.fromRGBO(166, 166, 166, 1),
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
