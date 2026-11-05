import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/video_item.dart';
import '../services/playlist_service.dart';
import '../state/video_feed_provider.dart';
import '../theme/app_colors.dart';

class PlaylistManagerSheet extends StatelessWidget {
  final VideoItem? currentMediaItem;
  final VoidCallback? onPlaylistSelected;

  const PlaylistManagerSheet({
    super.key,
    this.currentMediaItem,
    this.onPlaylistSelected,
  });

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int selectedColor = 0xFF00F2FE;

    final colorOptions = [
      0xFF00F2FE, // Cyan
      0xFFFF004F, // Red
      0xFF9D4EDD, // Purple
      0xFFFFBE0B, // Amber
      0xFF06D6A0, // Emerald
      0xFF3A86FF, // Blue
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.playlist_add_rounded, color: AppColors.tiktokCyan, size: 24),
              SizedBox(width: 10),
              Text(
                'Yeni Çalma Listesi',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Liste Adı (Örn: Spor Motivasyon)',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.cardDark,
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
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Açıklama (Opsiyonel)',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Liste Rengi:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: colorOptions.map((c) {
                  final isSelected = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tiktokRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<VideoFeedProvider>(context, listen: false).createPlaylist(
                    name,
                    description: descController.text.trim(),
                    colorValue: selectedColor,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text('Listeyi Yeniden Adlandır', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tiktokCyan),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Provider.of<VideoFeedProvider>(context, listen: false)
                    .renamePlaylist(playlist.id, newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoFeedProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.queue_music_rounded, color: AppColors.tiktokCyan, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Çalma Listelerim',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Add New Playlist Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardDark,
                  foregroundColor: AppColors.tiktokCyan,
                  side: const BorderSide(color: AppColors.tiktokCyan, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showCreatePlaylistDialog(context),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text(
                  'Yeni Liste Oluştur',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Playlist Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: provider.playlists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final playlist = provider.playlists[index];
                final isSelected = provider.activePlaylistId == playlist.id;

                // Count items in this playlist
                int itemCount = 0;
                if (playlist.id == PlaylistService.idAll) {
                  itemCount = provider.allItems.length;
                } else if (playlist.id == PlaylistService.idVideo) {
                  itemCount = provider.allItems.where((i) => i.isVideo).length;
                } else if (playlist.id == PlaylistService.idAudio) {
                  itemCount = provider.allItems.where((i) => i.isAudio).length;
                } else {
                  itemCount = provider.allItems
                      .where((i) => i.playlistIds.contains(playlist.id))
                      .length;
                }

                final hasMediaItem = currentMediaItem != null &&
                    currentMediaItem!.playlistIds.contains(playlist.id);

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(playlist.colorValue).withValues(alpha: 0.12)
                        : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Color(playlist.colorValue)
                          : AppColors.glassBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.setActivePlaylist(playlist.id);
                      Navigator.pop(context);
                      onPlaylistSelected?.call();
                    },
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Color(playlist.colorValue).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        playlist.iconData,
                        color: Color(playlist.colorValue),
                        size: 22,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            playlist.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Color(playlist.colorValue) : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(playlist.colorValue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Aktif',
                              style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '$itemCount Medya ${playlist.description.isNotEmpty ? '• ${playlist.description}' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // If currentMediaItem is provided, show add/remove checkbox for custom playlists
                        if (currentMediaItem != null && !playlist.isSystem)
                          IconButton(
                            icon: Icon(
                              hasMediaItem
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: hasMediaItem
                                  ? AppColors.tiktokCyan
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                            tooltip: 'Bu medyayı listeye ekle/çıkar',
                            onPressed: () {
                              provider.toggleItemInPlaylist(
                                currentMediaItem!.id,
                                playlist.id,
                              );
                            },
                          ),
                        if (!playlist.isSystem) ...[
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
                            color: AppColors.surfaceDark,
                            onSelected: (val) {
                              if (val == 'rename') {
                                _showRenameDialog(context, playlist);
                              } else if (val == 'delete') {
                                provider.deletePlaylist(playlist.id);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Yeniden Adlandır', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.tiktokRed),
                                    SizedBox(width: 8),
                                    Text('Listeyi Sil', style: TextStyle(color: AppColors.tiktokRed, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
