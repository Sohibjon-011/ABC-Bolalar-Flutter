import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../models/parent_youtube_video.dart';
import '../../services/parent_youtube_videos_store.dart';
import '../../services/youtube_oembed_service.dart';
import '../../utils/youtube_link.dart';
import '../../widgets/section_intro_card.dart';

class ParentSectionScreen extends StatefulWidget {
  const ParentSectionScreen({super.key});

  @override
  State<ParentSectionScreen> createState() => _ParentSectionScreenState();
}

class _ParentSectionScreenState extends State<ParentSectionScreen> {
  final _linkController = TextEditingController();
  final _store = ParentYoutubeVideosStore();
  final _oembed = YoutubeOembedService();

  YoutubePlayerController? _ytController;
  String _activeVideoId = '';
  String _activeTitle = 'Ota-ona videolari';
  String? _activeSubtitle;
  String? _playerError;

  bool _loading = true;
  bool _adding = false;
  String? _error;
  List<ParentYoutubeVideo> _items = [];

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
    // Ota-ona ekraniga kirganda portrait'ni darhol lock qilamiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    });
    _ytController = YoutubePlayerController(
      params: _ytParams,
      onWebResourceError: (e) {
        if (!mounted) return;
        setState(() => _playerError = '${e.errorCode}: ${e.description}');
      },
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    final list = await _store.load();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
    if (_activeVideoId.isEmpty && list.isNotEmpty) {
      _play(list.first);
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ytController?.close();
    super.dispose();
  }

  void _play(ParentYoutubeVideo item) {
    setState(() {
      _activeVideoId = item.videoId;
      _activeTitle = item.title?.isNotEmpty == true ? item.title! : 'YouTube video';
      _activeSubtitle = item.sourceUrl.isNotEmpty ? item.sourceUrl : null;
      _playerError = null;
    });
    _ytController?.loadVideoById(videoId: item.videoId);
  }

  Future<void> _openInYoutube(String videoId) async {
    final id = videoId.trim();
    if (id.isEmpty) return;
    final uri = YoutubeLink.watchUriFromId(id);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube ochilmadi.')),
      );
    }
  }

  Future<void> _addFromLink() async {
    final input = _linkController.text.trim();
    final videoId = YoutubeLink.extractVideoId(input);
    if (videoId.isEmpty) {
      setState(() => _error = 'Link noto‘g‘ri. YouTube video linkini yuboring.');
      return;
    }

    setState(() {
      _adding = true;
      _error = null;
    });

    void stopLoadingIfMounted() {
      if (!mounted) return;
      setState(() => _adding = false);
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1) Avval darhol qo‘shamiz (telefonda network/osilish bo‘lsa ham ro‘yxatga tushsin).
      final next = [
        ParentYoutubeVideo(
          videoId: videoId,
          sourceUrl: input,
          addedAtMs: now,
          title: 'YouTube video',
          thumbnailUrl: 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
        ),
        ..._items.where((e) => e.videoId != videoId),
      ];

      await _store.save(next).timeout(const Duration(seconds: 3));
      if (!mounted) return;

      setState(() {
        _items = next;
        _adding = false;
        _linkController.clear();
      });
      _play(next.first);

      // 2) Keyin metadata-ni fon rejimida yangilaymiz (bo‘lmasa ham mayli).
      unawaited(() async {
        try {
          final watch = YoutubeLink.watchUriFromId(videoId);
          final meta = await _oembed.fetchMeta(videoUrl: watch).timeout(const Duration(seconds: 6));
          final title = meta.title?.trim();
          final thumb = meta.thumbnailUrl?.trim();
          if (title == null && thumb == null) return;
          if (!mounted) return;

          final updated = _items
              .map((e) => e.videoId == videoId ? e.copyWith(title: title, thumbnailUrl: thumb) : e)
              .toList();
          await _store.save(updated).timeout(const Duration(seconds: 3));
          if (!mounted) return;
          setState(() => _items = updated);
        } catch (_) {
          // ignore
        }
      }());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _adding = false;
        _error = 'Video qo‘shilmadi. Xato: $e';
      });
    } finally {
      // Ba'zi qurilmalarda network so'rovlar osilib qolishi mumkin;
      // yuklanish indikatorini ishonchli yopamiz.
      stopLoadingIfMounted();
    }
  }

  Future<void> _remove(ParentYoutubeVideo item) async {
    final next = _items.where((e) => e.videoId != item.videoId).toList();
    await _store.save(next);
    if (!mounted) return;
    setState(() => _items = next);

    if (_activeVideoId == item.videoId) {
      if (next.isNotEmpty) {
        _play(next.first);
      } else {
        setState(() {
          _activeVideoId = '';
          _activeTitle = 'Ota-ona videolari';
          _activeSubtitle = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mut = Theme.of(context).colorScheme.onSurface.withOpacity(0.72);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ota yoki ona YouTube video linkini qo‘shadi — video ABC-Bololar ichida ko‘rinadi.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: mut, height: 1.5),
        ),
        const SizedBox(height: 12),
        const SectionIntroCard(
          emoji: '👨‍👩‍👧',
          title: 'Ota-ona bo‘limi',
          body: 'YouTube API yo‘q: faqat video linki. Linkni qo‘shing, keyin ro‘yxatdan boshqaring.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _linkController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _adding ? null : _addFromLink(),
          decoration: InputDecoration(
            hintText: 'YouTube link (masalan: https://youtu.be/...)',
            prefixIcon: const Icon(Icons.link_rounded),
            suffixIcon: _adding
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addFromLink,
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
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
                  child: _activeVideoId.isEmpty
                      ? SizedBox(
                          height: 190,
                          child: Center(
                            child: Text(
                              _loading ? 'Yuklanmoqda...' : 'Hali video qo‘shilmagan.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mut),
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            player,
                            if (_playerError != null)
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                  ),
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
                                              onPressed: () => _openInYoutube(_activeVideoId),
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
                _NowPlaying(title: _activeTitle, subtitle: _activeSubtitle),
                const SizedBox(height: 10),
                if (_activeVideoId.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _openInYoutube(_activeVideoId),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('YouTube’da ochish'),
                  ),
                const SizedBox(height: 16),
                Text('Ro‘yxat', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (_items.isEmpty && !_loading)
                  Text(
                    'Video yo‘q. Yuqoriga link qo‘shing.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mut),
                  )
                else
                  _ParentList(
                    items: _items,
                    activeVideoId: _activeVideoId,
                    onSelect: _play,
                    onRemove: _remove,
                    onOpen: (id) => _openInYoutube(id),
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

class _ParentList extends StatelessWidget {
  const _ParentList({
    required this.items,
    required this.activeVideoId,
    required this.onSelect,
    required this.onRemove,
    required this.onOpen,
  });

  final List<ParentYoutubeVideo> items;
  final String activeVideoId;
  final ValueChanged<ParentYoutubeVideo> onSelect;
  final ValueChanged<ParentYoutubeVideo> onRemove;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = item.videoId == activeVideoId;
        final title = item.title?.isNotEmpty == true ? item.title! : 'YouTube video';
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
            title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              selected ? 'Hozir ijro etilmoqda' : 'YouTube',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'YouTube’da ochish',
                  onPressed: () => onOpen(item.videoId),
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
                IconButton(
                  tooltip: "O'chirish",
                  onPressed: () => onRemove(item),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            onTap: () => onSelect(item),
          ),
        );
      },
    );
  }
}

