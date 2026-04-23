import 'package:flutter/material.dart';

import 'color_pop_game_screen.dart';
import 'drag_home_game_screen.dart';
import 'finger_paint_game_screen.dart';
import 'peekaboo_game_screen.dart';
import 'surprise_box_game_screen.dart';
import 'tap_dots_game_screen.dart';
import 'tap_listen_game_screen.dart';
import 'who_said_game_screen.dart';

class GamesHub extends StatelessWidget {
  const GamesHub({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mut = cs.onSurface.withOpacity(0.72);

    final items = <_GameCardData>[
      _GameCardData(
        emoji: '🙈',
        title: 'Yashiringan hayvon',
        blurb: 'Tega — hayvon paydo bo‘ladi, ovoz eshitasiz.',
        accent: const Color(0xFF00BBF9),
        screen: const PeekabooGameScreen(),
      ),
      _GameCardData(
        emoji: '✍️',
        title: 'Barmoq bilan chiz',
        blurb: 'Bola barmog‘i bilan ekranga chizadi: rang va qalinlikni tanlang.',
        accent: const Color(0xFF06B6D4),
        screen: const FingerPaintGameScreen(),
      ),
      _GameCardData(
        emoji: '⭕',
        title: 'Nuqta izi',
        blurb: 'Har safar boshqa naqsh: 1→2→3… tartibda bosing, emoji mukofot!',
        accent: const Color(0xFF7C3AED),
        screen: const TapDotsGameScreen(),
      ),
      _GameCardData(
        emoji: '🎵',
        title: 'Teginib tingla',
        blurb: 'Har rasm o‘z ovozini chiqaradi.',
        accent: const Color(0xFF9B5DE5),
        screen: const TapListenGameScreen(),
      ),
      _GameCardData(
        emoji: '🌈',
        title: 'Ranglar guli',
        blurb: 'Barcha doiralarni yoritib, gul oching.',
        accent: const Color(0xFFFF4D6D),
        screen: const ColorPopGameScreen(),
      ),
      _GameCardData(
        emoji: '👂',
        title: 'Kim gapirdi?',
        blurb: 'Ovozni tinglang — qaysi hayvon?',
        accent: const Color(0xFFFFB703),
        screen: const WhoSaidGameScreen(),
      ),
      _GameCardData(
        emoji: '🏠',
        title: 'Uyga yetkaz',
        blurb: 'Molni uy sohasiga torting — «muuu» eshitasiz.',
        accent: const Color(0xFF2EC4B6),
        screen: const DragHomeGameScreen(),
      ),
      _GameCardData(
        emoji: '🎁',
        title: 'Kutilmagan quti',
        blurb: 'Qutini oching — kichik syurpriz!',
        accent: const Color(0xFFE85D75),
        screen: const SurpriseBoxGameScreen(),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.28),
                    cs.tertiary.withOpacity(0.22),
                  ],
                ),
                border: Border.all(color: cs.primary.withOpacity(0.35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_esports_rounded, color: cs.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'O‘YIN MARKAZI',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mini-o‘yinlar — teginish, ovoz, mukofot. Mobil o‘yinlar uslubida.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mut, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cross = w >= 400 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: cross == 2 ? 1.05 : 1.18,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    return _GameLaunchCard(
                      data: it,
                      onTap: () => _open(context, it.screen),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCardData {
  const _GameCardData({
    required this.emoji,
    required this.title,
    required this.blurb,
    required this.accent,
    required this.screen,
  });

  final String emoji;
  final String title;
  final String blurb;
  final Color accent;
  final Widget screen;
}

class _GameLaunchCard extends StatelessWidget {
  const _GameLaunchCard({required this.data, required this.onTap});

  final _GameCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surfaceContainerHighest.withOpacity(0.75),
                Color.lerp(cs.surfaceContainerHighest, data.accent, 0.12)!,
              ],
            ),
            border: Border.all(
              color: data.accent.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: data.accent.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: data.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(data.emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.play_circle_fill_rounded, color: data.accent, size: 32),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    data.blurb,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.72),
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
