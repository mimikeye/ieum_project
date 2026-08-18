//커뮤니티 만들기

import 'package:flutter/material.dart';
import 'package:ieum_project/community_screen.dart';
import 'package:image_picker/image_picker.dart'; // 💡 이미지 피커 추가
import 'dart:io'; // 💡 File 객체 사용을 위해 추가

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  int _nameLength = 0; // 💡 1. 커뮤니티 이름 글자 수를 저장할 변수 추가
  int _descriptionLength = 0;
  
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkModifications);
    _descriptionController.addListener(_checkModifications);
  }

void _checkModifications() {
    setState(() {
      // 💡 2. 로직 변경: 제목이 비어있지 않아야만 무조건 초록색(true)으로 바뀝니다!
      // 사진이나 소개글이 있어도 제목이 없으면 버튼이 활성화되지 않습니다.
      _isModified = _nameController.text.trim().isNotEmpty;
    });
  }
  
  // ... (이하 _pickImage 등 나머지 함수들은 그대로 유지)

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false, // 선택사항: 메타데이터 요청 생략
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // 💡 1. 새로 추가할 팝업창 함수
  Future<bool> _showExitConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '커뮤니티 생성 화면을 나가시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9C9C9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '예',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBEBEB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
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
        );
      },
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 공통적으로 사용되는 테두리 색상
    final Color borderColor = Color.fromRGBO(197, 197, 197, 1);
    final Color hintColor = Color.fromRGBO(197, 197, 197, 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '커뮤니티 생성',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),

        // 💡 왼쪽 여백 16 + 버튼 크기 40 = 총 56의 가로 공간 확보
        leadingWidth: 56,

        // 좌측 X 버튼 (40x40 사이즈 적용)
        leading: Padding(
          padding: const EdgeInsets.only(left: 21.0),
          child: Center(
            child: SizedBox(
              width: 38,
              height: 38,
              child: InkWell(
                onTap: () async {
                  if (!_isModified) {
                    // 수정사항이 '없을 때' 팝업을 띄우고, '예'를 누르면 나감
                    final shouldExit = await _showExitConfirmDialog();
                    if (shouldExit && mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    // 수정사항이 '있을 때'도 필요하다면 동일하게 처리 (혹은 바로 나가기 등 상황에 맞게 조절 가능)
                    final shouldExit = await _showExitConfirmDialog();
                    if (shouldExit && mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                customBorder: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(217, 217, 217, 1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 29,
                  ), // 십자가 크기를 키우고 싶다면 size를 24 등으로 조절하세요
                ),
              ),
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 21.0),
            child: Center(
              child: SizedBox(
                width: 38,
                height: 38,
                child: InkWell(
                  onTap: _isModified
                      ? () {
                          // 💡 새로 변경된 이동 로직: 사용자가 입력한 데이터를 파라미터로 넘겨줍니다!
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommunityDetailScreen(
                                // 사진이 선택되었다면 File 객체로 변환해서 넘김
                                coverImage: _selectedImage != null
                                    ? File(_selectedImage!.path)
                                    : null,
                                // 입력창의 텍스트 값을 넘김
                                communityName: _nameController.text,
                                description: _descriptionController.text,
                              ),
                            ),
                          );
                        }
                      : null,
                  customBorder: const CircleBorder(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isModified
                          ? const Color.fromRGBO(234, 248, 203, 1)
                          : const Color.fromRGBO(217, 217, 217, 1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 커뮤니티 대표 이미지 박스
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(217, 217, 217, 1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _selectedImage != null
                        // 💡 단순 Image.file 대신 Stack을 사용해 위에 색상을 덮습니다.
                        ? Stack(
                            fit: StackFit.expand, // 이미지가 박스에 꽉 차게 설정
                            children: [
                              Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                              // 💡 사진 위에 회색 40% 불투명도 필터 씌우기
                              Container(
                                color: Colors.grey.withOpacity(0.4),
                                // (만약 더 어두운 느낌을 원하시면 Colors.black.withOpacity(0.4)를 추천합니다!)
                              ),
                            ],
                          )
                        : null,
                  ),

                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _pickImage, // 👈 버튼을 누르면 갤러리 여는 함수 실행!
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

// 2. 커뮤니티 이름 입력창
            Stack(
              children: [
                TextField(
                  controller: _nameController,
                  cursorColor: Colors.black,
                  maxLength: 15,
                  onChanged: (text) {
                    setState(() {
                      _nameLength = text.length;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '커뮤니티 이름 (필수)',
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    // 💡 X 버튼이 추가되었으므로 우측 패딩을 60에서 85로 넉넉히 늘려줍니다.
                    contentPadding: const EdgeInsets.only(
                      left: 24,
                      right: 85,
                      top: 18,
                      bottom: 18,
                    ),
                    counterText: "",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: borderColor, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Colors.grey.shade500,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                // 💡 내부 우측 수직 중앙에 X 버튼과 '0/15' 카운터 배치
                Positioned(
                  right: 24,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 💡 글자가 1자 이상 있을 때만 X 버튼 표시
                      if (_nameLength > 0)
                        GestureDetector(
                          onTap: () {
                            // X 버튼 누르면 텍스트 초기화 및 상태 업데이트
                            _nameController.clear();
                            setState(() {
                              _nameLength = 0;
                            });
                            _checkModifications(); // 초록색 체크 버튼 상태도 회색으로 다시 업데이트!
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8), // 카운터와의 간격
                            padding: const EdgeInsets.all(2), // 회색 동그라미 크기 조절용
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(217, 217, 217, 1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      // 글자 수 카운터
                      Text(
                        '$_nameLength/15',
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),

            // 3. 커뮤니티 소개 입력창 (글자 수 표시)
            Stack(
              children: [
                TextField(
                  controller: _descriptionController,
                  cursorColor: Colors.black,
                  maxLines: 6,
                  maxLength: 200,
                  onChanged: (text) {
                    setState(() {
                      _descriptionLength = text.length;
                    });
                  },
                  textAlignVertical: .top,
                  decoration: InputDecoration(
                    hintText: '커뮤니티를 소개해 주세요.',
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 17,
                      fontWeight: .w500,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      40,
                    ), // 텍스트 하단 여백 확보
                    counterText: "", // 기본 카운터 숨김
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // 이름창보다 약간 덜 둥글게
                      borderSide: BorderSide(color: borderColor, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.grey.shade500,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                // 내부 우측 하단 글자 수 카운터
                Positioned(
                  bottom: 16,
                  right: 24,
                  child: Text(
                    '$_descriptionLength/200',
                    style: TextStyle(color: hintColor, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 4. 커뮤니티 설정 섹션
            const Text(
              '커뮤니티 설정',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // 공개 범위 드롭다운
            _buildDropdownField('공개 범위', borderColor, hintColor),
            const SizedBox(height: 16),

            // 멤버 권한 설정 드롭다운
            _buildDropdownField('멤버 권한 설정', borderColor, hintColor),

            const SizedBox(height: 40), // 스크롤 여유 공간
          ],
        ),
      ),
    );
  }

  // 반복되는 드롭다운 필드를 위한 위젯 빌더
  Widget _buildDropdownField(
    String hintText,
    Color borderColor,
    Color hintColor,
  ) {
    return DropdownButtonFormField<String>(
      icon: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey.shade400,
          size: 37,
        ),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.2),
        ),
      ),
      hint: Text(
        hintText,
        style: TextStyle(color: hintColor, fontSize: 17, fontWeight: .w500),
      ),
      items: const [], // 실제 구현 시 항목 추가: items: ['전체 공개', '비공개'].map(...)
      onChanged: (value) {
        // 선택 로직 구현
      },
    );
  }
}
