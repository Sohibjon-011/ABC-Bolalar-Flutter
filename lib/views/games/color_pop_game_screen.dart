import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/fx_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/toast_provider.dart';
import 'game_scaffold.dart';

class ColorPopGameScreen extends StatefulWidget {
  const ColorPopGameScreen({super.key});

  @override
  State<ColorPopGameScreen> createState() => _ColorPopGameScreenState();
}

class _ColorPopGameScreenState extends State<ColorPopGameScreen> {
  final _lit = List<bool>.filled(6, false);
  static const _colors = [
    Color(0xFFFF4D6D),
    Color(0xFFFFB703),
    Color(0xFF00BBF9),
    Color(0xFF9B5DE5),
    Color(0xFF2EC4B6),
    Color(0xFF06D6A0),
  ];

  void _onTap(int i) {
    if (_lit[i]) return;
    HapticFeedback.lightImpact();
    setState(() => _lit[i] = true);
    if (_lit.every((e) => e)) {
      context.read<FxProvider>().correct();
      context.read<ToastProvider>().push('🌈', 'Gul ochildi — zo‘r!');
      context.read<LevelProvider>().addXP(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = _lit.every((e) => e);

    return GameScaffold(
      frameAccent: const Color(0xFFFF4D6D),
      title: 'Ranglar guli',
      subtitle: 'Barcha ranglarni «yoqing»',
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: done ? 1 : 0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, t, child) {
                  return Transform.rotate(
                    angle: t * 0.08,
                    child: Transform.scale(
                      scale: 1 + t * 0.06,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  done ? '🌸' : '🌼',
                  style: TextStyle(
                    fontSize: done ? 102 : 72,
                    shadows: [
                      Shadow(
                        color: _colors[3].withOpacity(done ? 0.55 : 0.2),
                        blurRadius: done ? 28 : 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_colors.length, (i) {
              final on = _lit[i];
              return GestureDetector(
                onTap: () => _onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? _colors[i] : cs.surfaceContainerHighest,
                    border: Border.all(
                      color: on ? Colors.white.withOpacity(0.55) : _colors[i].withOpacity(0.55),
                      width: on ? 3 : 2,
                    ),
                    boxShadow: on
                        ? [
                            BoxShadow(
                              color: _colors[i].withOpacity(0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: on
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 30)
                        : Icon(Icons.star_rounded, color: _colors[i].withOpacity(0.88), size: 26),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                for (var j = 0; j < _lit.length; j++) {
                  _lit[j] = false;
                }
              });
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Qayta boshlash'),
          ),
        ],
      ),
    );
  }
}
