import 'package:flutter/material.dart';

/// Pastki platforma: Videolar | O'yinlar | Ota-ona | O'rganish.
/// Kontent uchun taxminiy pastki rezerv (scroll padding) — haqiqiy balandlik shundan biroz farq qilishi mumkin.
class PlatformNavBar extends StatelessWidget {
  const PlatformNavBar({
    super.key,
    required this.section,
    required this.onSectionChanged,
  });

  /// `HomeShell` ichidagi bo'sh joy hisobi uchun (yangi dizayn balandligi).
  static const double barHeight = 124;

  /// 0 — videolar, 1 — o'yinlar, 2 — ota-ona, 3 — hozirgi o'quv platforma.
  final int section;
  final ValueChanged<int> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surfaceContainerHighest.withOpacity(isDark ? 0.88 : 0.94),
              Color.lerp(
                    cs.surfaceContainerHighest,
                    cs.primary,
                    isDark ? 0.06 : 0.04,
                  )?.withOpacity(isDark ? 0.82 : 0.90) ??
                  cs.surfaceContainerHighest.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Color.lerp(cs.outlineVariant, cs.primary, 0.25)!.withOpacity(0.45),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 28,
              offset: const Offset(0, 14),
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            ),
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 6),
              color: cs.primary.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _DockItem(
                selected: section == 0,
                emoji: '🎬',
                label: 'Videolar',
                accent: const Color(0xFF00BBF9),
                onTap: () => onSectionChanged(0),
              ),
            ),
            SizedBox(width: isDark ? 8 : 6),
            Expanded(
              child: _DockItem(
                selected: section == 1,
                emoji: '🎮',
                label: "O'yinlar",
                accent: const Color(0xFF9B5DE5),
                onTap: () => onSectionChanged(1),
              ),
            ),
            SizedBox(width: isDark ? 8 : 6),
            Expanded(
              child: _DockItem(
                selected: section == 2,
                emoji: '👨‍👩‍👧',
                label: "Ota-ona",
                accent: const Color(0xFF00C2A8),
                onTap: () => onSectionChanged(2),
              ),
            ),
            SizedBox(width: isDark ? 8 : 6),
            Expanded(
              child: _DockItem(
                selected: section == 3,
                emoji: '📚',
                label: "O'rganish",
                accent: const Color(0xFFFFB703),
                onTap: () => onSectionChanged(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.selected,
    required this.emoji,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final bool selected;
  final String emoji;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final double iconSize = selected ? 28 : 24;
    final double ring = selected ? 50 : 44;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: accent.withOpacity(0.12),
        highlightColor: accent.withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: ring,
                height: ring,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withOpacity(0.95),
                            Color.lerp(accent, cs.tertiary, 0.35)!,
                          ],
                        )
                      : null,
                  color: selected ? null : cs.surface.withOpacity(0.45),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withOpacity(0.35)
                        : cs.outlineVariant.withOpacity(0.4),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    emoji,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: iconSize,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: selected
                        ? Color.lerp(cs.onSurface, accent, 0.12)!
                        : cs.onSurface.withOpacity(0.78),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
