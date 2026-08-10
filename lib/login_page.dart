import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _saveId = false;
  bool _autoLogin = false;
  bool _isLoading = false;

  // ==========================================
  // 이메일 / 비밀번호 로그인
  // ==========================================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('로그인되었습니다.');

      // TODO:
      // 로그인 성공 후 메인 페이지로 이동
      //
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const HomePage(),
      //   ),
      // );
    } on FirebaseAuthException catch (e) {
      String message = '로그인에 실패했습니다.';

      if (e.code == 'user-not-found') {
        message = '등록되지 않은 아이디입니다.';
      } else if (e.code == 'wrong-password') {
        message = '비밀번호가 올바르지 않습니다.';
      } else if (e.code == 'invalid-credential') {
        message = '아이디 또는 비밀번호가 올바르지 않습니다.';
      } else if (e.code == 'invalid-email') {
        message = '올바른 이메일 형식을 입력해주세요.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('로그인 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // Google 로그인
  // ==========================================
  Future<void> _googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (!mounted) return;

      _showMessage('Google 로그인되었습니다.');

      // TODO:
      // 로그인 성공 후 메인 페이지로 이동
    } catch (e) {
      _showMessage('Google 로그인에 실패했습니다.');
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

    super.dispose();
  }

  // ==========================================
  // 로그인 화면
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),

            child: Column(
              children: [

                // ==================================
                // 로고
                // ==================================
                const SizedBox(height: 95),

                Container(
                  width: 286,
                  height: 161,
                  color: const Color(0xFFD9D9D9),

                  child: const Center(
                    child: Text(
                      'LOGO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 62),

                // ==================================
                // 아이디
                // ==================================
                SizedBox(
                  width: 338,
                  height: 55,
                  child: TextField(
                    controller: _emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration:
                        _inputDecoration('아이디'),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================
                // 비밀번호
                // ==================================
                SizedBox(
                  width: 338,
                  height: 55,
                  child: TextField(
                    controller: _passwordController,

                    obscureText: true,

                    decoration:
                        _inputDecoration('비밀번호'),
                  ),
                ),

                const SizedBox(height: 5),

                // ==================================
                // 아이디 저장 / 자동 로그인
                // ==================================
                Row(
                  children: [

                    Checkbox(
                      value: _saveId,

                      onChanged: (value) {
                        setState(() {
                          _saveId = value ?? false;
                        });
                      },

                      side: const BorderSide(
                        color: Color(0xFF7A7A7A),
                        width: 1.0,
                      ),

                      visualDensity:
                          VisualDensity.compact,

                      materialTapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                    ),

                    const Text(
                      '아이디 저장',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(width: 22),

                    Checkbox(
                      value: _autoLogin,

                      onChanged: (value) {
                        setState(() {
                          _autoLogin =
                              value ?? false;
                        });
                      },

                      side: const BorderSide(
                        color: Color(0xFF7A7A7A),
                        width: 1.0,
                      ),

                      visualDensity:
                          VisualDensity.compact,

                      materialTapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                    ),

                    const Text(
                      '자동 로그인',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // ==================================
                // 로그인 버튼
                // ==================================
                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _login,

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
                            BorderRadius.circular(50),
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
                            '로그인',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 65),

                // ==================================
                // 아이디 찾기 / 비밀번호 찾기
                // ==================================
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    TextButton(
                      onPressed: () {
                        // TODO: 아이디 찾기
                      },

                      style:
                          TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,

                        tapTargetSize:
                            MaterialTapTargetSize
                                .shrinkWrap,
                      ),

                      child: const Text(
                        '아이디 찾기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const Text(
                      ' | ',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        // TODO: 비밀번호 찾기
                      },

                      style:
                          TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,

                        tapTargetSize:
                            MaterialTapTargetSize
                                .shrinkWrap,
                      ),

                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================
                // Google 로그인
                // ==================================
                SizedBox(
                  width: double.infinity,
                  height: 44,

                  child: OutlinedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _googleLogin,

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.black,

                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),

                    child: const Text(
                      'Google로 로그인',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================
                // 회원가입
                // ==================================
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SignupPage(),
                      ),
                    );
                  },

                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
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
        fontSize: 20,
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13.5,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(50),

        borderSide: const BorderSide(
          color: Color(0xFFD0D0D0),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(50),

        borderSide: const BorderSide(
          color: Color(0xFFD0D0D0),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(50),

        borderSide: const BorderSide(
          color: Color(0xFF999999),
        ),
      ),
    );
  }
}