import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learn_item.dart';
import '../../providers/audio_provider.dart';
import '../../providers/fx_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/toast_provider.dart';

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  final _rand = Random();

  late final List<LearnItem> _nums = List.generate(10, (i) {
    final n = i + 1;
    const icons = {
      1: '⚽',
      2: '👀',
      3: '🔺',
      4: '🪑',
      5: '🖐️',
      6: '🐞',
      7: '🌈',
      8: '🐙',
      9: '🎯',
      10: '🖐️🖐️',
    };
    return LearnItem(
      id: 'n$n',
      big: '$n',
      emoji: icons[n]!,
      dots: n,
      audioNumber: 30 + i,
    );
  });

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
    final set = _shuffle(_nums).take(k).toList(growable: false);
    final ans = set[_rand.nextInt(set.length)];
    setState(() {
      _promptId = ans.id;
      _choices = _shuffle(set.map((x) => LearnItem(
            id: x.id,
            big: x.big,
            emoji: x.emoji,
            dots: min(x.dots ?? 0, 12),
            audioNumber: x.audioNumber,
          )).toList(growable: false));
    });
  }

  Future<void> _speakPrompt() async {
    final it = _nums.where((x) => x.id == _promptId).cast<LearnItem?>().firstOrNull;
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
          title: '🔢 Raqamlar',
          subtitle: '1–10',
          buttonEmoji: '▶️',
          buttonText: 'Hammasini ijro etish',
          disabled: _playingAll,
          gradient: const [Color(0xFF00BBF9), Color(0xFF9B5DE5), Color(0xFFFF4D6D)],
          onPressed: () async {
            setState(() {
              _playingAll = true;
              _activeId = null;
            });
            final list = _nums.map((x) => _audioPath(x.audioNumber)).toList(growable: false);
            await context.read<AudioProvider>().playSequence(
              list,
              onStep: (i) => setState(() => _activeId = _nums[i].id),
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
            final cols = c.maxWidth >= 900 ? 6 : (c.maxWidth >= 520 ? 4 : 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: _nums.length,
              itemBuilder: (context, i) {
                final it = _nums[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () async {
                    setState(() => _activeId = it.id);
                    await context.read<AudioProvider>().playAsset(_audioPath(it.audioNumber));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: _activeId == it.id ? 60 : 30,
                          offset: const Offset(0, 18),
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(it.emoji ?? '', style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(it.big, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
                      ],
                    ),
                  ),
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
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🎮 Raqam o\'yini', style: TextStyle(fontWeight: FontWeight.w900)),
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
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: List.generate(it.dots ?? 0, (_) {
                                  return Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(colors: [Color(0xFFFF4D6D), Color(0xFF00BBF9)]),
                                      boxShadow: [BoxShadow(blurRadius: 18, offset: const Offset(0, 10), color: Colors.black.withOpacity(0.10))],
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Text(it.big, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
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

