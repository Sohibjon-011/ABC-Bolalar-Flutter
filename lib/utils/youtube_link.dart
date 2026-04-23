class YoutubeLink {
  YoutubeLink._();

  /// Accepts:
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - https://www.youtube.com/shorts/VIDEO_ID
  /// - https://www.youtube.com/embed/VIDEO_ID
  /// - VIDEO_ID directly (11 chars)
  static String extractVideoId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    // Direct ID (most common length is 11)
    final idLike = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (idLike.hasMatch(raw)) return raw;

    Uri? uri;
    try {
      uri = Uri.parse(raw);
    } catch (_) {
      return '';
    }

    // If user pasted without scheme: "youtube.com/watch?v=..."
    if (!uri.hasScheme) {
      try {
        uri = Uri.parse('https://$raw');
      } catch (_) {
        return '';
      }
    }

    final host = (uri.host).toLowerCase();
    final path = uri.path;

    // youtu.be/<id>
    if (host == 'youtu.be') {
      final seg = uri.pathSegments;
      if (seg.isNotEmpty && idLike.hasMatch(seg.first)) return seg.first;
    }

    // youtube.com/watch?v=<id>
    final v = uri.queryParameters['v'];
    if (v != null && idLike.hasMatch(v)) return v;

    // /shorts/<id>, /embed/<id>
    final seg = uri.pathSegments;
    if (seg.length >= 2) {
      final head = seg.first.toLowerCase();
      final second = seg[1];
      if ((head == 'shorts' || head == 'embed') && idLike.hasMatch(second)) {
        return second;
      }
    }

    // Fallback: try to find 11-char id anywhere
    final m = RegExp(r'([a-zA-Z0-9_-]{11})').firstMatch('$host$path${uri.query}');
    if (m != null) return m.group(1) ?? '';
    return '';
  }

  static Uri watchUriFromId(String videoId) {
    final id = videoId.trim();
    return Uri.parse('https://www.youtube.com/watch?v=$id');
  }
}

