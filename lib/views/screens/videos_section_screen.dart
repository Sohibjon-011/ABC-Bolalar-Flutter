import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../data/default_youtube_videos.dart';
import '../../models/parent_youtube_video.dart';
import '../../models/youtube_search_item.dart';
import '../../services/parent_youtube_videos_store.dart';
import '../../services/youtube_results_cache.dart';
import '../../utils/youtube_link.dart';
import '../../widgets/section_intro_card.dart';

class VideosSectionScreen extends StatefulWidget {
  const VideosSectionScreen({super.key});

  @override
  State<VideosSectionScreen> createState() => _VideosSectionScreenState();
}

class _VideosSectionScreenState extends State<VideosSectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ParentYoutubeVideosStore _parentsStore = ParentYoutubeVideosStore();
  final YoutubeResultsCache _cache = YoutubeResultsCache();
  Timer? _debounce;

  YoutubePlayerController? _ytController;
  String _activeVideoId = '';
  String _activeTitle = 'Videolar';
  String? _activeSubtitle;
  String? _playerError;

  bool _searching = false;
  String? _searchError;
  final List<YoutubeSearchItem> _results = [];
  String _lastQuery = '';

  static const _ytParams = YoutubePlayerParams(
    mute: false,
    showControls: true,
    showFullscreenButton: true,
    strictRelatedVideos: true,
    showVideoAnnotations: false,
    interfaceLanguage: 'uz',
    // Android/WebView ichida embed cheklovlarini kamaytirish uchun origin beramiz.
    origin: 'https://www.youtube-nocookie.com',
  );

  @override
  void initState() {
    super.initState();
    // Videolar ekraniga kirganda portrait'ni darhol lock qilamiz (ba'zi qurilmalarda WebView aylantirib yuboradi).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    });
    // Boshlang'ich: ota-ona qo'shgan video + kesh/default, qidiruv lokal filtr.
    _ytController = YoutubePlayerController(
      params: _ytParams,
      onWebResourceError: (e) {
        if (!mounted) return;
        setState(() => _playerError = '${e.errorCode}: ${e.description}');
      },
    );
    _activeSubtitle = 'Videolar link asosida (ota-ona qo‘shgan).';
    _searchController.addListener(_onSearchChanged);
    unawaited(_loadAll());
  }

  Future<void> _loadAll() async {
    final parents = await _parentsStore.load();
    final cached = await _cache.load();
    if (!mounted) return;

    final list = _dedupe([
      ..._toSearchItemsFromParents(parents),
      ...cached,
      ...kDefaultYoutubeVideos,
    ]);

    setState(() {
      _results
        ..clear()
        ..addAll(list);
    });
    if (_activeVideoId.isEmpty) {
      if (list.isNotEmpty) _play(list.first);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 520), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _searchController.text.trim();
    if (q.length < 2) {
      if (!mounted) return;
      setState(() {
        _searchError = null;
        _searching = false;
      });
      unawaited(_loadAll());
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
      _lastQuery = q;
    });

    try {
      final parents = await _parentsStore.load();
      final cached = await _cache.load();
      if (!mounted) return;
      final base = [
        ..._toSearchItemsFromParents(parents),
        ...cached,
        ...kDefaultYoutubeVideos,
        ..._results,
      ];
      final filtered = _filterByQuery(_dedupe(base), q);
      setState(() {
        _results
          ..clear()
          ..addAll(filtered);
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      final parents = await _parentsStore.load();
      final cached = await _cache.load();
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchError = 'Qidiruvda xato yuz berdi. Keyinroq urinib ko‘ring.';
        _results
          ..clear()
          ..addAll(_dedupe([
            ..._toSearchItemsFromParents(parents),
            ...cached,
            ...kDefaultYoutubeVideos,
          ]));
      });
    }
  }

  List<YoutubeSearchItem> _toSearchItemsFromParents(List<ParentYoutubeVideo> items) {
    return items
        .where((e) => e.videoId.isNotEmpty)
        .map(
          (e) => YoutubeSearchItem(
            videoId: e.videoId,
            title: (e.title != null && e.title!.trim().isNotEmpty) ? e.title!.trim() : 'YouTube video',
            channelId: 'parents',
            channelTitle: 'Ota-ona',
            description: e.sourceUrl,
            thumbnailUrl: e.thumbnailUrl ?? 'https://i.ytimg.com/vi/${e.videoId}/hqdefault.jpg',
            publishedAt: null,
          ),
        )
        .toList();
  }

  List<YoutubeSearchItem> _dedupe(List<YoutubeSearchItem> list) {
    final byId = <String, YoutubeSearchItem>{};
    for (final item in list) {
      if (item.videoId.isEmpty) continue;
      byId.putIfAbsent(item.videoId, () => item);
    }
    return byId.values.toList();
  }

  List<YoutubeSearchItem> _filterByQuery(List<YoutubeSearchItem> list, String query) {
    final tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.trim().isNotEmpty)
        .toList();
    if (tokens.isEmpty) return list;

    bool matches(YoutubeSearchItem item) {
      final hay = _normalize('${item.title} ${item.description ?? ''}');
      for (final t in tokens) {
        if (!hay.contains(_normalize(t))) return false;
      }
      return true;
    }

    final out = list.where(matches).toList();
    return out;
  }

  String _normalize(String s) {
    // Oddiy normalizatsiya: kichik harf + HTML entitylarni soddalashtirish.
    return s
        .toLowerCase()
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        // Raw stringda `"` ni ishlatmaymiz (r"..." ichida \" escape bo'lmaydi).
        .replaceAll(RegExp(r"[^a-z0-9\u0400-\u04FF\u0100-\u017Fʻ’'& ]+"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // Ekrandan chiqqanda UI'ni tiklaymiz (portrait lock ilovada qoladi, fullscreen esa paket ichida boshqariladi).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ytController?.close();
    super.dispose();
  }

  void _play(YoutubeSearchItem item) {
    setState(() {
      _activeVideoId = item.videoId;
      _activeTitle = item.title;
      _activeSubtitle = item.channelTitle;
      _playerError = null;
    });
    _ytController?.loadVideoById(videoId: item.videoId);
  }

  Future<void> _openInYoutube() async {
    final id = _activeVideoId.trim();
    if (id.isEmpty) return;
    final uri = YoutubeLink.watchUriFromId(id);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube ochilmadi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mut = Theme.of(context).colorScheme.onSurface.withOpacity(0.72);
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Videolar ota-ona qo‘shgan YouTube linklaridan ko‘rsatiladi. Qidiruv — lokal filtr.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: mut, height: 1.5),
        ),
        const SizedBox(height: 12),
        const SectionIntroCard(
          emoji: '🎬',
          title: 'YouTube videolar',
          body:
              'Ota-ona qo‘shgan YouTube videolar shu yerda ko‘rinadi. Manage (o‘chirish) esa Ota-ona bo‘limida.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _runSearch(),
          decoration: InputDecoration(
            hintText: 'Masalan: harflar, sonlar, ranglar...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: _runSearch,
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
        ),
        const SizedBox(height: 10),
        if (_searchError != null) ...[
          const SizedBox(height: 8),
          Text(
            _searchError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );

    return YoutubePlayerScaffold(
      controller: _ytController!,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      player,
                      if (_playerError != null && _activeVideoId.isNotEmpty)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.55)),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.warning_rounded, color: Colors.white, size: 34),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Bu video ilova ichida ochilmadi.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'YouTube’da ochib tomosha qiling.\n($_playerError)',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 12),
                                      FilledButton.icon(
                                        onPressed: _openInYoutube,
                                        icon: const Icon(Icons.open_in_new_rounded),
                                        label: const Text('YouTube’da ochish'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _NowPlaying(
                  title: _activeTitle,
                  subtitle: _activeSubtitle,
                ),
                const SizedBox(height: 10),
                if (_activeVideoId.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _openInYoutube,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('YouTube’da ochish (agar player ishlamasa)'),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Natijalar',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_results.isEmpty && _searchController.text.trim().length >= 2 && !_searching)
                  Text(
                    'Natija topilmadi.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mut),
                  )
                else
                  _ResultsList(
                    items: _results.take(6).toList(),
                    activeVideoId: _activeVideoId,
                    onSelect: _play,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.isEmpty ? '—' : title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.75),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.items,
    required this.activeVideoId,
    required this.onSelect,
  });

  final List<YoutubeSearchItem> items;
  final String activeVideoId;
  final ValueChanged<YoutubeSearchItem> onSelect;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = item.videoId == activeVideoId;
        return Card(
          color: selected ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4) : null,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 88,
                height: 50,
                child: item.thumbnailUrl != null
                    ? Image.network(
                        item.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Colors.black26,
                          child: Icon(Icons.movie_outlined),
                        ),
                      )
                    : const ColoredBox(
                        color: Colors.black26,
                        child: Icon(Icons.movie_outlined),
                      ),
              ),
            ),
            title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              selected ? 'Hozir ijro etilmoqda' : (item.channelTitle ?? 'Kanal'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: 'YouTube link',
              onPressed: () => launchUrl(
                YoutubeLink.watchUriFromId(item.videoId),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.link_rounded),
            ),
            onTap: () => onSelect(item),
          ),
        );
      },
    );
  }
}
