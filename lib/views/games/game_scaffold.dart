import 'package:flutter/material.dart';

import 'widgets/game_arcade_widgets.dart';

/// Barcha mini-o‘yinlar — arcade uslubida fon + ramka + HUD.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.floatingActionButton,
    this.frameAccent,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? floatingActionButton;

  /// Ramka neon rangi (sukut: primary).
  final Color? frameAccent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = frameAccent ?? cs.primary;
    final dotsColor = cs.primary.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.14 : 0.10);

    return Scaffold(
      extendBodyBehindAppBar: false,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.surface.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: accent.withOpacity(0.25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [accent, cs.tertiary],
              ).createShader(bounds),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.62),
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.surface,
                  Color.lerp(cs.surface, accent, 0.09)!,
                  Color.lerp(cs.surface, cs.tertiary, 0.05)!,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: GameDotsPainter(color: dotsColor)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GameHudBar(accent: accent),
                  Expanded(
                    child: GameArcadeFrame(
                      accent: accent,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
