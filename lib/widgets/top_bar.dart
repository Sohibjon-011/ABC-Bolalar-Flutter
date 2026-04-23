import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../providers/theme_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.showLevel = true});

  /// O'rganish bo'limida XP / bosqich; media bo'limida yashirin.
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final level = context.watch<LevelProvider>();
    final theme = context.watch<ThemeProvider>();
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 380;

    return Material(
      color: cs.surface.withOpacity(0.85),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 10 : 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'public/MP4/playtime.png',
                width: compact ? 28 : 34,
                height: compact ? 28 : 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [cs.primary, cs.tertiary],
                ).createShader(rect),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ABC-BOLALAR',
                    style: TextStyle(fontSize: compact ? 16 : 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (showLevel) ...[
              _LevelPill(level: level),
              SizedBox(width: compact ? 8 : 12),
            ],
            IconButton.filledTonal(
              onPressed: () => theme.toggle(),
              tooltip: theme.themeMode == ThemeMode.dark ? "Kunduzgi rejim" : "Tungi rejim",
              icon: Text(theme.themeMode == ThemeMode.dark ? '🌙' : '☀️', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});
  final LevelProvider level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 400;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 132 : 170),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 7 : 9),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '⭐ ${level.level}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, color: cs.tertiary, fontSize: compact ? 12 : 13),
            ),
            SizedBox(height: compact ? 5 : 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: compact ? 5 : 6,
                value: level.progressPct / 100.0,
                backgroundColor: cs.outlineVariant.withOpacity(0.35),
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

