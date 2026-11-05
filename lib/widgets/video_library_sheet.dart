import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/video_feed_provider.dart';
import '../theme/app_colors.dart';
import 'playlist_manager_sheet.dart';

class VideoLibrarySheet extends StatefulWidget {
  final Function(int index) onSelectVideo;

  const VideoLibrarySheet({
    super.key,
    required this.onSelectVideo,
  });

  @override
  State<VideoLibrarySheet> createState() => _VideoLibrarySheetState();
}

class _VideoLibrarySheetState extends State<VideoLibrarySheet> {
  String _filter = 'all'; // 'all', 'video', 'audio'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoFeedProvider>(context);

    // Filter current playlist items by sub-filter and search query
    final items = provider.videos.where((item) {
      if (_filter == 'video' && !item.isVideo) return false;
      if (_filter == 'audio' && !item.isAudio) return false;
      if (_searchQuery.isNotEmpty) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.video_collection_rounded, color: AppColors.tiktokCyan, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medya Akış Listesi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Liste: ${provider.activePlaylist?.name ?? "Tümü"}',
                        style: const TextStyle(fontSize: 11, color: AppColors.tiktokCyan),
                      ),
                    ],
                  ),
                ),
                // Playlists manager button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.cardDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PlaylistManagerSheet(),
                    );
                  },
                  icon: const Icon(Icons.queue_music_rounded, size: 16, color: AppColors.tiktokCyan),
                  label: const Text('Listeler', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Medya ara (şarkı, video başlığı)...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.tiktokCyan),
                  ),
                ),
              ),
            ),
          ),

          // Filter Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tümü (${provider.videos.length})'),
                const SizedBox(width: 6),
                _buildFilterChip('video', 'Video (${provider.videos.where((i) => i.isVideo).length})'),
                const SizedBox(width: 6),
                _buildFilterChip('audio', 'MP3 (${provider.videos.where((i) => i.isAudio).length})'),
              ],
            ),
          ),

          // Action: Pick MP3 + MP4 from Storage
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tiktokRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final count = await provider.pickVideosFromStorage();
                  if (context.mounted) {
                    if (count > 0) {
                      Navigator.pop(context);
                      widget.onSelectVideo(0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$count yeni medya dosyası listenin başına eklendi! 🎉'),
                          backgroundColor: AppColors.tiktokCyan,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dosya seçilmedi veya zaten listede kayıtlı.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                label: const Text(
                  'Dosyalardan MP3 & MP4 Medyaları Ekle',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Media List
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'Bu filtreye uygun medya bulunamadı.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // Find real index in provider.videos
                      final realIndex = provider.videos.indexOf(item);
                      final isCurrent = realIndex == provider.currentIndex;
                      final isAudio = item.isAudio;

                      return Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? (isAudio
                                  ? const Color(0xFF9D4EDD).withValues(alpha: 0.15)
                                  : AppColors.tiktokCyan.withValues(alpha: 0.12))
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? (isAudio ? const Color(0xFF9D4EDD) : AppColors.tiktokCyan)
                                : AppColors.glassBorder,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          onTap: () {
                            Navigator.pop(context);
                            if (realIndex != -1) {
                              widget.onSelectVideo(realIndex);
                            }
                          },
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isAudio
                                  ? const Color(0xFF9D4EDD).withValues(alpha: 0.25)
                                  : AppColors.tiktokCyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAudio ? Icons.audiotrack_rounded : Icons.videocam_rounded,
                              color: isAudio ? const Color(0xFFE0AAFF) : AppColors.tiktokCyan,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent
                                  ? (isAudio ? const Color(0xFFE0AAFF) : AppColors.tiktokCyan)
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${item.fileExtension} • ${item.isLocal ? "Yerel Depo" : "URL"} ${item.formattedSize.isNotEmpty ? "• ${item.formattedSize}" : ""}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrent)
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: isAudio ? const Color(0xFFE0AAFF) : AppColors.tiktokCyan,
                                  size: 20,
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 18, color: AppColors.textMuted),
                                onPressed: () {
                                  provider.removeVideo(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tiktokCyan : AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.tiktokCyan : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
