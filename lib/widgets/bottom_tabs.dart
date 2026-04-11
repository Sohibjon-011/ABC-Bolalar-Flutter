import 'package:flutter/material.dart';

class BottomTabs extends StatelessWidget {
  const BottomTabs({super.key, required this.index, required this.onChanged});

  static const double height = 64;

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final emojiSize = (24 * textScale).clamp(22, 28).toDouble();

    Widget tab(int i, String emoji) {
      final on = i == index;
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? cs.primary.withOpacity(0.35) : Colors.transparent),
            gradient: on
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.20),
                      cs.tertiary.withOpacity(0.16),
                    ],
                  )
                : null,
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.70),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 18),
              color: Colors.black.withOpacity(0.18),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: tab(0, '🔤')),
            Expanded(child: tab(1, '🔢')),
            Expanded(child: tab(2, '🎨')),
            Expanded(child: tab(3, '🐾')),
          ],
        ),
      ),
    );
  }
}

