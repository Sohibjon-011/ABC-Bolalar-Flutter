import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learn_item.dart';
import '../../providers/audio_provider.dart';
import '../../providers/fx_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/game_card.dart';

class AbcScreen extends StatefulWidget {
  const AbcScreen({super.key});

  @override
  State<AbcScreen> createState() => _AbcScreenState();
}

class _AbcScreenState extends State<AbcScreen> {
  final _rand = Random();

  final List<LearnItem> _letters = const [
    LearnItem(id: 'a', big: 'A', small: 'Apelsin', emoji: '🍊', audioNumber: 1),
    LearnItem(id: 'b', big: 'B', small: 'Baliq', emoji: '🐟', audioNumber: 2),
    LearnItem(id: 'd', big: 'D', small: 'Daraxt', emoji: '🌳', audioNumber: 3),
    LearnItem(id: 'e', big: 'E', small: 'Eshik', emoji: '🚪', audioNumber: 4),
    LearnItem(id: 'f', big: 'F', small: 'Futbol', emoji: '⚽', audioNumber: 5),
    LearnItem(id: 'g', big: 'G', small: 'Gul', emoji: '🌹', audioNumber: 6),
    LearnItem(id: 'h', big: 'H', small: 'Hayvon', emoji: '🐻', audioNumber: 7),
    LearnItem(id: 'i', big: 'I', small: 'Ilon', emoji: '🐍', audioNumber: 8),
    LearnItem(id: 'j', big: 'J', small: 'Jiraffa', emoji: '🦒', audioNumber: 9),
    LearnItem(id: 'k', big: 'K', small: 'Kitob', emoji: '📖', audioNumber: 10),
    LearnItem(id: 'l', big: 'L', small: 'Lampa', emoji: '💡', audioNumber: 11),
    LearnItem(id: 'm', big: 'M', small: 'Mashina', emoji: '🚗', audioNumber: 12),
    LearnItem(id: 'n', big: 'N', small: 'Non', emoji: '🍞', audioNumber: 13),
    LearnItem(id: 'o', big: 'O', small: 'Oy', emoji: '🌙', audioNumber: 14),
    LearnItem(id: 'p', big: 'P', small: 'Poyezd', emoji: '🚆', audioNumber: 15),
    LearnItem(id: 'q', big: 'Q', small: 'Qush', emoji: '🐦', audioNumber: 28),
    LearnItem(id: 'r', big: 'R', small: 'Raketa', emoji: '🚀', audioNumber: 16),
    LearnItem(id: 's', big: 'S', small: 'Sut', emoji: '🥛', audioNumber: 17),
    LearnItem(id: 't', big: 'T', small: 'Telefon', emoji: '📱', audioNumber: 18),
    LearnItem(id: 'u', big: 'U', small: 'Uzuk', emoji: '💍', audioNumber: 19),
    LearnItem(id: 'v', big: 'V', small: 'Velosiped', emoji: '🚲', audioNumber: 20),
    LearnItem(id: 'x', big: 'X', small: 'Xarita', emoji: '🗺️', audioNumber: 21),
    LearnItem(id: 'y', big: 'Y', small: 'Yulduz', emoji: '⭐', audioNumber: 22),
    LearnItem(id: 'z', big: 'Z', small: 'Zebra', emoji: '🦓', audioNumber: 23),
    LearnItem(id: 'o2', big: "O'", small: "O'rdak", emoji: '🦆', audioNumber: 26),
    LearnItem(
      id: 'g2',
      big: "G'",
      small: "G'oz",
      emoji: '🦢',
      displayIcon: Icons.egg_outlined,
      audioNumber: 27,
    ),
    LearnItem(
      id: 'sh',
      big: 'SH',
      small: 'Shar',
      emoji: '🎈',
      displayIcon: Icons.celebration_outlined,
      audioNumber: 24,
    ),
    LearnItem(id: 'ch', big: 'Ch', small: 'Choynak', emoji: '🫖', audioNumber: 25),
    LearnItem(id: 'ng', big: 'NG', small: 'Bodring', emoji: '🥒', audioNumber: 29),
  ];

  String? _activeId;
  bool _playingAll = false;

  int _level = 1;
  String? _promptId;
  List<LearnItem> _choices = const [];

  String _audioPath(int n) => 'public/MP4/$n.ogg';

