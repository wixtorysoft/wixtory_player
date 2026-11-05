import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';
import '../theme/app_colors.dart';
import 'audio_visualizer_view.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoItem video;
  final bool isActive;
  final double volume; // 0.0 to 1.0
  final double playbackSpeed;
  final bool isLooping;
  final bool isFitContain;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.isActive,
    required this.volume,
    required this.playbackSpeed,
    required this.isLooping,
    required this.isFitContain,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Play / Pause center momentary icon
  bool _showPlayPauseIcon = false;
  bool _isPlayingState = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      if (widget.video.isLocal) {
        final file = File(widget.video.path);
        if (!await file.exists()) {
          throw Exception('Dosya bulunamadı: ${widget.video.path}');
        }
        _controller = VideoPlayerController.file(file);
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.path));
      }

      await _controller!.initialize();
      await _controller!.setLooping(widget.isLooping);
      await _controller!.setVolume(widget.volume);
      await _controller!.setPlaybackSpeed(widget.playbackSpeed);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          _isPlayingState = widget.isActive;
        });
        if (widget.isActive) {
          _controller!.play();
        } else {
          _controller!.pause();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_controller != null && _isInitialized) {
      if (widget.isActive != oldWidget.isActive) {
        if (widget.isActive) {
          _controller!.play();
          _isPlayingState = true;
        } else {
          // Immediately pause inactive videos to save CPU & RAM
          _controller!.pause();
          _isPlayingState = false;
        }
      }

      if (widget.volume != oldWidget.volume) {
        _controller!.setVolume(widget.volume);
      }

      if (widget.playbackSpeed != oldWidget.playbackSpeed) {
        _controller!.setPlaybackSpeed(widget.playbackSpeed);
      }

      if (widget.isLooping != oldWidget.isLooping) {
        _controller!.setLooping(widget.isLooping);
      }
    }
  }

  void _handleSingleTap() {
    if (_controller == null || !_isInitialized) return;

    HapticFeedback.selectionClick();
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() {
        _isPlayingState = false;
        _showPlayPauseIcon = true;
      });
    } else {
      _controller!.play();
      setState(() {
        _isPlayingState = true;
        _showPlayPauseIcon = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showPlayPauseIcon = false);
      });
    }
  }

  @override
  void dispose() {
    // Immediately release hardware decoder and surface texture
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppColors.voidDark,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.tiktokRed, size: 54),
              const SizedBox(height: 14),
              Text(
                widget.video.isAudio ? 'Müzik Oynatılamadı' : 'Video Oynatılamadı',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardDark,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.glassBorder),
                ),
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                  });
                  _initController();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: AppColors.voidDark,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.tiktokCyan,
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _handleSingleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Media Frame: Audio Visualizer (MP3) or Video Surface (MP4)
          if (widget.video.isAudio)
            AudioVisualizerView(
              video: widget.video,
              isPlaying: _isPlayingState,
            )
          else
            _buildVideoSurface(),

          // 2. Play / Pause Center Icon Pulse (Videos only)
          if (!widget.video.isAudio && (!_isPlayingState || _showPlayPauseIcon))
            Center(
              child: AnimatedOpacity(
                opacity: !_isPlayingState ? 0.9 : (_showPlayPauseIcon ? 0.8 : 0.0),
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Icon(
                    _isPlayingState ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
              ),
            ),

          // 3. Subtle Bottom Scrubber Progress Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              colors: VideoProgressColors(
                playedColor: widget.video.isAudio ? AppColors.tiktokCyan : AppColors.tiktokRed,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lightweight video surface: Uses 1 single VideoPlayer texture to minimize RAM and GPU
  Widget _buildVideoSurface() {
    final size = _controller!.value.size;
    final aspect = _controller!.value.aspectRatio > 0
        ? _controller!.value.aspectRatio
        : (size.width > 0 && size.height > 0 ? size.width / size.height : 16 / 9);

    if (widget.isFitContain) {
      // Prioritize horizontal width with zero cropping.
      // Uses a lightweight static cinematic gradient instead of duplicate blurred video texture!
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF14141B),
              Color(0xFF0A0A0E),
              AppColors.voidDark,
            ],
          ),
        ),
        child: Center(
          child: AspectRatio(
            aspectRatio: aspect,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    } else {
      // Fullscreen fill (crops to fill entire screen)
      return Center(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width > 0 ? size.width : 1080,
              height: size.height > 0 ? size.height : 1920,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      );
    }
  }
}
