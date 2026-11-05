import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';

class TikTokVideoScrubber extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isAudio;
  final Color? playedColor;

  const TikTokVideoScrubber({
    super.key,
    required this.controller,
    this.isAudio = false,
    this.playedColor,
  });

  @override
  State<TikTokVideoScrubber> createState() => _TikTokVideoScrubberState();
}

class _TikTokVideoScrubberState extends State<TikTokVideoScrubber> {
  bool _isScrubbing = false;
  double _dragProgress = 0.0; // 0.0 to 1.0
  Duration _dragTargetDuration = Duration.zero;
  Duration _dragStartDuration = Duration.zero;
  bool _wasPlayingBeforeDrag = false;
  Timer? _hideHudTimer;
  DateTime _lastSeekTime = DateTime.now();

  @override
  void dispose() {
    _hideHudTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration < Duration.zero) duration = Duration.zero;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _onDragStart(DragStartDetails details, double totalWidth, Duration totalDuration) {
    if (totalDuration <= Duration.zero || totalWidth <= 0) return;

    HapticFeedback.selectionClick();
    _hideHudTimer?.cancel();

    final currentPos = widget.controller.value.position;
    _wasPlayingBeforeDrag = widget.controller.value.isPlaying;
    if (_wasPlayingBeforeDrag) {
      widget.controller.pause();
    }

    final ratio = (details.localPosition.dx / totalWidth).clamp(0.0, 1.0);
    final target = Duration(milliseconds: (totalDuration.inMilliseconds * ratio).round());

    setState(() {
      _isScrubbing = true;
      _dragProgress = ratio;
      _dragStartDuration = currentPos;
      _dragTargetDuration = target;
    });

    _throttleSeek(target);
  }

  void _onDragUpdate(DragUpdateDetails details, double totalWidth, Duration totalDuration) {
    if (!_isScrubbing || totalDuration <= Duration.zero || totalWidth <= 0) return;

    final ratio = (details.localPosition.dx / totalWidth).clamp(0.0, 1.0);
    final target = Duration(milliseconds: (totalDuration.inMilliseconds * ratio).round());

    setState(() {
      _dragProgress = ratio;
      _dragTargetDuration = target;
    });

    _throttleSeek(target);
  }

