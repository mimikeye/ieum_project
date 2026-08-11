import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  final String nickname;
  final String email;

  const SignupPage({
    super.key,
    required this.nickname,
    required this.email,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // ============================================================
  // Firebase
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 입력 컨트롤러 / 포커스 노드
  // ============================================================

  final TextEditingController _idController = TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // ============================================================
  // 상태
  // ============================================================

  bool _isLoading = false;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _idFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  // ============================================================
  // 회원가입
  // ============================================================

  Future<void> _signup() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    // 아이디 입력 확인
    if (id.isEmpty) {
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

    // TODO:
    // 아이디 → 내부용 이메일 변환 ('$id@ieum-users.com')
    // + Firestore에 nickname / 실제 email 저장하는 로직은
    // 다음 단계에서 추가 예정.

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: '$id@ieum-users.com',
        password: password,
      );

      final uid = credential.user?.uid;

      if (uid == null) {
        _showMessage('회원가입 중 오류가 발생했습니다.');
        return;
      }

      // Firestore에 부가 정보 저장
      try {
        await _firestore.collection('users').doc(uid).set({
          'username': id,
          'nickname': widget.nickname,
          'email': widget.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Firestore 저장 실패 시, 방금 만든 계정을 롤백
        await credential.user?.delete();

        _showMessage('회원가입 중 오류가 발생했습니다. 다시 시도해주세요.');
        return;
      }

      if (!mounted) return;

      _showMessage('회원가입이 완료되었습니다.');

      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String message = '회원가입에 실패했습니다.';

      if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 아이디입니다.';
      } else if (e.code == 'invalid-email') {
        message = '아이디 형식이 올바르지 않습니다.';
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
  // 종료
  // ============================================================

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();

    _idFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // 화면
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isFilled = _idController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;

    final idActive =
        _idFocusNode.hasFocus || _idController.text.isNotEmpty;

    final passwordActive = _passwordFocusNode.hasFocus ||
        _passwordController.text.isNotEmpty;

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
                '아이디와 비밀번호를\n만들어주세요',
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
            // 아이디
            // ==================================================

            Center(
              child: Container(
                width: 338,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: idActive
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
                        controller: _idController,
                        focusNode: _idFocusNode,
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
                      top: idActive ? 9.31 : 19,
                      child: IgnorePointer(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: idActive ? 12 : 18,
                            fontWeight: FontWeight.w500,
                            color: idActive
                                ? Colors.black
                                : const Color(0xFFC5C5C5),
                          ),
                          child: const Text('아이디'),
                        ),
                      ),
                    ),

                    // 입력 내용 전체 삭제 (X)
                    if (_idController.text.isNotEmpty)
                      Positioned(
                        right: 18,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _idController.clear();

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
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // 비밀번호
            // ==================================================

            Center(
              child: Container(
                width: 338,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: passwordActive
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(
                            left: 19,
                            right: 76,
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
                      top: passwordActive ? 9.31 : 19,
                      child: IgnorePointer(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: passwordActive ? 12 : 18,
                            fontWeight: FontWeight.w500,
                            color: passwordActive
                                ? Colors.black
                                : const Color(0xFFC5C5C5),
                          ),
                          child: const Text('비밀번호'),
                        ),
                      ),
                    ),

                    // 비밀번호 값이 있을 때만: 눈 아이콘 + X 아이콘
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
                  onPressed: _isLoading ? null : _signup,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading
                        ? const Color(0xFFD9D9D9)
                        : isFilled
                            ? const Color(0xFFEAF8CB)
                            : const Color(0xFFD9D9D9),

                    foregroundColor: Colors.black,

                    elevation: 0,

                    padding: EdgeInsets.zero,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
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
