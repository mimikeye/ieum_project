import 'package:flutter/material.dart';
import 'signup_page.dart';

class SignupInfoPage extends StatefulWidget {
  const SignupInfoPage({super.key});

  @override
  State<SignupInfoPage> createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {
  // ============================================================
  // 입력 컨트롤러 / 포커스 노드
  // ============================================================

  final TextEditingController _nicknameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final FocusNode _nicknameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _nicknameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
  }

  // ============================================================
  // 다음 단계로
  // ============================================================

  void _next() {
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();

    if (nickname.isEmpty) {
      _showMessage('닉네임을 입력해주세요.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('이메일을 입력해주세요.');
      return;
    }

    // 아주 간단한 이메일 형식 체크
    final emailReg = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');

    if (!emailReg.hasMatch(email)) {
      _showMessage('올바른 이메일 형식을 입력해주세요.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupPage(
          nickname: nickname,
          email: email,
        ),
      ),
    );
  }

  // ============================================================
  // 메시지
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // 종료
  // ============================================================

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();

    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // 힌트 ↔ 라벨 입력창 (공통)
  // ============================================================

  Widget _floatingField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    TextInputType? keyboardType,
  }) {
    final isActive = focusNode.hasFocus || controller.text.isNotEmpty;

    return Container(
      width: 338,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.black : const Color(0xFFC5C5C5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [

          // 실제 입력 필드
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.only(
                  left: 19,
                  right: 46,
                  top: 28,
                  bottom: 10,
                ),
              ),
            ),
          ),

          // 힌트 → 라벨로 움직이는 텍스트
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            left: 19,
            top: isActive ? 9.31 : 19,
            child: IgnorePointer(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: isActive ? 12 : 18,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? Color(0xFFC5C5C5)
                      : const Color(0xFFC5C5C5),
                ),
                child: Text(label),
              ),
            ),
          ),

          // 입력 내용 전체 삭제 (X)
          if (controller.text.isNotEmpty)
            Positioned(
              right: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    controller.clear();

                    setState(() {});
                  },
                  child: const Icon(
                    Icons.cancel,
                    size: 18,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 화면
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isFilled = _nicknameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // 상단
            // ==================================================

            SizedBox(
              height: 52,
              child: Stack(
                children: [

                  Positioned(
                    left: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: 
                        Image.asset(
                          'assets/images/back_arrow.png',
                          width: 22.35,
                          height: 19.3,
                        )
                    ),
                  ),

                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 15,
                    child: Center(
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 59,
            ),

            // ==================================================
            // 제목
            // ==================================================

            const SizedBox(
              width: 338,
              child: Text(
                '정보를\n입력해주세요',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 27.21,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // 닉네임
            // ==================================================

            Center(
              child: _floatingField(
                controller: _nicknameController,
                focusNode: _nicknameFocusNode,
                label: '이름',
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // 이메일
            // ==================================================

            Center(
              child: _floatingField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: '이메일',
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            const SizedBox(
              height: 236,
            ),

            // ==================================================
            // 확인 버튼
            // ==================================================

            Center(
              child: SizedBox(
                width: 338,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFilled
                        ? const Color(0xFFEAF8CB)
                        : const Color(0xFFD9D9D9),

                    foregroundColor: Colors.black,

                    elevation: 0,

                    padding: EdgeInsets.zero,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
