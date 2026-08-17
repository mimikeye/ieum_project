import 'package:flutter/material.dart';
import 'category_selection.dart';

// 💡 1. 텍스트 변화에 따라 화면을 업데이트해야 하므로 StatefulWidget으로 변경합니다.
class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> {
  // 💡 2. 텍스트 입력값을 제어하고 읽어오기 위한 컨트롤러 생성
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 💡 3. 글자가 입력되거나 지워질 때마다 화면을 새로고침(setState)하여 x 버튼을 표시/숨김 처리합니다.
    _searchController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    // 💡 4. 화면이 종료될 때 메모리 누수를 방지하기 위해 컨트롤러를 해제합니다.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 30.0),
          child: Column(
            children: [
              Row(
                children: [
                  // --- 뒤로 가기 버튼 (<) ---
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); 
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new, 
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12), 
                  
                  // --- 검색 텍스트 필드 ---
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController, // 💡 5. 컨트롤러 연결
                        autofocus: true, 
                        cursorColor: const Color.fromRGBO(138, 136, 136, 1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          
                          // 왼쪽 돋보기 아이콘
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color.fromRGBO(138, 136, 136, 1),
                            size: 21,
                          ),
                          
                          // 💡 6. 오른쪽 X 버튼 (글자가 있을 때만 보여줌)
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear(); // 💡 누르면 텍스트 전체 삭제
                                  },
                                  child: const Icon(
                                    Icons.cancel, // 피그마 이미지와 동일한 회색 동그라미 x 아이콘
                                    color: Color.fromRGBO(200, 200, 200, 1),
                                    size: 19,
                                  ),
                                )
                              : null, // 글자가 없으면 안 보여줌
                              
                          // 기본 상태 테두리
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(234, 248, 203, 1), 
                              width: 1.0,
                            ),
                          ),
                          // 클릭(포커스)된 상태 테두리
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(234, 248, 203, 1),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}