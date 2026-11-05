import 'dart:convert';
import 'package:flutter/material.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final int iconCode;
  final int colorValue;
  final bool isSystem;
  final DateTime createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    this.description = '',
    this.iconCode = 0xe6e2,
    this.colorValue = 0xFF00F2FE,
    this.isSystem = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  IconData get iconData {
    switch (iconCode) {
      case 0xe6a8:
        return Icons.video_collection_rounded;
      case 0xe415:
        return Icons.music_note_rounded;
      case 0xe25b:
        return Icons.favorite_rounded;
      case 0xe6e2:
      default:
        return Icons.queue_music_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isSystem': isSystem,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconCode: map['iconCode'] ?? 0xe6e2,
      colorValue: map['colorValue'] ?? 0xFF00F2FE,
      isSystem: map['isSystem'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaylistModel.fromJson(String source) =>
      PlaylistModel.fromMap(json.decode(source));

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCode,
    int? colorValue,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
