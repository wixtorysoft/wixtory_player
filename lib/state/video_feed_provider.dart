import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/playlist_model.dart';
import '../models/video_item.dart';
import '../services/playlist_service.dart';

class VideoFeedProvider extends ChangeNotifier {
  List<VideoItem> _allItems = [];
  List<PlaylistModel> _playlists = [];
  String _activePlaylistId = PlaylistService.idAll;
  int _currentIndex = 0;

  // Multi-lingual state ('tr', 'en', 'de', 'it', 'fr')
  String _currentLanguage = 'tr';
  String get currentLanguage => _currentLanguage;

  // Media importing preloader HUD state
  bool _isImporting = false;
  bool get isImporting => _isImporting;
  String _importStatusMessage = '';
  String get importStatusMessage => _importStatusMessage;

  // Audio / Volume state
  double _volume = 1.0; // 0.0 to 1.0
  bool _isMuted = false;
  bool _showVolumeHud = false;
  Timer? _volumeHudTimer;

  // Video Aspect Ratio / Fit mode (default: true -> BoxFit.contain, horizontal width prioritized, zero cropping)
  bool _isFitContain = true;

  // Playback options
  double _playbackSpeed = 1.0; // 0.5x, 1.0x, 1.5x, 2.0x
  bool _isLooping = true;
  bool _isLoading = true;

  // Getters
  List<VideoItem> get allItems => _allItems;
  List<PlaylistModel> get playlists => _playlists;
  String get activePlaylistId => _activePlaylistId;
  int get currentIndex => _currentIndex;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get showVolumeHud => _showVolumeHud;
  bool get isFitContain => _isFitContain;
  BoxFit get mediaFit => _isFitContain ? BoxFit.contain : BoxFit.cover;
  double get playbackSpeed => _playbackSpeed;
  bool get isLooping => _isLooping;
  bool get isLoading => _isLoading;

  /// Effective volume (0.0 if muted, else _volume)
  double get effectiveVolume => _isMuted ? 0.0 : _volume;

  /// Filtered items based on active playlist
  List<VideoItem> get videos {
    if (_activePlaylistId == PlaylistService.idAll) {
      return _allItems;
    } else if (_activePlaylistId == PlaylistService.idVideo) {
      return _allItems.where((item) => item.isVideo).toList();
    } else if (_activePlaylistId == PlaylistService.idAudio) {
      return _allItems.where((item) => item.isAudio).toList();
    } else {
      return _allItems
          .where((item) => item.playlistIds.contains(_activePlaylistId))
          .toList();
    }
  }

  PlaylistModel? get activePlaylist {
    try {
      return _playlists.firstWhere((p) => p.id == _activePlaylistId);
    } catch (_) {
      return null;
    }
  }

  VideoItem? get currentVideo {
    final list = videos;
    if (list.isNotEmpty && _currentIndex < list.length) {
      return list[_currentIndex];
    }
    return null;
  }

  VideoFeedProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _currentLanguage = await PlaylistService.loadLanguage();
    _playlists = await PlaylistService.loadPlaylists(_currentLanguage);
    _allItems = await PlaylistService.loadMediaItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (!AppStrings.supportedLanguages.contains(lang)) return;
    _currentLanguage = lang;
    await PlaylistService.saveLanguage(lang);
    _playlists = await PlaylistService.loadPlaylists(_currentLanguage);
    notifyListeners();
  }

  Future<void> clearAllCache() async {
    _allItems = [];
    _currentIndex = 0;
    await PlaylistService.clearAllData();
    _playlists = await PlaylistService.loadPlaylists(_currentLanguage);
    notifyListeners();
  }

  void onPageChanged(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // --- ASPECT RATIO & FIT MODE TOGGLE ---

  void toggleFitMode() {
    _isFitContain = !_isFitContain;
    notifyListeners();
  }

  // --- VOLUME CONTROLS ---

  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
    if (_volume > 0.0 && _isMuted) {
      _isMuted = false;
    }
    _triggerVolumeHud();
    notifyListeners();
  }

  void increaseVolume([double step = 0.1]) {
    setVolume(_volume + step);
  }

  void decreaseVolume([double step = 0.1]) {
    setVolume(_volume - step);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _triggerVolumeHud();
    notifyListeners();
  }

  void _triggerVolumeHud() {
    _showVolumeHud = true;
    _volumeHudTimer?.cancel();
    _volumeHudTimer = Timer(const Duration(seconds: 2), () {
      _showVolumeHud = false;
      notifyListeners();
    });
  }

  // --- PLAYBACK SPEED & LOOP ---

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void cyclePlaybackSpeed() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    int currentIdx = speeds.indexOf(_playbackSpeed);
    if (currentIdx == -1 || currentIdx == speeds.length - 1) {
      _playbackSpeed = speeds[0];
    } else {
      _playbackSpeed = speeds[currentIdx + 1];
    }
    notifyListeners();
  }

  void toggleLooping() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  // --- PLAYLIST MANAGEMENT ---

  void setActivePlaylist(String playlistId) {
    if (_activePlaylistId != playlistId) {
      _activePlaylistId = playlistId;
      _currentIndex = 0;
      notifyListeners();
    }
  }

  Future<void> createPlaylist(
    String name, {
    String description = '',
    int iconCode = 0xe6e2,
    int colorValue = 0xFF00F2FE,
  }) async {
    final newId = 'pl_${DateTime.now().millisecondsSinceEpoch}';
    final playlist = PlaylistModel(
      id: newId,
      name: name,
      description: description,
      iconCode: iconCode,
      colorValue: colorValue,
      isSystem: false,
    );
    _playlists.add(playlist);
    await PlaylistService.saveCustomPlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    final idx = _playlists.indexWhere((p) => p.id == playlistId && !p.isSystem);
    if (idx != -1) {
      _playlists.removeAt(idx);
      for (final item in _allItems) {
        item.playlistIds.remove(playlistId);
      }
      if (_activePlaylistId == playlistId) {
        _activePlaylistId = PlaylistService.idAll;
        _currentIndex = 0;
      }
      await PlaylistService.saveCustomPlaylists(_playlists);
      await PlaylistService.saveMediaItems(_allItems);
      notifyListeners();
    }
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final idx = _playlists.indexWhere((p) => p.id == playlistId && !p.isSystem);
    if (idx != -1) {
      _playlists[idx] = _playlists[idx].copyWith(name: newName);
      await PlaylistService.saveCustomPlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> toggleItemInPlaylist(String itemId, String playlistId) async {
    final idx = _allItems.indexWhere((item) => item.id == itemId);
    if (idx != -1) {
      final item = _allItems[idx];
      if (item.playlistIds.contains(playlistId)) {
        item.playlistIds.remove(playlistId);
      } else {
        item.playlistIds.add(playlistId);
      }
      await PlaylistService.saveMediaItems(_allItems);
      notifyListeners();
    }
  }

  // --- REMOVAL & NAVIGATION ---

  void removeVideo(String id) {
    final idx = _allItems.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _allItems.removeAt(idx);
      final currentList = videos;
      if (_currentIndex >= currentList.length) {
        _currentIndex = (currentList.length - 1).clamp(0, 999999);
      }
      _saveMedia();
      notifyListeners();
    }
  }

  Future<void> _saveMedia() async {
    await PlaylistService.saveMediaItems(_allItems);
  }

  void jumpToIndex(int index) {
    final list = videos;
    if (index >= 0 && index < list.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // --- STRICT MP3 & MP4 FILE PICKER ---

  /// Pick only MP3 and MP4 files from local storage - all other media strictly filtered out
  Future<int> pickVideosFromStorage({String? targetPlaylistId}) async {
    _isImporting = true;
    _importStatusMessage = AppStrings.get('loading_files', _currentLanguage);
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return 0;
      }

      _importStatusMessage =
          '${result.files.length} ${AppStrings.get('processing_files', _currentLanguage)}';
      notifyListeners();
      // Allow frame rendering so the user sees the processing counter immediately
      await Future.delayed(const Duration(milliseconds: 60));

      int addedCount = 0;
      final newItems = <VideoItem>[];

      for (final file in result.files) {
        if (file.path != null && file.path!.isNotEmpty) {
          final filePath = file.path!;
          final fileName = file.name;
          final fileSize = file.size;

          // Check if already in library
          final alreadyExists = _allItems.any((v) => v.path == filePath);
          if (!alreadyExists) {
            final mediaType = VideoItem.detectMediaType(filePath);

            final List<String> initialPlaylists = [];
            if (targetPlaylistId != null &&
                targetPlaylistId != PlaylistService.idAll &&
                targetPlaylistId != PlaylistService.idVideo &&
                targetPlaylistId != PlaylistService.idAudio) {
              initialPlaylists.add(targetPlaylistId);
            }

            final mediaItem = VideoItem(
              id: 'local_${DateTime.now().millisecondsSinceEpoch}_${newItems.length}',
              path: filePath,
              title: _cleanFileName(fileName),
              description: '',
              isLocal: true,
              fileSizeBytes: fileSize,
              mediaType: mediaType,
              playlistIds: initialPlaylists,
            );
            newItems.add(mediaItem);
            addedCount++;
          }
        }
      }

      if (newItems.isNotEmpty) {
        _allItems.insertAll(0, newItems);
        _currentIndex = 0;
        await PlaylistService.saveMediaItems(_allItems);
        _importStatusMessage = AppStrings.get('import_success', _currentLanguage);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return addedCount;
    } catch (e) {
      debugPrint('[VideoFeedProvider] Error picking media files: $e');
      return 0;
    } finally {
      _isImporting = false;
      _importStatusMessage = '';
      notifyListeners();
    }
  }

  String _cleanFileName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot != -1) {
      return name.substring(0, dot);
    }
    return name;
  }

  @override
  void dispose() {
    _volumeHudTimer?.cancel();
    super.dispose();
  }
}
