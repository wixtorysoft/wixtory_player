import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/video_item.dart';
import '../theme/app_colors.dart';

class TikTokActionsBar extends StatefulWidget {
  final VideoItem video;
  final bool isMuted;
  final double volume;
  final double playbackSpeed;
  final bool isFitContain;
  final VoidCallback onToggleMute;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onCycleSpeed;
  final VoidCallback onToggleFitMode;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenPlaylists;

  const TikTokActionsBar({
    super.key,
    required this.video,
    required this.isMuted,
    required this.volume,
    required this.playbackSpeed,
    required this.isFitContain,
    required this.onToggleMute,
    required this.onVolumeChanged,
    required this.onCycleSpeed,
    required this.onToggleFitMode,
    required this.onOpenLibrary,
    required this.onOpenPlaylists,
  });

  @override
  State<TikTokActionsBar> createState() => _TikTokActionsBarState();
}

class _TikTokActionsBarState extends State<TikTokActionsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _diskController;

  @override
  void initState() {
    super.initState();
    _diskController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _diskController.dispose();
    super.dispose();
  }

  void _showVolumeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final effective = widget.isMuted ? 0.0 : widget.volume;
          final pct = (effective * 100).round();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      widget.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: widget.isMuted ? AppColors.tiktokRed : AppColors.tiktokCyan,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Ses Kontrolü',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.tiktokCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_down_rounded, color: Colors.white),
                      onPressed: () {
                        widget.onVolumeChanged((widget.volume - 0.1).clamp(0.0, 1.0));
                        setSheetState(() {});
                      },
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                          activeTrackColor: AppColors.tiktokCyan,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: effective,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (val) {
                            widget.onVolumeChanged(val);
                            setSheetState(() {});
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                      onPressed: () {
                        widget.onVolumeChanged((widget.volume + 0.1).clamp(0.0, 1.0));
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.cardDark,
                        foregroundColor: widget.isMuted ? AppColors.tiktokRed : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        widget.onToggleMute();
                        setSheetState(() {});
                      },
                      icon: Icon(widget.isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: 18),
                      label: Text(widget.isMuted ? 'Sesi Aç' : 'Sessize Al'),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.cardDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        widget.onVolumeChanged(1.0);
                        setSheetState(() {});
                      },
                      icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.tiktokCyan),
                      label: const Text('Maksimum (%100)'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Row(
          children: [
            Icon(
              widget.video.isAudio ? Icons.audiotrack_rounded : Icons.videocam_rounded,
              color: widget.video.isAudio ? AppColors.tiktokCyan : AppColors.tiktokRed,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.video.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Format:', widget.video.fileExtension),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Tür:',
              widget.video.isAudio ? 'MP3 Ses Parçası 🎵' : 'MP4 Video Klibi 🎬',
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Kaynak:', widget.video.isLocal ? 'Yerel Dosya Deposu' : 'Ağ Akışı (URL)'),
            const SizedBox(height: 8),
            if (widget.video.fileSizeBytes > 0) ...[
              _buildInfoRow('Boyut:', widget.video.formattedSize),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            const Text(
              'Dosya Yolu:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: SelectableText(
                widget.video.path,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: AppColors.tiktokCyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. User Avatar + Media Type Tag
        _buildAvatarButton(),
        const SizedBox(height: 14),

        // 2. Playlists Management Launcher ("Listeler")
        _buildActionButton(
          icon: Icons.playlist_play_rounded,
          iconColor: AppColors.tiktokCyan,
          label: 'Listeler',
          onTap: widget.onOpenPlaylists,
        ),
        const SizedBox(height: 14),

        // 4. Aspect Ratio / Fit Mode Toggle (Sığdır / Doldur)
        if (!widget.video.isAudio) ...[
          _buildActionButton(
            icon: widget.isFitContain ? Icons.fit_screen_rounded : Icons.crop_free_rounded,
            iconColor: widget.isFitContain ? AppColors.tiktokCyan : Colors.white,
            label: widget.isFitContain ? 'Sığdır' : 'Doldur',
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onToggleFitMode();
            },
          ),
          const SizedBox(height: 14),
        ],

        // 5. Volume Control Button (Tap opens volume slider sheet)
        _buildActionButton(
          icon: widget.isMuted
              ? Icons.volume_off_rounded
              : (widget.volume < 0.5 ? Icons.volume_down_rounded : Icons.volume_up_rounded),
          iconColor: widget.isMuted ? AppColors.tiktokRed : Colors.white,
          label: widget.isMuted ? 'Sessiz' : '%${(widget.volume * 100).round()}',
          onTap: () => _showVolumeSheet(context),
        ),
        const SizedBox(height: 14),

        // 6. Playback Speed Button (1.0x, 1.5x, etc.)
        _buildActionButton(
          icon: Icons.speed_rounded,
          iconColor: Colors.white,
          label: '${widget.playbackSpeed}x',
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCycleSpeed();
          },
        ),
        const SizedBox(height: 14),

        // 7. Media Library Sheet Button
        _buildActionButton(
          icon: Icons.video_library_rounded,
          iconColor: Colors.white,
          label: 'Akış',
          onTap: widget.onOpenLibrary,
        ),
        const SizedBox(height: 14),

        // 8. Media Info Details Button
        _buildActionButton(
          icon: Icons.info_outline_rounded,
          iconColor: Colors.white,
          label: 'Detay',
          onTap: () => _showInfoDialog(context),
        ),
        const SizedBox(height: 16),

        // 9. Spinning Vinyl Disk
        _buildSpinningVinyl(),
      ],
    );
  }

  Widget _buildAvatarButton() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            gradient: LinearGradient(
              colors: widget.video.isAudio
                  ? [const Color(0xFF9D4EDD), AppColors.tiktokCyan]
                  : [AppColors.tiktokCyan, AppColors.tiktokRed],
            ),
          ),
          child: Center(
            child: Icon(
              widget.video.isAudio ? Icons.headphones_rounded : Icons.videocam_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        Positioned(
          bottom: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: widget.video.isAudio ? const Color(0xFF9D4EDD) : AppColors.tiktokRed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.video.fileExtension,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinningVinyl() {
    return AnimatedBuilder(
      animation: _diskController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _diskController.value * 2 * math.pi,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF2C2C35), Color(0xFF101015), Colors.black],
                stops: [0.2, 0.7, 1.0],
              ),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 8),
              ],
            ),
            child: Center(
              child: Icon(
                widget.video.isAudio
                    ? Icons.music_note_rounded
                    : Icons.movie_filter_rounded,
                color: widget.video.isAudio ? AppColors.tiktokCyan : AppColors.tiktokRed,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}
