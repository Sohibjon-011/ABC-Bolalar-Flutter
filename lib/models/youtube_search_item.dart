class YoutubeSearchItem {
  const YoutubeSearchItem({
    required this.videoId,
    required this.title,
    required this.channelId,
    this.channelTitle,
    this.description,
    this.thumbnailUrl,
    this.publishedAt,
  });

  final String videoId;
  final String title;
  final String channelId;
  final String? channelTitle;
  final String? description;
  final String? thumbnailUrl;
  final DateTime? publishedAt;
}

