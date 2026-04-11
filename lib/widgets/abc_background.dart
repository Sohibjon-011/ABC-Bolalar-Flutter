import 'dart:math';

import 'package:flutter/material.dart';

class AbcBackground extends StatelessWidget {
  const AbcBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rand = Random(42);
    final stickers = const ["🧸", "🚗", "🍎", "🐶", "🦋", "🎈", "🧩", "⭐", "🍭", "🌈", "🎵", "🫧"];

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.6, -0.9),
            radius: 1.3,
            colors: [
              cs.tertiary.withOpacity(0.18),
              cs.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -0.7),
                    radius: 1.4,
                    colors: [
                      cs.primary.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.9),
                    radius: 1.4,
                    colors: [
                      cs.secondary.withOpacity(0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            for (var i = 0; i < 22; i++)
              Positioned(
                left: rand.nextDouble() * MediaQuery.sizeOf(context).width,
                top: rand.nextDouble() * MediaQuery.sizeOf(context).height,
                child: Opacity(
                  opacity: 0.08 + (i % 6) * 0.03,
                  child: Container(
                    width: 8 + (i % 7) * 2,
                    height: 8 + (i % 7) * 2,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < stickers.length; i++)
              Positioned(
                left: ((i * 13 + 7) % 100) / 100 * MediaQuery.sizeOf(context).width,
                top: ((i * 19 + 9) % 100) / 100 * MediaQuery.sizeOf(context).height,
                child: Opacity(
                  opacity: 0.85,
                  child: Text(
                    stickers[i],
                    style: TextStyle(fontSize: 18 + (i % 6) * 6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

