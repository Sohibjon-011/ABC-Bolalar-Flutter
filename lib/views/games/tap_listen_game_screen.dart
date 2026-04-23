import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/animal_sound_player.dart';
import 'game_animals_catalog.dart';
import 'game_scaffold.dart';

class TapListenGameScreen extends StatefulWidget {
  const TapListenGameScreen({super.key});

  @override
  State<TapListenGameScreen> createState() => _TapListenGameScreenState();
}

class _TapListenGameScreenState extends State<TapListenGameScreen> {
  int? _pulse;

  Future<void> _play(int index) async {
    HapticFeedback.lightImpact();
    setState(() => _pulse = index);
    await context.read<AnimalSoundPlayer>().play(kGameAnimals[index]);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (mounted) setState(() => _pulse = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GameScaffold(
      frameAccent: const Color(0xFF9B5DE5),
      title: 'Teginib tingla',
      subtitle: 'Har katak — alohida ovoz',
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.02,
        ),
        itemCount: kGameAnimals.length,
        itemBuilder: (context, i) {
          final it = kGameAnimals[i];
          final pulse = _pulse == i;
          return AnimatedScale(
            scale: pulse ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _play(i),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.surfaceContainerHighest.withOpacity(0.85),
                        Color.lerp(cs.surfaceContainerHighest, cs.tertiary, pulse ? 0.22 : 0.06)!,
                      ],
                    ),
                    border: Border.all(
                      color: pulse ? cs.tertiary.withOpacity(0.65) : cs.primary.withOpacity(0.22),
                      width: pulse ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (pulse ? cs.tertiary : Colors.black).withOpacity(pulse ? 0.2 : 0.06),
                        blurRadius: pulse ? 16 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(it.emoji, style: TextStyle(fontSize: pulse ? 56 : 50)),
                      const SizedBox(height: 6),
                      Text(
                        it.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
