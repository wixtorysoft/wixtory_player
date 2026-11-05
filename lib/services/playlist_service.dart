import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_strings.dart';
import '../models/playlist_model.dart';
import '../models/video_item.dart';

class PlaylistService {
  static const String _keyPlaylist = 'wixtory_player_user_media_v1';
  static const String _keyPlaylistLegacy = 'reel_flow_user_media_v1';
  static const String _keyCustomPlaylists = 'wixtory_player_user_playlists_v1';
  static const String _keyCustomPlaylistsLegacy = 'reel_flow_user_playlists_v1';
  static const String keyLanguage = 'wixtory_player_language_v1';

  /// Predefined system playlist IDs
  static const String idAll = 'all';
  static const String idVideo = 'video';
  static const String idAudio = 'audio';

  static List<PlaylistModel> getSystemPlaylists([String? lang]) {
    return [
      PlaylistModel(
        id: idAll,
        name: AppStrings.get('all_media_playlist', lang),
        description: AppStrings.get('all_media_desc', lang),
        iconCode: 0xe6e2, // queue_music
        colorValue: 0xFF00F2FE,
        isSystem: true,
      ),
      PlaylistModel(
        id: idVideo,
        name: AppStrings.get('video_playlist', lang),
        description: AppStrings.get('video_playlist_desc', lang),
        iconCode: 0xe6a8, // video_collection
        colorValue: 0xFFFF004F,
        isSystem: true,
      ),
      PlaylistModel(
        id: idAudio,
        name: AppStrings.get('audio_playlist', lang),
        description: AppStrings.get('audio_playlist_desc', lang),
        iconCode: 0xe415, // music_note
        colorValue: 0xFF9D4EDD,
        isSystem: true,
      ),
    ];
  }

  static Future<List<PlaylistModel>> loadPlaylists([String? lang]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_keyCustomPlaylists) ?? prefs.getStringList(_keyCustomPlaylistsLegacy);
      final systemPlaylists = getSystemPlaylists(lang);

      if (rawList == null || rawList.isEmpty) {
        return systemPlaylists;
      }

      final customPlaylists = rawList
          .map((item) => PlaylistModel.fromJson(item))
          .where((p) => !p.isSystem)
          .toList();

      return [...systemPlaylists, ...customPlaylists];
    } catch (_) {
      return getSystemPlaylists(lang);
    }
  }

  static Future<void> saveCustomPlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final customOnly = playlists.where((p) => !p.isSystem).toList();
    final rawList = customOnly.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyCustomPlaylists, rawList);
  }

  static Future<List<VideoItem>> loadMediaItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_keyPlaylist) ?? prefs.getStringList(_keyPlaylistLegacy);
      if (rawList == null || rawList.isEmpty) {
        return [];
      }
      return rawList.map((item) => VideoItem.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMediaItems(List<VideoItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = items.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyPlaylist, rawList);
  }

  static Future<String> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(keyLanguage) ?? 'tr';
    } catch (_) {
      return 'tr';
    }
  }

  static Future<void> saveLanguage(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyLanguage, lang);
    } catch (_) {}
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPlaylist);
      await prefs.remove(_keyPlaylistLegacy);
      await prefs.remove(_keyCustomPlaylists);
      await prefs.remove(_keyCustomPlaylistsLegacy);
    } catch (_) {}
  }
}
