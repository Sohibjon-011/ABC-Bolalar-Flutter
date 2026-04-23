class ParentYoutubeVideo {
  const ParentYoutubeVideo({
    required this.videoId,
    required this.sourceUrl,
    required this.addedAtMs,
    this.title,
    this.thumbnailUrl,
  });

  final String videoId;
  final String sourceUrl;
  final int addedAtMs;
  final String? title;
  final String? thumbnailUrl;

  ParentYoutubeVideo copyWith({
    String? title,
    String? thumbnailUrl,
  }) {
    return ParentYoutubeVideo(
      videoId: videoId,
      sourceUrl: sourceUrl,
      addedAtMs: addedAtMs,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'sourceUrl': sourceUrl,
        'addedAtMs': addedAtMs,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
      };

  static ParentYoutubeVideo? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    final videoId = (m['videoId'] as String?) ?? '';
    final sourceUrl = (m['sourceUrl'] as String?) ?? '';
    final addedAtMs = (m['addedAtMs'] is int) ? (m['addedAtMs'] as int) : int.tryParse('${m['addedAtMs']}') ?? 0;
    if (videoId.isEmpty) return null;
    return ParentYoutubeVideo(
      videoId: videoId,
      sourceUrl: sourceUrl,
      addedAtMs: addedAtMs == 0 ? DateTime.now().millisecondsSinceEpoch : addedAtMs,
      title: m['title'] as String?,
      thumbnailUrl: m['thumbnailUrl'] as String?,
    );
  }
}

