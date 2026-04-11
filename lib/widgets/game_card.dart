import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.big,
    this.small,
    this.emoji,
    this.displayIcon,
    this.image,
    required this.active,
    required this.onTap,
  });

  final String big;
  final String? small;
  final String? emoji;
  final IconData? displayIcon;
  final ImageProvider? image;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.70),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              blurRadius: active ? 60 : 30,
              offset: const Offset(0, 18),
              color: (active ? cs.primary : Colors.black).withOpacity(active ? 0.16 : 0.10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 92),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.tertiary.withOpacity(0.16), cs.secondary.withOpacity(0.14)],
                ),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.35), style: BorderStyle.solid),
              ),
              child: Center(
                child: image != null
                    ? Image(image: image!, width: 92, height: 92, fit: BoxFit.contain)
                    : displayIcon != null
                        ? Icon(displayIcon, size: 56, color: cs.primary)
                        : Text(emoji ?? '', style: const TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: 10),
            Text(big, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, height: 1)),
            if (small != null) ...[
              const SizedBox(height: 2),
              Text(
                small!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.85)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

