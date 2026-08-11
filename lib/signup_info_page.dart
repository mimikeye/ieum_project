import 'package:flutter/material.dart';

class SignupInfoPage extends StatefulWidget {
  const SignupInfoPage({super.key});

  @override
  State<SignupInfoPage> createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormFilled {
    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _clearName() {
    _nameController.clear();
  }

  void _clearEmail() {
    _emailController.clear();
  }

  void _onConfirm() {
    if (!_isFormFilled) return;

    // 다음 단계인 signup_page.dart로
    // 이름과 이메일을 전달하는 부분은
    // signup_page.dart 구조에 맞춰 이후 연결합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────
            // 상단 헤더
            // ─────────────────────────
            SizedBox(
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 36,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),

                  const Text(
                    '회원가입',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),

            // ─────────────────────────
            // 본문
            // ─────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 47),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 61),

                    const Text(
                      '정보를\n입력해주세요',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: Color(0xFF000000),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 이름 입력창
                    _buildTextField(
                      controller: _nameController,
                      label: '이름',
                      hintText: '이름 입력',
                      onClear: _clearName,
                    ),

                    const SizedBox(height: 13),

                    // 이메일 입력창
                    _buildTextField(
                      controller: _emailController,
                      label: '이메일',
                      hintText: '이메일 입력',
                      keyboardType: TextInputType.emailAddress,
                      onClear: _clearEmail,
                    ),

                    const Spacer(),

                    // 확인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 41,
                      child: ElevatedButton(
                        onPressed: _isFormFilled ? _onConfirm : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: _isFormFilled
                              ? const Color(0xFFEAF8CB)
                              : const Color(0xFFD9D9D9),
                          disabledBackgroundColor:
                              const Color(0xFFD9D9D9),
                          foregroundColor: const Color(0xFF000000),
                          disabledForegroundColor:
                              const Color(0xFF000000),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 139),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required VoidCallback onClear,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF000000),
        ),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          hintText: hintText,

          labelStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: Color(0xFFC5C5C5),
          ),

          hintStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFFC5C5C5),
          ),

          contentPadding: const EdgeInsets.fromLTRB(
            13,
            9,
            35,
            3,
          ),

          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(
                    Icons.cancel,
                    size: 13,
                    color: Color(0xFF767676),
                  ),
                )
              : null,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(23),
            borderSide: const BorderSide(
              color: Color(0xFFC5C5C5),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(23),
            borderSide: const BorderSide(
              color: Color(0xFF000000),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}