  void _onDragEnd(DragEndDetails details, Duration totalDuration) {
    if (!_isScrubbing) return;

    HapticFeedback.lightImpact();
    widget.controller.seekTo(_dragTargetDuration).then((_) {
      if (_wasPlayingBeforeDrag) {
        widget.controller.play();
      }
    });

    _hideHudTimer?.cancel();
    _hideHudTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isScrubbing = false;
        });
      }
    });
  }

  void _onTapDown(TapDownDetails details, double totalWidth, Duration totalDuration) {
    if (totalDuration <= Duration.zero || totalWidth <= 0) return;

    HapticFeedback.selectionClick();
    final ratio = (details.localPosition.dx / totalWidth).clamp(0.0, 1.0);
    final target = Duration(milliseconds: (totalDuration.inMilliseconds * ratio).round());

    setState(() {
      _isScrubbing = true;
      _dragProgress = ratio;
      _dragStartDuration = widget.controller.value.position;
      _dragTargetDuration = target;
    });

    widget.controller.seekTo(target);

    _hideHudTimer?.cancel();
    _hideHudTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isScrubbing = false;
        });
      }
    });
  }

  void _throttleSeek(Duration target) {
    final now = DateTime.now();
    if (now.difference(_lastSeekTime).inMilliseconds > 120) {
      _lastSeekTime = now;
      widget.controller.seekTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final totalDuration = value.duration;
        final currentPosition = value.position;
        final isInitialized = value.isInitialized;

        if (!isInitialized || totalDuration <= Duration.zero) {
          return const SizedBox.shrink();
        }

        final currentProgress = (currentPosition.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);
        final effectiveProgress = _isScrubbing ? _dragProgress : currentProgress;
        final effectiveDuration = _isScrubbing ? _dragTargetDuration : currentPosition;

        // Calculate delta time when scrubbing (+00:15 or -00:08)
        final deltaMs = _dragTargetDuration.inMilliseconds - _dragStartDuration.inMilliseconds;
        final isForward = deltaMs >= 0;
        final deltaAbs = Duration(milliseconds: deltaMs.abs());

        final activeColor = widget.playedColor ??
            (widget.isAudio ? AppColors.tiktokCyan : Colors.white);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Center Floating TikTok Scrubber HUD
            if (_isScrubbing)
              Positioned.fill(
                child: Center(
                  child: _buildCenterScrubBadge(
                    effectiveDuration: effectiveDuration,
                    totalDuration: totalDuration,
                    isForward: isForward,
                    deltaDuration: deltaAbs,
                  ),
                ),
              ),

            // 2. Bottom Scrubber & Time Indicator Row
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _onTapDown(d, totalWidth, totalDuration),
                    onHorizontalDragStart: (d) => _onDragStart(d, totalWidth, totalDuration),
                    onHorizontalDragUpdate: (d) => _onDragUpdate(d, totalWidth, totalDuration),
                    onHorizontalDragEnd: (d) => _onDragEnd(d, totalDuration),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      color: Colors.transparent, // Touch target
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Small live timestamp bar visible at all times
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  '${_formatDuration(effectiveDuration)} / ${_formatDuration(totalDuration)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: _isScrubbing
                                        ? const Color(0xFF00F2FE)
                                        : Colors.white.withOpacity(0.9),
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_isScrubbing)
                                Text(
                                  isForward
                                      ? '+${_formatDuration(deltaAbs)}'
                                      : '-${_formatDuration(deltaAbs)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isForward
                                        ? const Color(0xFF00F2FE)
                                        : const Color(0xFFFF2A54),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Interactive TikTok Scrubber Line with Thumb Knob
                          SizedBox(
                            height: 18,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Background Track
                                Container(
                                  height: _isScrubbing ? 5.5 : 2.8,
                                  width: totalWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),

                                // Buffered Track
                                if (value.buffered.isNotEmpty)
                                  FractionallySizedBox(
                                    widthFactor: (value.buffered.last.end.inMilliseconds /
                                            totalDuration.inMilliseconds)
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      height: _isScrubbing ? 5.5 : 2.8,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.38),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),

                                // Played Track
                                FractionallySizedBox(
                                  widthFactor: effectiveProgress,
                                  child: Container(
                                    height: _isScrubbing ? 5.5 : 2.8,
                                    decoration: BoxDecoration(
                                      color: activeColor,
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: _isScrubbing
                                          ? [
                                              BoxShadow(
                                                color: activeColor.withOpacity(0.6),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),

                                // Draggable Thumb Knob (Grows on scrub)
                                Positioned(
                                  left: (totalWidth - 32) * effectiveProgress - (_isScrubbing ? 6 : 4),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    width: _isScrubbing ? 14 : 9,
                                    height: _isScrubbing ? 14 : 9,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: activeColor,
                                        width: _isScrubbing ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                        if (_isScrubbing)
                                          BoxShadow(
                                            color: activeColor.withOpacity(0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
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
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- TIKTOK CENTER TIMESTAMP BADGE HUD ---
  Widget _buildCenterScrubBadge({
    required Duration effectiveDuration,
    required Duration totalDuration,
    required bool isForward,
    required Duration deltaDuration,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0813).withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF00F2FE).withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F2FE).withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isForward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                    color: const Color(0xFF00F2FE),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isForward
                        ? '+${_formatDuration(deltaDuration)}'
                        : '-${_formatDuration(deltaDuration)}',
                    style: const TextStyle(
                      color: Color(0xFF00F2FE),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatDuration(effectiveDuration),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    ' / ${_formatDuration(totalDuration)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
