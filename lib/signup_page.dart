import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // ============================================================
  // Firebase
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 입력 컨트롤러
  // ============================================================

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  // ============================================================
  // 상태
  // ============================================================

  bool _isLoading = false;

  bool _obscurePassword = true;

  // ============================================================
  // 회원가입
  // ============================================================

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 아이디 입력 확인
    if (email.isEmpty) {
      _showMessage('아이디를 입력해주세요.');
      return;
    }

    // 비밀번호 입력 확인
    if (password.isEmpty) {
      _showMessage('비밀번호를 입력해주세요.');
      return;
    }

    // 비밀번호 길이 확인
    if (password.length < 6) {
      _showMessage('비밀번호는 6자 이상 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('회원가입이 완료되었습니다.');

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '회원가입에 실패했습니다.';

      if (e.code == 'email-already-in-use') {
        message = '이미 가입된 아이디입니다.';
      } else if (e.code == 'invalid-email') {
        message = '올바른 아이디 형식을 입력해주세요.';
      } else if (e.code == 'weak-password') {
        message = '비밀번호가 너무 간단합니다.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('회원가입 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
  // 입력창 디자인
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      // 작은 위쪽 라벨
      labelStyle: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 9,
      ),

      // 입력 전 표시되는 글씨
      hintStyle: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 14,
      ),

      // 입력창에 글자가 들어가면
      // label이 위쪽으로 올라감
      floatingLabelBehavior:
          FloatingLabelBehavior.always,

      // 입력창 내부 여백
      contentPadding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 17,
        bottom: 8,
      ),

      suffixIcon: suffixIcon,

      // 기본 테두리
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),

        borderSide: const BorderSide(
          color: Color(0xFFD0D0D0),
          width: 1,
        ),
      ),

      // 입력하지 않았을 때
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),

        borderSide: const BorderSide(
          color: Color(0xFFD0D0D0),
          width: 1,
        ),
      ),

      // 입력 중일 때
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),

        borderSide: const BorderSide(
          color: Color(0xFF555555),
          width: 1,
        ),
      ),
    );
  }

  // ============================================================
  // 화면
  // ============================================================

  @override
  Widget build(BuildContext context) {
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

                  // 뒤로가기
                  Positioned(
                    left: 16,
                    top: 14,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 19,
                      ),
                    ),
                  ),

                  // 회원가입
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 15,
                    child: Center(
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // 상단 ↔ 제목
            // ==================================================

            const SizedBox(
              height: 70,
            ),

            // ==================================================
            // 제목
            // ==================================================

            const SizedBox(
              width: 338,
              child: Text(
                '아이디와 비밀번호를\n만들어주세요',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),

            // ==================================================
            // 제목 ↔ 아이디
            // ==================================================

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // 아이디
            // 338 × 55
            // ==================================================

            SizedBox(
              width: 338,
              height: 55,
              child: TextField(
                controller: _emailController,

                keyboardType:
                    TextInputType.emailAddress,

                onChanged: (_) {
                  setState(() {});
                },

                decoration: _inputDecoration(
                  label: '아이디',
                  hint: '아이디 입력',

                  suffixIcon:
                      _emailController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _emailController.clear();

                                setState(() {});
                              },

                              icon: const Icon(
                                Icons.cancel,
                                size: 15,
                                color: Color(0xFF888888),
                              ),
                            )
                          : null,
                ),
              ),
            ),

            // ==================================================
            // 아이디 ↔ 비밀번호
            // ==================================================

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // 비밀번호
            // 338 × 55
            // ==================================================

            SizedBox(
              width: 338,
              height: 55,
              child: TextField(
                controller:
                    _passwordController,

                obscureText:
                    _obscurePassword,

                onChanged: (_) {
                  setState(() {});
                },

                decoration: _inputDecoration(
                  label: '비밀번호',
                  hint: '비밀번호 입력',

                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // 비밀번호 보기
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },

                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,

                          size: 17,

                          color:
                              const Color(0xFFBDBDBD),
                        ),
                      ),

                      // 입력 내용 삭제
                      if (_passwordController
                          .text
                          .isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _passwordController.clear();

                            setState(() {});
                          },

                          icon: const Icon(
                            Icons.cancel,
                            size: 15,
                            color: Color(0xFF888888),
                          ),
                        ),

                      const SizedBox(
                        width: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // 비밀번호 ↔ 확인 버튼
            // ==================================================

            const SizedBox(
              height: 188,
            ),

            // ==================================================
            // 확인 버튼
            // 338 × 44
            // ==================================================

            SizedBox(
              width: 338,
              height: 44,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _signup,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _emailController
                                  .text
                                  .isNotEmpty &&
                              _passwordController
                                  .text
                                  .isNotEmpty
                          ? const Color(0xFFEAF8CB)
                          : const Color(0xFFD9D9D9),

                  disabledBackgroundColor:
                      const Color(0xFFD9D9D9),

                  foregroundColor: Colors.black,

                  disabledForegroundColor:
                      Colors.black,

                  elevation: 0,

                  padding: EdgeInsets.zero,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 종료
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}