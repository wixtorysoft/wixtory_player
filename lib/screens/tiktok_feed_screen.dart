import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../screens/settings_screen.dart';
import '../state/video_feed_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/media_importing_hud.dart';
import '../widgets/playlist_manager_sheet.dart';
import '../widgets/tiktok_actions_bar.dart';
import '../widgets/tiktok_bottom_info.dart';
import '../widgets/video_library_sheet.dart';
import '../widgets/video_player_item.dart';
import '../widgets/volume_slider_hud.dart';

class TikTokFeedScreen extends StatefulWidget {
  const TikTokFeedScreen({super.key});

  @override
  State<TikTokFeedScreen> createState() => _TikTokFeedScreenState();
}

class _TikTokFeedScreenState extends State<TikTokFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openSettingsScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _openLibrarySheet() {
    final provider = Provider.of<VideoFeedProvider>(context, listen: false);
    final count = provider.videos.length;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoLibrarySheet(
        onSelectVideo: (index) {
          if (_pageController.hasClients && count > 0) {
            final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
            final currentCycle = (currentPage / count).floor();
            final targetPage = currentCycle * count + index;
            _pageController.jumpToPage(targetPage >= 0 ? targetPage : index);
          }
          provider.onPageChanged(index);
        },
      ),
    );
  }

  void _openPlaylistsSheet() {
    final provider = Provider.of<VideoFeedProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaylistManagerSheet(
        currentMediaItem: provider.currentVideo,
        onPlaylistSelected: () {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoFeedProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.voidDark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.tiktokCyan,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final lang = provider.currentLanguage;
    final activePlaylist = provider.activePlaylist;
    final displayVideos = provider.videos;

    if (displayVideos.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.voidDark,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(activePlaylist?.colorValue ?? 0xFF00F2FE),
                            AppColors.tiktokRed,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tiktokRed.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        activePlaylist?.iconData ?? Icons.perm_media_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      activePlaylist != null
                          ? '${activePlaylist.name} - ${AppStrings.get('no_media', lang)}'
                          : AppStrings.get('no_media', lang),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.get('no_media_desc', lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tiktokRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final count = await provider.pickVideosFromStorage(
                          targetPlaylistId: provider.activePlaylistId,
                        );
                        if (count > 0 && mounted) {
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(0);
                          }
                        }
                      },
                      icon: const Icon(Icons.add_to_photos_rounded, size: 20),
                      label: Text(
                        AppStrings.get('add_media', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _openPlaylistsSheet,
                      icon: const Icon(
                        Icons.queue_music_rounded,
                        color: AppColors.tiktokCyan,
                        size: 18,
                      ),
                      label: Text(
                        AppStrings.get('other_playlists', lang),
                        style: const TextStyle(color: AppColors.tiktokCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Bar in Empty State
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _openSettingsScreen,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Preloader HUD overlay in empty state
            if (provider.isImporting)
              MediaImportingHud(
                statusMessage: provider.importStatusMessage,
                language: lang,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.voidDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Vertical TikTok PageView Reel Stream with seamless infinite looping
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: displayVideos.length > 1 ? null : displayVideos.length,
            onPageChanged: (page) {
              final realIndex = displayVideos.isNotEmpty ? page % displayVideos.length : 0;
              provider.onPageChanged(realIndex);
            },
            itemBuilder: (context, page) {
              final realIndex = displayVideos.isNotEmpty ? page % displayVideos.length : 0;
              final video = displayVideos[realIndex];
              final isActive = realIndex == provider.currentIndex;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Video / Audio Frame
                  VideoPlayerItem(
                    video: video,
                    isActive: isActive,
                    volume: provider.effectiveVolume,
                    playbackSpeed: provider.playbackSpeed,
                    isLooping: provider.isLooping,
                    isFitContain: provider.isFitContain,
                  ),

                  // Bottom Left: Author & Info Overlay
                  Positioned(
                    left: 0,
                    right: 80,
                    bottom: 0,
                    child: TikTokBottomInfo(video: video),
                  ),

                  // Bottom Right: Actions Bar (Playlists, Volume, Speed, Library, Vinyl)
                  Positioned(
                    right: 12,
                    bottom: 20,
                    child: TikTokActionsBar(
                      video: video,
                      isMuted: provider.isMuted,
                      volume: provider.volume,
                      playbackSpeed: provider.playbackSpeed,
                      isFitContain: provider.isFitContain,
                      onToggleMute: provider.toggleMute,
                      onVolumeChanged: provider.setVolume,
                      onCycleSpeed: provider.cyclePlaybackSpeed,
                      onToggleFitMode: provider.toggleFitMode,
                      onOpenLibrary: _openLibrarySheet,
                      onOpenPlaylists: _openPlaylistsSheet,
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Top Navigation & Playlist Switcher Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Media count index badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        '${provider.currentIndex + 1}/${displayVideos.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Active Playlist Selector Chip
                    GestureDetector(
                      onTap: _openPlaylistsSheet,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(activePlaylist?.colorValue ?? 0xFF00F2FE).withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(activePlaylist?.colorValue ?? 0xFF00F2FE).withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activePlaylist?.iconData ?? Icons.queue_music_rounded,
                              size: 15,
                              color: Color(activePlaylist?.colorValue ?? 0xFF00F2FE),
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                activePlaylist?.name ?? 'Çalma Listesi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Add Local MP3 & MP4 Files Button
                    GestureDetector(
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final count = await provider.pickVideosFromStorage(
                          targetPlaylistId: provider.activePlaylistId,
                        );
                        if (count > 0 && mounted) {
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(0);
                          }
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '$count ${AppStrings.get('import_success', lang)}',
                              ),
                              backgroundColor: AppColors.tiktokCyan,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tiktokCyan.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.tiktokCyan, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: AppColors.tiktokCyan, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.get('add', lang),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.tiktokCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Settings Button (Slide transition right to left)
                    GestureDetector(
                      onTap: _openSettingsScreen,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Volume Slider HUD (Appears when volume changes)
          if (provider.showVolumeHud)
            Positioned(
              top: 75,
              left: 0,
              right: 0,
              child: Center(
                child: VolumeSliderHud(
                  volume: provider.volume,
                  isMuted: provider.isMuted,
                  onVolumeChanged: provider.setVolume,
                ),
              ),
            ),

          // 4. Media Importing Preloader HUD (Appears when importing files)
          if (provider.isImporting)
            MediaImportingHud(
              statusMessage: provider.importStatusMessage,
              language: lang,
            ),
        ],
      ),
    );
  }
}
