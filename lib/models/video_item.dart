import 'dart:convert';

enum MediaType {
  video,
  audio,
}

class VideoItem {
  final String id;
  final String path; // Local absolute file path
  final String title;
  final String description;
  final int durationSeconds;
  final bool isLocal;
  final int fileSizeBytes;
  final MediaType mediaType;
  final List<String> playlistIds;
  final DateTime addedAt;

  VideoItem({
    required this.id,
    required this.path,
    required this.title,
    this.description = '',
    this.durationSeconds = 0,
    this.isLocal = true,
    this.fileSizeBytes = 0,
    MediaType? mediaType,
    List<String>? playlistIds,
    DateTime? addedAt,
  })  : mediaType = mediaType ?? detectMediaType(path),
        playlistIds = playlistIds ?? [],
        addedAt = addedAt ?? DateTime.now();

  static MediaType detectMediaType(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.mp3')) {
      return MediaType.audio;
    }
    return MediaType.video;
  }

  bool get isAudio => mediaType == MediaType.audio;
  bool get isVideo => mediaType == MediaType.video;

  String get fileExtension => isAudio ? 'MP3' : 'MP4';

  String get formattedSize {
    if (fileSizeBytes <= 0) return '';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'description': description,
      'durationSeconds': durationSeconds,
      'isLocal': isLocal,
      'fileSizeBytes': fileSizeBytes,
      'mediaType': mediaType.name,
      'playlistIds': playlistIds,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    final typeStr = map['mediaType'] as String?;
    final mediaType = typeStr != null
        ? (typeStr == 'audio' ? MediaType.audio : MediaType.video)
        : VideoItem.detectMediaType(map['path'] ?? '');

    final dynamic rawPlaylists = map['playlistIds'];
    final List<String> playlistIds = rawPlaylists is List
        ? rawPlaylists.map((e) => e.toString()).toList()
        : [];

    return VideoItem(
      id: map['id'] ?? '',
      path: map['path'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      isLocal: map['isLocal'] ?? true,
      fileSizeBytes: map['fileSizeBytes'] ?? 0,
      mediaType: mediaType,
      playlistIds: playlistIds,
      addedAt: map['addedAt'] != null
          ? DateTime.tryParse(map['addedAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoItem.fromJson(String source) =>
      VideoItem.fromMap(json.decode(source));

  VideoItem copyWith({
    String? id,
    String? path,
    String? title,
    String? description,
    int? durationSeconds,
    bool? isLocal,
    int? fileSizeBytes,
    MediaType? mediaType,
    List<String>? playlistIds,
    DateTime? addedAt,
  }) {
    return VideoItem(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isLocal: isLocal ?? this.isLocal,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mediaType: mediaType ?? this.mediaType,
      playlistIds: playlistIds ?? List.from(this.playlistIds),
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
