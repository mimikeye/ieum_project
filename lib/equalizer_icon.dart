import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// =======================================================
// 이퀄라이저 아이콘 (재생 중엔 애니메이션, 탭하면 음악 토글)
// =======================================================

class EqualizerIcon extends StatefulWidget {
  const EqualizerIcon({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  State<EqualizerIcon> createState() => _EqualizerIconState();
}

class _EqualizerIconState extends State<EqualizerIcon> {
  static const int _barCount = 5;
  static const int _maxLevel = 4;

  final Random _random = Random();
  late List<int> _levels;
  Timer? _animTimer;

  @override
  void initState() {
    super.initState();
    _levels = List.filled(_barCount, 1);
    if (widget.isPlaying) _startAnimating();
  }

  @override
  void didUpdateWidget(covariant EqualizerIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimating();
      } else {
        _stopAnimating();
      }
    }
  }

  void _startAnimating() {
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (!mounted) return;
      setState(() {
        _levels = List.generate(
          _barCount,
          (_) => 1 + _random.nextInt(_maxLevel),
        );
      });
    });
  }

  void _stopAnimating() {
    _animTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _levels = List.filled(_barCount, 1);
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dotSize = 4.0;
    const dotSpacing = 2.5;

    final color = widget.isPlaying
        ? const Color(0xFF7BAF3E)
        : const Color(0xFFC5C5C5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_barCount, (i) {
            return Padding(
              padding: EdgeInsets.only(
                right: i == _barCount - 1 ? 0 : dotSpacing,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_maxLevel, (dotIndex) {
                  final positionFromBottom = _maxLevel - 1 - dotIndex;
                  final active = positionFromBottom < _levels[i];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: dotIndex == _maxLevel - 1 ? 0 : dotSpacing,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? color : Colors.transparent,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}