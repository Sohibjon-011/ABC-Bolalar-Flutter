import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nuqtali «oyin maydoni» foni.
class GameDotsPainter extends CustomPainter {
  GameDotsPainter({required this.color, this.seed = 42});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final paint = Paint()..color = color;
    for (var i = 0; i < 48; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 1.2 + rnd.nextDouble() * 2.2;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GameDotsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}

/// Neon uslubidagi ichki ramka — mobil o‘yinlar kabi.
class GameArcadeFrame extends StatelessWidget {
  const GameArcadeFrame({super.key, required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.22),
            cs.surface.withOpacity(0.4),
            accent.withOpacity(0.12),
          ],
        ),
        border: Border.all(
          width: 2.5,
          color: Color.lerp(accent, Colors.white, 0.35)!,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.28),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.55),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Yuqori HUD: yulduzchalar + mini o‘yin yorlig‘i.
class GameHudBar extends StatelessWidget {
  const GameHudBar({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [accent.withOpacity(0.35), cs.tertiary.withOpacity(0.22)],
              ),
              border: Border.all(color: accent.withOpacity(0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_esports_rounded, size: 18, color: accent),
                const SizedBox(width: 6),
                Text(
                  'MINI O‘YIN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: cs.onSurface.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Icon(Icons.star_rounded, color: accent.withOpacity(0.65 + i * 0.1), size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
