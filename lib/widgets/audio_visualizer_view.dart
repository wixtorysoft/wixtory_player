import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../theme/app_colors.dart';

class AudioVisualizerView extends StatefulWidget {
  final VideoItem video;
  final bool isPlaying;

  const AudioVisualizerView({
    super.key,
    required this.video,
    required this.isPlaying,
  });

  @override
  State<AudioVisualizerView> createState() => _AudioVisualizerViewState();
}

class _AudioVisualizerViewState extends State<AudioVisualizerView>
    with TickerProviderStateMixin {
  late AnimationController _vinylController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isPlaying) {
      _vinylController.repeat();
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _vinylController.repeat();
        _waveController.repeat(reverse: true);
      } else {
        _vinylController.stop();
        _waveController.stop();
      }
    }
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vinylRadius = size.width * 0.32;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.15),
          radius: 1.1,
          colors: [
            Color(0xFF1B1429),
            Color(0xFF0F0A1A),
            AppColors.voidDark,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Ambient Background Pulse Glow
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              final scale = 1.0 + (_waveController.value * 0.15);
              return Container(
                width: vinylRadius * 2 * scale,
                height: vinylRadius * 2 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tiktokCyan.withValues(alpha: 0.25),
                      AppColors.tiktokRed.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Spinning Vinyl Record
          AnimatedBuilder(
            animation: _vinylController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _vinylController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: vinylRadius * 2,
              height: vinylRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF1F1F24),
                    Color(0xFF0E0E12),
                    Color(0xFF282830),
                    Color(0xFF0B0B0E),
                  ],
                  stops: [0.0, 0.45, 0.5, 1.0],
                ),
                border: Border.all(color: Colors.white12, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 30,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: AppColors.tiktokCyan.withValues(alpha: 0.25),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vinyl groove circles
                  Container(
                    width: vinylRadius * 1.5,
                    height: vinylRadius * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
                    ),
                  ),
                  Container(
                    width: vinylRadius * 1.1,
                    height: vinylRadius * 1.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1.5),
                    ),
                  ),
                  // Center Album Label
                  Container(
                    width: vinylRadius * 0.75,
                    height: vinylRadius * 0.75,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.tiktokCyan, AppColors.tiktokRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  // Center Spindle Hole
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Audio Equalizer Spectrum Bars (Below the vinyl)
          Positioned(
            bottom: size.height * 0.26,
            left: 32,
            right: 100,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return _buildSpectrumBars();
              },
            ),
          ),

          // 4. MP3 Format Indicator Badge
          Positioned(
            top: size.height * 0.16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.headphones_rounded, color: AppColors.tiktokCyan, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'SES AKIŞI • ${widget.video.fileExtension}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumBars() {
    const barCount = 28;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(barCount, (i) {
        final phase = (i / barCount) * 2 * math.pi;
        final waveVal = math.sin(_waveController.value * 2 * math.pi + phase).abs();
        final height = widget.isPlaying ? (10.0 + (waveVal * 42.0)) : 8.0;

        return Container(
          width: 3.5,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.tiktokCyan,
                AppColors.tiktokRed,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

