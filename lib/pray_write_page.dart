import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'category_selection.dart'; // 카테고리 선택 시트 import
import 'package:flutter/cupertino.dart';
import 'prayer_note_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'equalizer_icon.dart';
import 'dart:math';

class PrayerWriteScreen extends StatefulWidget {
  final String? noteId;
  final Map<String, dynamic>? initialNote;

  const PrayerWriteScreen({
    super.key,
    this.noteId,
    this.initialNote,
  });

  @override
  State<PrayerWriteScreen> createState() => _PrayerWriteScreenState();
}

class _PrayerWriteScreenState extends State<PrayerWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  final double _lineHeight = 36.0; // 본문 줄 간격
  final double _titleLineHeight = 25.0; // 제목 글자들의 촘촘한 줄 간격 (19 * 1.3 ≈ 25px)
  final double _baseTitleHeight = 50.0; // 제목 1줄일 때의 기본 박스 높이

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final Random _random = Random();

  final List<String> _musicList = [
    'audio/pray_music1.mp3',
    'audio/pray_music2.mp3',
    'audio/pray_music3.mp3',
    'audio/pray_music4.mp3',
    'audio/pray_music5.mp3',
    'audio/pray_music6.mp3',
    'audio/pray_music7.mp3',
    'audio/pray_music8.mp3',
    'audio/pray_music9.mp3',
  ];

  int? _currentMusicIndex;
  bool _isMusicPlaying = false;

  List<String> _selectedCategories = [];
  int _titleLines = 1;
  bool _hasText = false;
  bool _isSaved = false;
  String _lastTitle = "";
  String _lastBody = "";

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  Future<void> _updateDailyActivity() async {
    final username = await UserService.getCurrentUsername();

    if (username == null) {
      throw Exception('로그인한 사용자의 username을 찾을 수 없습니다.');
    }

    final today = DateTime.now();
    final date = _formatDate(today);

    final activityRef = FirebaseFirestore.instance
        .collection('dailyActivities')
        .doc(username)
        .collection('dates')
        .doc(date);

    await activityRef.set(
      {
        'wrotePrayer': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '저장하지 않고 나가시겠습니까?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        text: '예',
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogButton(
                        text: '취소',
                        onTap: () => Navigator.pop(context, false),
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

  void _updateButtonState() {
    final currentTitle = _titleController.text;
    final currentBody = _bodyController.text;

    // 💡 [핵심 방어코드] 글자 내용이 이전과 완전히 똑같다면? (단순 한글 조합 완료나 키보드 내림 현상)
    // 헛수고하지 말고 여기서 함수를 멈춥니다!
    if (currentTitle == _lastTitle && currentBody == _lastBody) return;

    // 글자가 진짜로 바뀌었다면 이전 텍스트를 최신화해 줍니다.
    _lastTitle = currentTitle;
    _lastBody = currentBody;

    final bool currentHasText =
        currentTitle.trim().isNotEmpty || currentBody.trim().isNotEmpty;

    setState(() {
      _hasText = currentHasText;
      _isSaved = false; // 글이 진짜로 수정되었을 때만 '저장 완료' 상태를 풉니다.
    });
  }

  Future<void> _savePrayer() async {
    if (!_hasText || _isSaved) return;

    FocusScope.of(context).unfocus();

    try {
      // ① 기도문 원본 저장
      String? savedNoteId;

      if (widget.noteId == null) {
        // 새 기도문 작성
        savedNoteId = await PrayerNoteService.savePrayerNote(
          title: _titleController.text,
          content: _bodyController.text,
          categories: _selectedCategories,
          image: _selectedImage != null
              ? File(_selectedImage!.path)
              : null,
        );
      } else {
        // 기존 기도문 수정
        await PrayerNoteService.updatePrayerNote(
          noteId: widget.noteId!,
          title: _titleController.text,
          content: _bodyController.text,
          categories: _selectedCategories,
        );

        // 수정한 기존 문서의 ID
        savedNoteId = widget.noteId;
      }

      if (savedNoteId == null) {
        throw Exception('기도문 저장에 실패했습니다.');
      }

      // ② 오늘 활동 기록
      await _updateDailyActivity();

      if (!mounted) return;

      await _audioPlayer.stop();

      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '저장되었습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          ),
          backgroundColor: const Color.fromRGBO(85, 85, 85, 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(
            left: 100,
            right: 100,
            bottom: 40,
          ),
          duration: const Duration(seconds: 2),
          elevation: 0,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '저장 중 오류가 발생했습니다.',
            style: const TextStyle(
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      );

      debugPrint('기도문 저장 오류: $e');
    }
  }

  

  @override
  void initState() {
    super.initState();

    if (widget.initialNote != null) {
      _titleController.text =
          widget.initialNote!['title'] ?? '';

      _bodyController.text =
          widget.initialNote!['content'] ?? '';

      _selectedCategories =
          List<String>.from(
            widget.initialNote!['categories'] ?? [],
          );

      _hasText =
          _titleController.text.trim().isNotEmpty ||
          _bodyController.text.trim().isNotEmpty;

      _lastTitle = _titleController.text;
      _lastBody = _bodyController.text;
    }
    // (기존) 제목 줄 수 계산 리스너
    _titleController.addListener(() {
      int lines = '\n'.allMatches(_titleController.text).length + 1;
      if (lines != _titleLines) {
        setState(() {
          _titleLines = lines;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isMusicPlaying) {
        _playRandomMusic();
      }
    });

    // 💡 [새로 추가] 글자 입력 시 버튼 색상을 바꾸기 위해 리스너 부착!
    _titleController.addListener(_updateButtonState);
    _bodyController.addListener(_updateButtonState);

    _playRandomMusic();
  }

  Future<void> _playRandomMusic() async {
    try {
      int newIndex;

      do {
        newIndex = _random.nextInt(_musicList.length);
      } while (
          _musicList.length > 1 &&
          newIndex == _currentMusicIndex);

      _currentMusicIndex = newIndex;

      await _audioPlayer.play(
        AssetSource(_musicList[newIndex]),
      );

      if (!mounted) return;

      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      debugPrint('음악 재생 오류: $e');
    }
  }

  Future<void> _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();

      if (!mounted) return;

      setState(() {
        _isMusicPlaying = false;
      });
    } else {
      if (_currentMusicIndex == null) {
        await _playRandomMusic();
      } else {
        await _audioPlayer.resume();

        if (!mounted) return;

        setState(() {
          _isMusicPlaying = true;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _showCategorySelection() async {
    final List<String>? result = await showCategorySelectionSheet(
      context: context,
      initialSelectedCategories: _selectedCategories,
    );

    if (result != null) {
      setState(() {
        _selectedCategories = result;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ), // 👇 이 숫자를 키울수록 버튼이 오른쪽으로 밀려납니다!
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () async {
              if (_isSaved) {
                // 기존 기도문을 수정한 경우
                if (widget.noteId != null) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  // 새 기도문을 작성한 경우
                  Navigator.of(context).pop();
                }

                return;
              }

              if (!_hasText &&
                  _selectedImage == null &&
                  _selectedCategories.isEmpty) {
                Navigator.of(context).pop();
                return;
              }

              final shouldExit = await _showConfirmDialog();

              if (shouldExit && context.mounted) {
                await _audioPlayer.stop();
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: const Text(
          '이음 기도문 작성',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
          ),
        ),
        centerTitle: false,
        titleSpacing: 4,
        actions: [
          EqualizerIcon(
            isPlaying: _isMusicPlaying,
            onTap: _toggleMusic,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _hasText ? _savePrayer : null,
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _hasText
                    ? const Color.fromRGBO(234, 248, 203, 1)
                    : const Color.fromRGBO(224, 224, 224, 1),
                shape: BoxShape.circle,
              ),
              // 💡 저장되었으면 종이비행기, 아니면 체크 마크를 보여줍니다.
              child: _isSaved
                  ? Padding(
                      padding: EdgeInsets.only(left: 1.0),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    )
                  : Padding(
                    padding: const EdgeInsets.only(right:1),
                    child: Icon(CupertinoIcons.checkmark_alt, color: Colors.white,size: 28),
                  ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 247, 247, 1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double areaHeight = constraints.maxHeight;

                        // 기본 제목 영역의 높이
                        final double currentTitleHeight =
                            _baseTitleHeight +
                            (_titleLines - 1) * _titleLineHeight;

                        // 카테고리가 선택되었을 때 추가로 필요한 높이 공간 설정
                        final double categoryAreaHeight =
                            _selectedCategories.isNotEmpty ? 40.0 : 0.0;

                        // 💡 [새로 추가된 부분] 사진이 차지할 높이와 본문이 늘어나야 할 최소 높이 계산
                        // 사진 200px + 아래 여백 20px = 220px
                        final double imageAreaHeight = _selectedImage != null
                            ? 220.0
                            : 0.0;
                        final double minBodyHeight =
                            areaHeight -
                            currentTitleHeight -
                            categoryAreaHeight -
                            imageAreaHeight;

                        return Stack(
                          children: [
                            // 배경 밑줄과 글자가 함께 스크롤되도록 구조 변경
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  // 글이 짧아도 전체 화면에 줄이 그어지도록 최소 높이를 areaHeight로 설정
                                  minHeight: areaHeight,
                                ),
                                child: Stack(
                                  children: [
                                    // 💡 [수정됨] 1. 배경 선 그리기: 카테고리 유무에 따라 굵은 선의 위치를 동적으로 조절
                                    // 💡 [수정됨] 1. 배경 선 그리기: Positioned.fill을 사용해 글 길이에 맞춰 도화지를 무한히 늘립니다.
                                    Positioned.fill(
                                      child: CustomPaint(
                                        // 💡 고정된 size 옵션을 아예 삭제합니다!
                                        painter: LinedPaperPainter(
                                          lineHeight: _lineHeight,
                                          titleHeight:
                                              currentTitleHeight +
                                              categoryAreaHeight,
                                        ),
                                      ),
                                    ),

                                    // 제목, 카테고리, 본문 입력창 Column
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // 1. 제목 입력창
                                        SizedBox(
                                          height: currentTitleHeight,
                                          child: TextField(
                                            controller: _titleController,
                                            maxLines: null,
                                            cursorColor: Colors.black,
                                            cursorHeight: 20.0,
                                            style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                              fontFamily: 'Pretendard',
                                              height: 1.2,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: '제목',
                                              hintStyle: TextStyle(
                                                color: Color.fromRGBO(
                                                  224,
                                                  224,
                                                  224,
                                                  1,
                                                ),
                                                fontWeight: FontWeight.w400,
                                                height: 1.3,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 14,
                                                bottom: 10,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 💡 [수정됨] 2. 카테고리 태그를 제목 밑으로 이동 및 가로 스크롤 적용
                                        if (_selectedCategories.isNotEmpty)
                                          Container(
                                            height: 40.0, // 카테고리 영역 고정 높이
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              bottom: 8,
                                            ),
                                            alignment: Alignment
                                                .centerLeft, // 태그를 왼쪽 정렬
                                            child: SingleChildScrollView(
                                              scrollDirection:
                                                  Axis.horizontal, // 가로 스크롤
                                              // ... 카테고리 가로 스크롤 부분 ...
                                              child: Row(
                                                children: _selectedCategories.map((
                                                  category,
                                                ) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 6.0,
                                                        ),
                                                    child: Stack(
                                                      children: [
                                                        // 👇 1. 카테고리 글자를 감싸는 둥근 껍데기
                                                        Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                top: 6,
                                                                right: 6,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .grey
                                                                  .shade300,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            category,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Color.fromRGBO(
                                                                    166,
                                                                    166,
                                                                    166,
                                                                    1,
                                                                  ),
                                                              fontFamily:
                                                                  'Pretendard',
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                        ),

                                                        // 👇 2. 바로 여기입니다! 저장되기 전(!_isSaved)에만 x 버튼 띄우기
                                                        if (!_isSaved)
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedCategories
                                                                      .remove(
                                                                        category,
                                                                      );
                                                                });
                                                              },
                                                              child: Container(
                                                                width: 16,
                                                                height: 16,
                                                                decoration: const BoxDecoration(
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        217,
                                                                        217,
                                                                        217,
                                                                        1,
                                                                      ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: const Icon(
                                                                  Icons.close,
                                                                  size: 10,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),

                                        // 3. 본문 입력창
                                        // 3. 본문 입력창
                                        Container(
                                          constraints: BoxConstraints(
                                            minHeight: minBodyHeight > 0
                                                ? minBodyHeight
                                                : 0,
                                          ),
                                          child: TextField(
                                            controller: _bodyController,
                                            cursorColor: Colors.black,
                                            cursorHeight: 21.0,
                                            maxLines: null, // 무한 스크롤 가능
                                            keyboardType:
                                                TextInputType.multiline,
                                            // 💡 주의: 안에 변수가 들어가므로 const를 지웠습니다!
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 5.0,
                                                // 💡 핵심: 사진이 있으면 여백 20, 없으면 터치 영역을 위해 300!
                                                bottom: _selectedImage != null
                                                    ? 20.0
                                                    : 300.0,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              height:
                                                  _lineHeight / 14, // 줄간격 맞춤
                                              color: Colors.black87,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ),

                                        // 💡 4. 사진이 선택되었을 때만 보여주는 사진 미리보기 UI
                                        if (_selectedImage != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              bottom: 20,
                                            ),
                                            child: Stack(
                                              children: [
                                                // 둥근 모서리 사진 배경
                                                Container(
                                                  width: double.infinity,
                                                  height: 200, // 사진의 높이
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    image: DecorationImage(
                                                      image: FileImage(
                                                        File(
                                                          _selectedImage!.path,
                                                        ),
                                                      ),
                                                      fit: BoxFit
                                                          .cover, // 화면에 꽉 차게 비율 조절
                                                    ),
                                                  ),
                                                ),
                                                // 우측 상단 '-' 삭제 버튼
                                                if (!_isSaved)
                                                  Positioned(
                                                    top: 12,
                                                    right: 12,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedImage = null;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 28,
                                                        height: 28,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    153,
                                                                    153,
                                                                    153,
                                                                    0.8,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.remove,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        if (_selectedImage != null)
                                          const SizedBox(height: 100),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 8.0,
                      bottom:
                          36.0, // 💡 이 숫자를 키울수록 버튼들이 위로 쑥쑥 올라갑니다! (원하는 만큼 조절해 보세요)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 0.0,
                              right: 4.0,
                              top: 4.0,
                              bottom: 4.0,
                            ),
                            child: Image.asset(
                              'assets/images/ImageIcon.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showCategorySelection,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromRGBO(166, 166, 166, 1),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  '카테고리',
                                  style: TextStyle(
                                    color: Color.fromRGBO(166, 166, 166, 1),
                                    fontSize: 13,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.add,
                                  color: Color.fromRGBO(166, 166, 166, 1),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 💡 [스크롤 대응 수정] LinedPaperPainter 클래스
class LinedPaperPainter extends CustomPainter {
  final double lineHeight;
  final double titleHeight;

  LinedPaperPainter({required this.lineHeight, required this.titleHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final normalPaint = Paint()
      ..color = const Color.fromRGBO(224, 224, 224, 1)
      ..strokeWidth = 1;

    final thickPaint = Paint()
      ..color = const Color.fromRGBO(206, 206, 206, 1)
      ..strokeWidth = 2.0;

    // 1. 제목 첫 줄 굵은 선
    canvas.drawLine(
      Offset(20, titleHeight),
      Offset(size.width - 20, titleHeight),
      thickPaint,
    );

    // 2. 그 밑으로 본문 밑줄 그리기
    double currentY = titleHeight + lineHeight;

    // 💡 [이 부분 수정!]
    // size.height 에서 숫자를 빼주면, 바닥에서 그 숫자만큼 띄우고 선 그리기를 멈춥니다.
    // 숫자를 크게 할수록 밑줄이 일찍 끊겨서 밑줄의 마지막 위치가 위로 올라갑니다! (예: 60, 80, 100 등 자유롭게 조절)
    final double stopY = size.height + 20.0;

    while (currentY < stopY) {
      canvas.drawLine(
        Offset(20, currentY),
        Offset(size.width - 20, currentY),
        normalPaint,
      );
      currentY += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.lineHeight != lineHeight ||
        oldDelegate.titleHeight != titleHeight;
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEBEBEB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        splashColor: const Color(0xFFCBCBCB),
        highlightColor: const Color(0xFFCBCBCB),
        child: SizedBox(
          height: 45,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}