  List<T> _shuffle<T>(List<T> a) {
    final x = List<T>.from(a);
    for (var i = x.length - 1; i > 0; i--) {
      final j = _rand.nextInt(i + 1);
      final tmp = x[i];
      x[i] = x[j];
      x[j] = tmp;
    }
    return x;
  }

  void _makeRound() {
    final k = min(2 + (_level ~/ 2), 5);
    final set = _shuffle(_letters).take(k).toList(growable: false);
    final ans = set[_rand.nextInt(set.length)];
    setState(() {
      _promptId = ans.id;
      _choices = _shuffle(set);
    });
  }

  Future<void> _speakPrompt() async {
    final it = _letters.where((x) => x.id == _promptId).cast<LearnItem?>().firstOrNull;
    if (it == null) return;
    await context.read<AudioProvider>().playAsset(_audioPath(it.audioNumber));
  }

  Future<void> _choose(LearnItem c) async {
    if (c.id == _promptId) {
      final xpReward = _level * 10;
      context.read<ToastProvider>().push('🎉', '+$xpReward XP olindi!');
      await context.read<LevelProvider>().addXP(xpReward);
      context.read<FxProvider>().correct();

      setState(() {
        if (_level < 10) {
          _level += 1;
        } else {
          context.read<ToastProvider>().push('🏆', '10 bosqich tugallandi!');
          _level = 1;
        }
      });
      _makeRound();
    } else {
      context.read<ToastProvider>().push('😺', 'Yana bir bor urinib ko\'ring!');
      await _speakPrompt();
    }
  }

  @override
  void initState() {
    super.initState();
    _makeRound();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      children: [
        _HeroCard(
          title: '🔤 Alifbo',
          subtitle: 'Bos → ovoz 🎵',
          buttonEmoji: '▶️',
          buttonText: 'Hammasini ijro etish',
          disabled: _playingAll,
          gradient: const [Color(0xFFFF4D6D), Color(0xFFFFB703), Color(0xFF00BBF9)],
          onPressed: () async {
            setState(() {
              _playingAll = true;
              _activeId = null;
            });
            final list = _letters.map((x) => _audioPath(x.audioNumber)).toList(growable: false);
            await context.read<AudioProvider>().playSequence(
              list,
              onStep: (i) => setState(() => _activeId = _letters[i].id),
            );
            if (!mounted) return;
            setState(() {
              _playingAll = false;
              _activeId = null;
            });
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cols = w >= 860 ? 5 : (w >= 520 ? 3 : 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemCount: _letters.length,
              itemBuilder: (context, i) {
                final it = _letters[i];
                return GameCard(
                  big: it.big,
                  small: it.small,
                  emoji: it.emoji,
                  displayIcon: it.displayIcon,
                  image: null,
                  active: _activeId == it.id,
                  onTap: () async {
                    setState(() => _activeId = it.id);
                    await context.read<AudioProvider>().playAsset(_audioPath(it.audioNumber));
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
            boxShadow: [BoxShadow(blurRadius: 50, offset: const Offset(0, 20), color: Colors.black.withOpacity(0.12))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🎮 Alifbo o\'yini', style: TextStyle(fontWeight: FontWeight.w900)),
                  Text('Bosqich: $_level/10', style: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.9))),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: FilledButton(
                  onPressed: _speakPrompt,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔊', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Text('TOP!', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth >= 520 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _choices.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, i) {
                      final it = _choices[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => _choose(it),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (it.displayIcon != null)
                                Icon(it.displayIcon, size: 44, color: cs.primary)
                              else
                                Text(it.emoji ?? '', style: const TextStyle(fontSize: 44)),
                              const SizedBox(height: 8),
                              Text(it.big, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.buttonEmoji,
    required this.buttonText,
    required this.disabled,
    required this.gradient,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonEmoji;
  final String buttonText;
  final bool disabled;
  final List<Color> gradient;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        boxShadow: [BoxShadow(blurRadius: 50, offset: const Offset(0, 20), color: Colors.black.withOpacity(0.12))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.85), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: disabled ? null : onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              backgroundColor: gradient.first,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) return cs.onSurface.withOpacity(0.12);
                return null;
              }),
            ),
            child: Row(
              children: [
                Text(buttonEmoji),
                const SizedBox(width: 10),
                Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

