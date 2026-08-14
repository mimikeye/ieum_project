import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ==========================================
  // Firebase
  // ==========================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // 입력 컨트롤러
  // ==========================================

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // ==========================================
  // 상태
  // ==========================================

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  bool _obscurePassword = true;

  bool _saveId = false;

  bool _autoLogin = false;

  // ==========================================
  // 로그인
  // ==========================================

  Future<void> _login() async {
    final id = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      _showMessage('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: '$id@ieum-users.com',
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RootScreen(),
        ),
      );

      _showMessage('로그인되었습니다.');

      // TODO:
      // 로그인 성공 후 이동할 페이지를 여기에 넣으세요.
      //
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const MainPage(),
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
        message = '올바른 아이디를 입력해주세요.';
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
  // 메시지
  // ==========================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================
  // 아이디 찾기
  // ==========================================

  void _findId() {
    _showMessage('아이디 찾기 기능은 준비 중입니다.');
  }

  // ==========================================
  // 비밀번호 찾기
  // ==========================================

  void _findPassword() {
    _showMessage('비밀번호 찾기 기능은 준비 중입니다.');
  }

  // ==========================================
  // 회원가입
  // ==========================================

  void _signupInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupInfoPage(),
      ),
    );
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

      final userCredential =
          await _auth.signInWithCredential(credential);

      final isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        final uid = userCredential.user?.uid;

        if (uid != null) {
          await _firestore.collection('users').doc(uid).set({
            'username': null,
            'nickname': googleUser.displayName ?? '',
            'email': googleUser.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

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
  // Dispose
  // ==========================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  // ==========================================
  // 화면
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================
      // Body
      // ========================================

      body: SafeArea(
        child: Column(
          children: [

            // ====================================
            // 위쪽 빈 공간
            //
            // 이 숫자로 입력창의 세로 위치를 조절
            // ====================================

            const SizedBox(
              height: 323.12,
            ),

            // ====================================
            // 아이디 입력창
            // ====================================

            Center(
              child: Container(
                width: 338,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (_emailFocusNode.hasFocus ||
                            _emailController.text.isNotEmpty)
                        ? Colors.black
                        : const Color(0xFFC5C5C5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Stack(
                  children: [

                    // 실제 입력 필드
                    Positioned.fill(
                      child: TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
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
                            bottom: 14,
                          ),
                        ),
                      ),
                    ),

                    // 힌트 → 라벨로 움직이는 텍스트
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      left: 19,
                      top: (_emailFocusNode.hasFocus ||
                              _emailController.text.isNotEmpty)
                          ? 9.31
                          : 19,
                      child: IgnorePointer(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: (_emailFocusNode.hasFocus ||
                                    _emailController.text.isNotEmpty)
                                ? 12
                                : 18,
                            fontWeight: FontWeight.w500,
                            color: (_emailFocusNode.hasFocus ||
                                    _emailController.text.isNotEmpty)
                                ? Color(0xFFC5C5C5)
                                : const Color(0xFFC5C5C5),
                          ),
                          child: const Text('아이디'),
                        ),
                      ),
                    ),

                    if (_emailController.text.isNotEmpty)
                      Positioned(
                        right: 18,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _emailController.clear();

                              setState(() {});
                            },
                            child: const Icon(
                              Icons.cancel,
                              size: 18,
                              color: Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            ),

            // ====================================
            // 입력창 사이 간격
            // ====================================

            const SizedBox(
              height: 18,
            ),

            // ====================================
            // 비밀번호 입력창
            // ====================================

            Center(
              child: Container(
                width: 338,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (_passwordFocusNode.hasFocus ||
                            _passwordController.text.isNotEmpty)
                        ? Colors.black
                        : const Color(0xFFC5C5C5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Stack(
                  children: [

                    // 실제 입력 필드
                    Positioned.fill(
                      child: TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          setState(() {});
                        },
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.only(
                            left: 19,
                            right: 76,
                            top: 28,
                            bottom: 14,
                          ),
                        ),
                      ),
                    ),

                    // 힌트 → 라벨로 움직이는 텍스트
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      left: 19,
                      top: (_passwordFocusNode.hasFocus ||
                              _passwordController.text.isNotEmpty)
                          ? 9.31
                          : 19,
                      child: IgnorePointer(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: (_passwordFocusNode.hasFocus ||
                                    _passwordController.text.isNotEmpty)
                                ? 12
                                : 18,
                            fontWeight: FontWeight.w500,
                            color: (_passwordFocusNode.hasFocus ||
                                    _passwordController.text.isNotEmpty)
                                ? Color(0xFFC5C5C5)
                                : const Color(0xFFC5C5C5),
                          ),
                          child: const Text('비밀번호'),
                        ),
                      ),
                    ),
                    if (_passwordController.text.isNotEmpty) ...[

                      // 입력 내용 전체 삭제 (X) — 오른쪽 끝에서 18px
                      Positioned(
                        right: 18,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _passwordController.clear();

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

                      // 비밀번호 보기/숨기기 — X 아이콘에서 13px 더 왼쪽
                      Positioned(
                        right: 18 + 18 + 13,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ====================================
            // 체크박스 영역
            // ====================================

            const SizedBox(
              height: 17,
            ),

            Center(
              child: SizedBox(
                width: 338,
                height: 30,
                child: Row(
                  children: [

                    // ------------------------------
                    // 아이디 저장
                    // ------------------------------

                    SizedBox(
                      width: 16,
                      height: 16,
                        child: Transform.scale(
                          scale: 16/18,
                          child: Checkbox(
                          value: _saveId,

                          onChanged: (value) {
                            setState(() {
                              _saveId =
                                  value ?? false;
                            });
                          },

                          side: const BorderSide(
                            color: Color(0xFF7A7A7A),
                            width: 1.0,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(2),
                          ),

                          activeColor:
                              const Color(0xFFEAF8CB),
                          checkColor: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    const Text(
                      '아이디 저장',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),

                    // ------------------------------
                    // 두 체크박스 사이
                    // ------------------------------

                    const SizedBox(
                      width: 27,
                    ),

                    // ------------------------------
                    // 자동 로그인
                    // ------------------------------

                    SizedBox(
                      width: 16,
                      height: 16,
                      child: Transform.scale(
                          scale: 16/18,
                          child: Checkbox(
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

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(2),
                          ),

                          activeColor:
                              const Color(0xFFEAF8CB),
                          checkColor: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    const Text(
                      '자동 로그인',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====================================
            // 로그인 버튼
            // ====================================

            const SizedBox(
              height: 28,
            ),

            Center(
              child: SizedBox(
                width: 338,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _login,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                      _isLoading
                          ? const Color(0xFFD9D9D9)
                          : _emailController.text.trim().isNotEmpty &&
                                  _passwordController.text.trim().isNotEmpty
                              ? const Color(0xFFEAF8CB)
                              : const Color(0xFFD9D9D9),

                    foregroundColor:
                        Colors.black,

                    elevation: 0,

                    padding:
                        EdgeInsets.zero,

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
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),

            // ====================================
            // 아이디 찾기 / 비밀번호 찾기 /
            // 회원가입
            // ====================================

            const SizedBox(
              height: 45.71,
            ),

            Center(
              child: SizedBox(
                width: 338,
                height: 22,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    GestureDetector(
                      onTap: _findId,

                      child: const Text(
                        '아이디 찾기',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const Text(
                      ' | ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),

                    GestureDetector(
                      onTap: _findPassword,

                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const Text(
                      ' | ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),

                    GestureDetector(
                      onTap: _signupInfo,

                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====================================
            // Google 로그인 버튼
            // ====================================

            const SizedBox(
              height: 65.38,
            ),

            Center(
              child: SizedBox(
                width: 338,
                height: 54,
                child: OutlinedButton(
                  onPressed: _googleLogin,

                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        Colors.white,

                    padding:
                        EdgeInsets.zero,

                    side: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(28),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      // ----------------------------
                      // Google 아이콘
                      // ----------------------------

                      Image.asset(
                        'assets/images/google_icon.png',

                        width: 22,
                        height: 22,

                        fit: BoxFit.contain,
                      ),

                      // ----------------------------
                      // 아이콘과 글자 사이
                      // ----------------------------

                      const SizedBox(
                        width: 12,
                      ),

                      const Text(
                        '구글로 계속하기',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
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
}