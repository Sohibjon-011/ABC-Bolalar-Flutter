import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/youtube_search_item.dart';

class YoutubeResultsCache {
  static const _key = 'yt.cached_results.v1';

  Future<List<YoutubeSearchItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .where((e) => e.videoId.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<YoutubeSearchItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = items.take(60).map(_toJson).toList();
    await prefs.setString(_key, jsonEncode(trimmed));
  }

  Map<String, dynamic> _toJson(YoutubeSearchItem x) => {
        'videoId': x.videoId,
        'title': x.title,
        'channelId': x.channelId,
        'channelTitle': x.channelTitle,
        'description': x.description,
        'thumbnailUrl': x.thumbnailUrl,
        'publishedAt': x.publishedAt?.toIso8601String(),
      };

  YoutubeSearchItem _fromJson(Map<String, dynamic> m) => YoutubeSearchItem(
        videoId: (m['videoId'] as String?) ?? '',
        title: (m['title'] as String?) ?? '',
        channelId: (m['channelId'] as String?) ?? '',
        channelTitle: m['channelTitle'] as String?,
        description: m['description'] as String?,
        thumbnailUrl: m['thumbnailUrl'] as String?,
        publishedAt: (m['publishedAt'] is String)
            ? DateTime.tryParse(m['publishedAt'] as String)
            : null,
      );
}

