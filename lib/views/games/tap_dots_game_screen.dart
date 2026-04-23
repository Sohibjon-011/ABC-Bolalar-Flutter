import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/fx_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/toast_provider.dart';
import 'game_scaffold.dart';

/// Bolalar nuqtalarni 1→2→3 tartibida bosadi; xatolar va muvaffaqiyatga qarab emoji.
class TapDotsGameScreen extends StatefulWidget {
  const TapDotsGameScreen({super.key});

  @override
  State<TapDotsGameScreen> createState() => _TapDotsGameScreenState();
}

class _TapDotsGameScreenState extends State<TapDotsGameScreen> with SingleTickerProviderStateMixin {
  /// Har bir element — 1→6 tartibidagi nuqta joylari (ekran nisbati 0–1).
  static const _presets = <List<Offset>>[
    [
      Offset(0.14, 0.72),
      Offset(0.32, 0.28),
      Offset(0.52, 0.62),
      Offset(0.68, 0.22),
      Offset(0.86, 0.55),
      Offset(0.48, 0.88),
    ],
    [
      Offset(0.5, 0.14),
      Offset(0.82, 0.32),
      Offset(0.78, 0.62),
      Offset(0.5, 0.5),
      Offset(0.22, 0.62),
      Offset(0.18, 0.32),
    ],
    [
      Offset(0.12, 0.2),
      Offset(0.45, 0.18),
      Offset(0.78, 0.28),
      Offset(0.72, 0.55),
      Offset(0.4, 0.72),
      Offset(0.15, 0.55),
    ],
    [
      Offset(0.85, 0.2),
      Offset(0.55, 0.35),
      Offset(0.25, 0.25),
      Offset(0.2, 0.58),
      Offset(0.5, 0.75),
      Offset(0.82, 0.72),
    ],
    [
      Offset(0.5, 0.88),
      Offset(0.22, 0.68),
      Offset(0.18, 0.38),
      Offset(0.48, 0.22),
      Offset(0.8, 0.38),
      Offset(0.78, 0.68),
    ],
    [
      Offset(0.2, 0.15),
      Offset(0.2, 0.45),
      Offset(0.2, 0.75),
      Offset(0.55, 0.75),
      Offset(0.82, 0.48),
      Offset(0.55, 0.2),
    ],
    [
      Offset(0.78, 0.15),
      Offset(0.5, 0.35),
      Offset(0.22, 0.2),
      Offset(0.15, 0.52),
      Offset(0.42, 0.78),
      Offset(0.75, 0.82),
    ],
    [
      Offset(0.5, 0.2),
      Offset(0.75, 0.38),
      Offset(0.68, 0.65),
      Offset(0.5, 0.82),
      Offset(0.32, 0.65),
      Offset(0.25, 0.38),
    ],
    [
      Offset(0.15, 0.35),
      Offset(0.4, 0.2),
      Offset(0.7, 0.22),
      Offset(0.82, 0.5),
      Offset(0.55, 0.72),
      Offset(0.22, 0.78),
    ],
    [
      Offset(0.82, 0.42),
      Offset(0.58, 0.22),
      Offset(0.3, 0.28),
      Offset(0.18, 0.55),
      Offset(0.38, 0.78),
      Offset(0.68, 0.78),
    ],
    [
      Offset(0.48, 0.12),
      Offset(0.22, 0.32),
      Offset(0.35, 0.58),
      Offset(0.62, 0.52),
      Offset(0.78, 0.3),
      Offset(0.52, 0.82),
    ],
    [
      Offset(0.25, 0.82),
      Offset(0.15, 0.48),
      Offset(0.42, 0.22),
      Offset(0.72, 0.18),
      Offset(0.82, 0.52),
      Offset(0.55, 0.78),
    ],
  ];

  final _rand = math.Random();
  late List<Offset> _layout;
  int? _lastPresetIdx;

  var _nextIndex = 0;
  var _mistakes = 0;
  var _finished = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void initState() {
    super.initState();
    _layout = _randomLayout();
  }

