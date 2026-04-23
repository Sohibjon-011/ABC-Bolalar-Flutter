import 'package:dio/dio.dart';

class YoutubeOembedService {
  YoutubeOembedService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                sendTimeout: const Duration(seconds: 5),
              ),
            );

  final Dio _dio;

  /// No API key required. Example:
  /// https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=VIDEO_ID&format=json
  Future<({String? title, String? thumbnailUrl})> fetchMeta({required Uri videoUrl}) async {
    final uri = Uri.parse('https://www.youtube.com/oembed').replace(queryParameters: {
      'url': videoUrl.toString(),
      'format': 'json',
    });

    final resp = await _dio.get<Map<String, dynamic>>(uri.toString());
    final data = resp.data;
    if (data == null) return (title: null, thumbnailUrl: null);
    final title = data['title'] as String?;
    final thumb = data['thumbnail_url'] as String?;
    return (title: title, thumbnailUrl: thumb);
  }
}

