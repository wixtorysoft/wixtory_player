import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../theme/app_colors.dart';

class TikTokBottomInfo extends StatelessWidget {
  final VideoItem video;

  const TikTokBottomInfo({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    final isAudio = video.isAudio;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 90, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black87,
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author / Handle + Media Type Pill (No MB display)
          Row(
            children: [
              Text(
                video.isLocal ? '@my_storage' : '@wixtory_player',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                  shadows: [
                    Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAudio
                      ? const Color(0xFF9D4EDD).withValues(alpha: 0.25)
                      : AppColors.tiktokCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isAudio ? const Color(0xFF9D4EDD) : AppColors.tiktokCyan,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isAudio ? 'MP3 • SES' : 'MP4 • VİDEO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAudio
                        ? const Color(0xFFE0AAFF)
                        : AppColors.tiktokCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Video Title Only (No "yerel video klibi" description)
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Audio / Sound info bar
          Row(
            children: [
              Icon(
                isAudio ? Icons.audiotrack_rounded : Icons.music_note_rounded,
                color: isAudio ? const Color(0xFFE0AAFF) : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isAudio
                      ? 'Parça • ${video.title} (MP3)'
                      : 'Orijinal Ses • ${video.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
