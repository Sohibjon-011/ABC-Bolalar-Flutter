import 'package:flutter/material.dart';

class BottomTabs extends StatelessWidget {
  const BottomTabs({super.key, required this.index, required this.onChanged});

  /// Platforma paneli bilan bir xil rezerv hisobi.
  static const double height = 72;

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final emojiSize = (26 * textScale).clamp(22.0, 30.0);

    Widget tab(int i, String emoji) {
      final on = i == index;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onChanged(i),
            splashColor: cs.primary.withOpacity(0.12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: on ? cs.primary.withOpacity(0.45) : Colors.transparent,
                  width: on ? 1.5 : 1,
                ),
                gradient: on
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withOpacity(0.22),
                          cs.tertiary.withOpacity(0.18),
                        ],
                      )
                    : null,
                color: on ? null : cs.surface.withOpacity(0.25),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: emojiSize, height: 1.0)),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surfaceContainerHighest.withOpacity(isDark ? 0.85 : 0.92),
              Color.lerp(cs.surfaceContainerHighest, cs.tertiary, isDark ? 0.05 : 0.03)!
                  .withOpacity(isDark ? 0.78 : 0.88),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Color.lerp(cs.outlineVariant, cs.tertiary, 0.2)!.withOpacity(0.42),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, 12),
              color: Colors.black.withOpacity(isDark ? 0.28 : 0.1),
            ),
          ],
        ),
        child: Row(
          children: [
            tab(0, '🔤'),
            tab(1, '🔢'),
            tab(2, '🎨'),
            tab(3, '🐾'),
          ],
        ),
      ),
    );
  }
}
