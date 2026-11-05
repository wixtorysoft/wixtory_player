import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VolumeSliderHud extends StatelessWidget {
  final double volume; // 0.0 to 1.0
  final bool isMuted;
  final ValueChanged<double> onVolumeChanged;

  const VolumeSliderHud({
    super.key,
    required this.volume,
    required this.isMuted,
    required this.onVolumeChanged,
  });

  IconData _getVolumeIcon() {
    if (isMuted || volume == 0.0) return Icons.volume_off_rounded;
    if (volume < 0.3) return Icons.volume_mute_rounded;
    if (volume < 0.7) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final effective = isMuted ? 0.0 : volume;
    final percentage = (effective * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getVolumeIcon(),
            color: isMuted ? AppColors.tiktokRed : AppColors.tiktokCyan,
            size: 22,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.tiktokCyan,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: effective,
                min: 0.0,
                max: 1.0,
                onChanged: onVolumeChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

