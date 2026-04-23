import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/game_animal_sound.dart';
import '../../providers/fx_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/animal_sound_player.dart';
import 'game_animals_catalog.dart';
import 'game_scaffold.dart';

class PeekabooGameScreen extends StatefulWidget {
  const PeekabooGameScreen({super.key});

  @override
  State<PeekabooGameScreen> createState() => _PeekabooGameScreenState();
}

class _PeekabooGameScreenState extends State<PeekabooGameScreen> {
  final _rand = Random();
  late GameAnimalSound _current;
  var _revealed = false;

  @override
  void initState() {
    super.initState();
    _current = kGameAnimals[_rand.nextInt(kGameAnimals.length)];
  }

  void _pickNext() {
    setState(() {
      _revealed = false;
      GameAnimalSound n;
      do {
        n = kGameAnimals[_rand.nextInt(kGameAnimals.length)];
      } while (n.id == _current.id && kGameAnimals.length > 1);
      _current = n;
    });
  }

  Future<void> _onTapArea() async {
    if (_revealed) return;
    setState(() => _revealed = true);
    await context.read<AnimalSoundPlayer>().play(_current);
    if (!mounted) return;
    context.read<FxProvider>().correct();
    context.read<ToastProvider>().push('🎉', 'Salom, ${_current.label}!');
    await context.read<LevelProvider>().addXP(2);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GameScaffold(
      frameAccent: const Color(0xFF00BBF9),
      title: 'Yashiringan hayvon',
      subtitle: 'Parda ko‘tariladi — hayvon chiqadi!',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          _pickNext();
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Boshqasi'),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: cs.surface.withOpacity(0.35)),
                  if (_revealed) ..._sparkles(),
                  Center(
                    child: AnimatedScale(
                      scale: _revealed ? 1.0 : 0.65,
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.elasticOut,
                      child: AnimatedOpacity(
                        opacity: _revealed ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_current.emoji, style: const TextStyle(fontSize: 96)),
                            const SizedBox(height: 8),
                            Text(
                              _current.label,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '«Boshqasi» — keyingi round',
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.55),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: _revealed,
                      child: AnimatedSlide(
                        offset: _revealed ? const Offset(0, -1.2) : Offset.zero,
                        duration: const Duration(milliseconds: 560),
                        curve: Curves.easeInOutCubic,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onTapArea,
                            splashColor: Colors.white30,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.lerp(cs.primary, Colors.black, 0.08)!,
                                    Color.lerp(cs.tertiary, Colors.black, 0.12)!,
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '? ? ?',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withOpacity(0.35),
                                      letterSpacing: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Icon(Icons.touch_app_rounded, size: 58, color: Colors.white.withOpacity(0.95)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'TEGA!',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Parda ortida hayvon yashirin…',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.88),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  List<Widget> _sparkles() {
    return const [
      Positioned(left: 12, top: 24, child: Text('✨', style: TextStyle(fontSize: 28))),
      Positioned(right: 16, top: 36, child: Text('⭐', style: TextStyle(fontSize: 24))),
      Positioned(left: 28, bottom: 48, child: Text('🎉', style: TextStyle(fontSize: 26))),
      Positioned(right: 22, bottom: 36, child: Text('✨', style: TextStyle(fontSize: 22))),
    ];
  }
}
