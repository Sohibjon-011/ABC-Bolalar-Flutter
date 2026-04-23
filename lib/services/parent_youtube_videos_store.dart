import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/parent_youtube_video.dart';

class ParentYoutubeVideosStore {
  static const _key = 'parents.youtube_videos.v1';

  Future<List<ParentYoutubeVideo>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final out = decoded.map(ParentYoutubeVideo.fromJson).whereType<ParentYoutubeVideo>().toList();
      out.sort((a, b) => b.addedAtMs.compareTo(a.addedAtMs));
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ParentYoutubeVideo> items) async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences katta bo'lsa sekinlashishi mumkin, lekin ota-ona "xohlagancha"
    // qo'sha olishi uchun limitni ancha keng qoldiramiz.
    final trimmed = items.take(1000).map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(trimmed));
  }
}

