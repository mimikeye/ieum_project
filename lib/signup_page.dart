import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _passwordCheckController =
      TextEditingController();

  bool _isLoading = false;

  // ==========================================
  // 회원가입
  // ==========================================
  Future<void> _signup() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text.trim();

    final passwordCheck =
        _passwordCheckController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        passwordCheck.isEmpty) {
      _showMessage('모든 항목을 입력해주세요.');
      return;
    }

    if (password != passwordCheck) {
      _showMessage('비밀번호가 일치하지 않습니다.');
      return;
    }

    if (password.length < 6) {
      _showMessage(
        '비밀번호는 6자 이상 입력해주세요.',
      );
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
      String message =
          '회원가입에 실패했습니다.';

      if (e.code ==
          'email-already-in-use') {
        message =
            '이미 가입된 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        message =
            '올바른 이메일 형식을 입력해주세요.';
      } else if (e.code == 'weak-password') {
        message =
            '비밀번호가 너무 간단합니다.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage(
        '회원가입 중 오류가 발생했습니다.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // 메시지
  // ==========================================
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();

    super.dispose();
  }

  // ==========================================
  // 회원가입 화면
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================
      // 상단 AppBar
      // ========================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================
      // Body
      // ========================================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 70,
            ),

            child: Column(
              children: [

                const SizedBox(height: 80),

                // ==================================
                // 아이디
                // ==================================
                TextField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  decoration:
                      _inputDecoration(
                    '아이디',
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================
                // 비밀번호
                // ==================================
                TextField(
                  controller:
                      _passwordController,

                  obscureText: true,

                  decoration:
                      _inputDecoration(
                    '비밀번호',
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================
                // 비밀번호 확인
                // ==================================
                TextField(
                  controller:
                      _passwordCheckController,

                  obscureText: true,

                  decoration:
                      _inputDecoration(
                    '비밀번호 확인',
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================
                // 회원가입 버튼
                // ==================================
                SizedBox(
                  width: double.infinity,
                  height: 44,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _signup,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFD9D9D9),

                      foregroundColor:
                          Colors.black,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 입력창 디자인
  // ==========================================
  InputDecoration _inputDecoration(
    String hint,
  ) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 16,
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Color(0xFFD0D0D0),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Color(0xFFD0D0D0),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Color(0xFF999999),
        ),
      ),
    );
  }
}