  /// Yangi mashq: boshqa naqsh (ketma-ket bir xil bo‘lmasin).
  List<Offset> _randomLayout() {
    if (_presets.isEmpty) return [const Offset(0.5, 0.5)];
    int idx;
    var guard = 0;
    do {
      idx = _rand.nextInt(_presets.length);
      guard++;
    } while (_presets.length > 1 && idx == _lastPresetIdx && guard < 24);
    _lastPresetIdx = idx;
    return List<Offset>.from(_presets[idx]);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() {
      _layout = _randomLayout();
      _nextIndex = 0;
      _mistakes = 0;
      _finished = false;
    });
  }

  void _onDotTap(int orderIndex) {
    if (_finished) return;
    if (orderIndex == _nextIndex) {
      HapticFeedback.lightImpact();
      setState(() => _nextIndex++);
      if (_nextIndex >= _layout.length) {
        _completeRound();
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _mistakes++);
      _shake.forward(from: 0);
    }
  }

  Future<void> _completeRound() async {
    setState(() => _finished = true);
    final tier = _resultTier();
    context.read<ToastProvider>().push(tier.emoji, tier.title);
    if (tier.showFx) {
      context.read<FxProvider>().correct();
    }
    final xp = tier.xp;
    if (xp > 0) {
      await context.read<LevelProvider>().addXP(xp);
    }
  }

  _ResultTier _resultTier() {
    if (_mistakes == 0) {
      return const _ResultTier(emoji: '🤩', title: 'Mukammal!', subtitle: 'Hech xato yo‘q', xp: 6, showFx: true);
    }
    if (_mistakes <= 2) {
      return const _ResultTier(emoji: '😊', title: 'Zo‘r!', subtitle: 'Yaxshi o‘ynadingiz', xp: 4, showFx: true);
    }
    if (_mistakes <= 5) {
      return const _ResultTier(emoji: '👍', title: 'Yaxshi!', subtitle: 'Yana mashq qiling', xp: 2, showFx: false);
    }
    return const _ResultTier(emoji: '🌱', title: 'Gap yo‘q!', subtitle: 'Qayta urinib ko‘ring', xp: 1, showFx: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GameScaffold(
      frameAccent: const Color(0xFF7C3AED),
      title: 'Nuqta izi',
      subtitle: 'Har safar yangi naqsh — 1 dan tartib bilan bosing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StatChip(icon: Icons.flag_rounded, label: 'Nuqta', value: '${_layout.length}'),
              const SizedBox(width: 8),
              _StatChip(icon: Icons.bolt_rounded, label: 'Xato', value: '$_mistakes'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final v = _shake.value;
                final dx = (v * (1 - v) * 20) * (v < 0.5 ? 1 : -1);
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final h = c.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(w, h),
                        painter: _DotTrailPainter(
                          layout: _layout,
                          completedCount: _finished ? _layout.length : _nextIndex,
                          width: w,
                          height: h,
                          lineColor: cs.primary.withOpacity(0.55),
                        ),
                      ),
                      ...List.generate(_layout.length, (i) {
                        final o = _layout[i];
                        final cx = o.dx * w;
                        final cy = o.dy * h;
                        final done = i < _nextIndex;
                        final active = i == _nextIndex && !_finished;
                        return Positioned(
                          left: cx - 34,
                          top: cy - 34,
                          child: _DotButton(
                            order: i + 1,
                            done: done,
                            active: active,
                            enabled: !_finished,
                            accent: cs.primary,
                            tertiary: cs.tertiary,
                            onTap: () => _onDotTap(i),
                          ),
                        );
                      }),
                      if (_finished)
                        Positioned.fill(
                          child: Center(
                            child: _ResultCard(tier: _resultTier(), onPlayAgain: _reset),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surfaceContainerHighest.withOpacity(0.75),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DotButton extends StatelessWidget {
  const _DotButton({
    required this.order,
    required this.done,
    required this.active,
    required this.enabled,
    required this.accent,
    required this.tertiary,
    required this.onTap,
  });

  final int order;
  final bool done;
  final bool active;
  final bool enabled;
  final Color accent;
  final Color tertiary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = done
        ? Color.lerp(accent, Colors.white, 0.55)!
        : active
            ? Color.lerp(accent, tertiary, 0.35)!
            : cs.surfaceContainerHighest.withOpacity(0.92);
    final borderW = active ? 3.5 : 2.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(
              color: active ? Colors.white : accent.withOpacity(done ? 0.5 : 0.35),
              width: borderW,
            ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: accent.withOpacity(0.55),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: done
                ? Icon(Icons.check_rounded, color: accent, size: 32)
                : Text(
                    '$order',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: active ? Colors.white : cs.onSurface.withOpacity(0.88),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DotTrailPainter extends CustomPainter {
  _DotTrailPainter({
    required this.layout,
    required this.completedCount,
    required this.width,
    required this.height,
    required this.lineColor,
  });

  final List<Offset> layout;
  final int completedCount;
  final double width;
  final double height;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (completedCount < 2) return;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < completedCount - 1; i++) {
      final a = Offset(layout[i].dx * width, layout[i].dy * height);
      final b = Offset(layout[i + 1].dx * width, layout[i + 1].dy * height);
      canvas.drawLine(a, b, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotTrailPainter oldDelegate) {
    if (oldDelegate.completedCount != completedCount ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.width != width ||
        oldDelegate.height != height) {
      return true;
    }
    if (oldDelegate.layout.length != layout.length) return true;
    for (var i = 0; i < layout.length; i++) {
      if (oldDelegate.layout[i] != layout[i]) return true;
    }
    return false;
  }
}

class _ResultTier {
  const _ResultTier({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.showFx,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final int xp;
  final bool showFx;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.tier, required this.onPlayAgain});

  final _ResultTier tier;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      builder: (context, t, child) {
        return Transform.scale(scale: 0.85 + 0.15 * t, child: Opacity(opacity: t.clamp(0.0, 1.0), child: child));
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface.withOpacity(0.97),
                Color.lerp(cs.surface, cs.tertiary, 0.08)!,
              ],
            ),
            border: Border.all(color: cs.primary.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tier.emoji, style: const TextStyle(fontSize: 88)),
              const SizedBox(height: 8),
              Text(
                tier.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                tier.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withOpacity(0.68), fontWeight: FontWeight.w600),
              ),
              if (tier.xp > 0) ...[
                const SizedBox(height: 10),
                Text('+${tier.xp} XP', style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary, fontSize: 16)),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onPlayAgain,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Yana o‘ynash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
