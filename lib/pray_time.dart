import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'prayer_session.dart';
import 'equalizer_icon.dart';

class PrayerTimerPage extends StatefulWidget {
  const PrayerTimerPage({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  State<PrayerTimerPage> createState() => _PrayerTimerPageState();
}

class _PrayerTimerPageState extends State<PrayerTimerPage> {
  final PrayerSessionService _sessionService =
      PrayerSessionService();

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

  Timer? _timer;

  DateTime? _startedAt;

  int _elapsedSeconds = 0;

  bool _isRunning = false;
  bool _isPaused = false;

  bool _showTodayRecords = false;

  bool _isMusicMuted = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _todayRecords = [];

  int get _fullRounds => _elapsedSeconds ~/ 3600;

  double get _currentProgress =>
      (_elapsedSeconds % 3600) / 3600;

  
    @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRunning && !_isPaused && !_isMusicMuted) {
        _playRandomMusic();
      }
    });

    _loadTodayRecords();
  }


  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // =========================
  // 타이머 시작
  // =========================

  Future<void> _startTimer() async {
    if (_startedAt == null) {
      _startedAt = DateTime.now();
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    await _playRandomMusic();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!_isRunning || _isPaused) return;

        setState(() {
          _elapsedSeconds += 60;
        });
      },
    );
  }

  // =========================
  // 음악만 토글 (타이머는 유지)
  // =========================

  Future<void> _toggleMusic() async {
    if (!_isRunning || _isPaused) return;

    setState(() {
      _isMusicMuted = !_isMusicMuted;
    });

    if (_isMusicMuted) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  // =========================
  // 일시정지
  // =========================

  Future<void> _pauseTimer() async {
    _timer?.cancel();

    setState(() {
      _isPaused = true;
    });

    await _audioPlayer.pause();
  }

  // =========================
  // 다시 시작
  // =========================

  Future<void> _resumeTimer() async {
    setState(() {
      _isPaused = false;
    });

    await _audioPlayer.resume();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!_isRunning || _isPaused) return;

        setState(() {
          _elapsedSeconds += 60;
        });
      },
    );
  }

  // =========================
  // 음악
  // =========================

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
    } catch (e) {
      debugPrint('음악 재생 오류: $e');
    }
  }

  // =========================
  // 정지
  // =========================

  Future<void> _stopTimer() async {
  // 아직 시작 안 한 상태에서 정지 버튼을 누른 경우는 그냥 바로 정지
  if (_elapsedSeconds == 0) {
    _timer?.cancel();
    await _audioPlayer.stop();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isMusicMuted = false;
    });
    return;
  }

  // 다이얼로그를 보여주는 동안은 '일시정지' 상태로만 전환
  _timer?.cancel();
  await _audioPlayer.pause();

  setState(() {
    _isPaused = true;
  });

  final shouldSave = await _showConfirmDialog(
    message: '기도시간을 저장하시겠습니까?',
    leftText: '예',
    rightText: '취소',
  );

  if (!mounted) return;

  if (shouldSave) {
    // 저장 후 시작 화면으로 초기화
    await _savePrayerSession();

    if (!mounted) return;

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isMusicMuted = false;
      _elapsedSeconds = 0;
      _startedAt = null;
      _showTodayRecords = false;
    });
  } else {
    // 취소 -> 같은 시간에서 이어서 재개
    await _resumeTimer();
  }
}

  // =========================
  // Firebase 저장
  // =========================

  Future<void> _savePrayerSession() async {
    if (_startedAt == null) return;

    try {
      await _sessionService.savePrayerSession(
        uid: widget.uid,
        startedAt: _startedAt!,
        durationSeconds: _elapsedSeconds,
      );
    } catch (e) {
      debugPrint('기도시간 저장 오류: $e');
      return;
    }

    try {
      await _loadTodayRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기도시간이 저장되었습니다.')),
      );
    } catch (e) {
      debugPrint('오늘 기록 불러오기 오류: $e');
    }
  }

  // =========================
  // 커스텀 확인 다이얼로그
  // =========================

  Future<bool> _showConfirmDialog({
  required String message,
  required String leftText,
  required String rightText,
  }) async {
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

                // 메시지 영역
                Text(
                  message,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // 버튼 영역
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        text: leftText,
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogButton(
                        text: rightText,
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

  // =========================
  // 오늘 기록 불러오기
  // =========================

  Future<void> _loadTodayRecords() async {
    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final records =
        await _sessionService.getPrayerSessions(
      uid: widget.uid,
      date: date,
    );

    if (!mounted) return;

    setState(() {
      _todayRecords = records;
    });
  }

  // =========================
  // 페이지 나가기
  // =========================

  Future<bool> _handleBack() async {
    if (!_isRunning && !_isPaused) {
      return true;
    }

    final shouldExit = await _showConfirmDialog(
      message: '페이지를 나가면 시간 기록이 중단됩니다.\n정말 나가시겠어요?',
      leftText: '나가기',   // 왼쪽 = true 반환
      rightText: '취소',    // 오른쪽 = false 반환
    );

    if (!shouldExit) {
      return false;
    }

    _timer?.cancel();
    await _audioPlayer.stop();

    return true;
  }

  // =========================
  // 시간 표시
  // =========================

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _handleBack();

        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () async {
              final shouldPop = await _handleBack();

              if (shouldPop && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            '기도 몰입시간 타이머',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: EqualizerIcon(   // 앞의 _ 제거
                isPlaying: _isRunning && !_isPaused && !_isMusicMuted,
                onTap: _toggleMusic,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // ==========================================
            // 중앙 타이머 / 시작 버튼
            // ==========================================
            Positioned(
              left: 0,
              right: 0,
              bottom: 298,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // 원 (탭 감지 없음, 그냥 보여주기만)
                    SizedBox(
                      width: 279,
                      height: 279,
                      child: CustomPaint(
                        painter: PrayerCirclePainter(
                          progress: _currentProgress,
                          fullRounds: _fullRounds,
                          isRunning: _isRunning || _isPaused,
                        ),
                      ),
                    ),

                    // 시작 / 타이머 텍스트
                    if (!_isRunning && _elapsedSeconds == 0)
                      GestureDetector(
                        onTap: _startTimer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            '시작',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        _formatTime(_elapsedSeconds),
                        style: const TextStyle(
                          fontSize: 39,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 재생 / 일시정지 / 중지 버튼
            // ==========================================
            if (_isRunning || _isPaused)
              Positioned(
                left: 0,
                right: 0,
                bottom: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    IconButton(
                      onPressed: _isPaused
                          ? _resumeTimer
                          : _pauseTimer,
                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow
                            : Icons.pause,
                        size: 28,
                        color: const Color(0xFFB0B0B0),
                      ),
                    ),

                    const SizedBox(width: 24),

                    IconButton(
                      onPressed: _stopTimer,
                      icon: const Icon(
                        Icons.stop_rounded,
                        size: 26,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ],
                ),
              ),

            // ==========================================
            // 안내 문구
            // 항상 같은 위치
            // ==========================================
            Positioned(
              left: 0,
              right: 0,
              bottom: 118,
              child: const Center(
                child: Text(
                  '시간보다 하나님과 함께하는 순간에 집중해보세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA7A7A7),
                  ),
                ),
              ),
            ),

            // ==========================================
            // 오늘 기도 기록 서랍
            // 타이머 작동 중에는 숨김
            // ==========================================
            if (!_isRunning && !_isPaused)
              Positioned(
                left: 45,
                right: 45,
                bottom: 38,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ====================================
                    // 기록 패널 (펼쳤을 때만 등장, 독립된 둥근 모양)
                    // ====================================
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      alignment: Alignment.bottomCenter,
                      child: !_showTodayRecords
                          ? const SizedBox(width: double.infinity, height: 0)
                          : Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: const BoxConstraints(maxHeight: 220),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDFDFD),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 237, 237, 237),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: _buildRecordsList(),
                                    ),
                                  ),
                                  if (_todayRecords.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14.5),
                                      child: _buildTotalRow(),
                                    ),
                                ],
                              ),
                            ),
                    ),

                    // ====================================
                    // 서랍 버튼 (항상 동일한 캡슐 모양 고정)
                    // ====================================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 237, 237, 237),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (!_showTodayRecords) {
                            await _loadTodayRecords();
                          }

                          setState(() {
                            _showTodayRecords = !_showTodayRecords;
                          });
                        },
                        child: SizedBox(
                          height: 41,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '오늘 기도 기록',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                Icon(
                                  _showTodayRecords
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_todayRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '오늘의 기도 기록이 없습니다.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < _todayRecords.length; i++) ...[
          _buildRecordRow(_todayRecords[i]),
          if (i != _todayRecords.length - 1)
            const Divider(height: 1, color: Color(0xFFECECEC)),
        ],
      ],
    );
  }

  Widget _buildRecordRow(
    QueryDocumentSnapshot<Map<String, dynamic>> record,
  ) {
    final data = record.data();
    final timestamp = data['startedAt'] as Timestamp;
    final startedAt = timestamp.toDate();
    final duration = data['durationSeconds'] as int;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            _formatTimeOfDay(startedAt),
            style: const TextStyle(fontSize: 13),
          ),
          const Spacer(),
          Text(
            '+ ${_formatDuration(duration)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4F6539),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    int totalSeconds = 0;

    for (final record in _todayRecords) {
      totalSeconds += (record.data()['durationSeconds'] ?? 0) as int;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 20, color: Color(0xFFECECEC)),
        Row(
          children: [
            const Text(
              '총',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '+ ${_formatDuration(totalSeconds)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F6539),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimeOfDay(DateTime time) {
    final hour = time.hour;
    final minute =
        time.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? '오후' : '오전';

    final displayHour =
        hour % 12 == 0 ? 12 : hour % 12;

    return '$period $displayHour:$minute';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    }

    if (minutes > 0) {
      return '$minutes분';
    }

    return '0분';
  }
}


// =======================================================
// 원형 게이지
// =======================================================

class PrayerCirclePainter extends CustomPainter {
  final double progress;
  final int fullRounds;
  final bool isRunning; // 추가: 타이머가 시작된 상태인지

  PrayerCirclePainter({
    required this.progress,
    required this.fullRounds,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = const RadialGradient(
      colors: [
        Color(0x99D8EEAA),
        Color(0x99EAF8CB),
      ],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // 시작 전(탭하지 않은 상태) -> 기본 원을 꽉 채워서 표시
    if (!isRunning) {
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // 완료된 정시간 -> 꽉 찬 원으로 표시
    for (int i = 0; i < fullRounds; i++) {
      canvas.drawCircle(center, radius, paint);
    }

    // 현재 진행 중인 시간 -> 부채꼴로 표시 (00:00에는 progress=0이라 아무것도 안 그려짐)
    if (progress > 0) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx, center.dy - radius)
        ..arcTo(rect, -pi / 2, 2 * pi * progress, false)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PrayerCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fullRounds != fullRounds ||
        oldDelegate.isRunning != isRunning;
  }
}

// =======================================================
// 다이얼로그 버튼 (눌렀을 때 배경색 변화)
// =======================================================

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