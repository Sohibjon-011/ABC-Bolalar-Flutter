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

class DragHomeGameScreen extends StatefulWidget {
  const DragHomeGameScreen({super.key});

  @override
  State<DragHomeGameScreen> createState() => _DragHomeGameScreenState();
}

class _DragHomeGameScreenState extends State<DragHomeGameScreen> {
  late final GameAnimalSound _pet = kGameAnimals.firstWhere((e) => e.id == 'cow');
  var _atHome = false;

  Future<void> _onHome() async {
    if (_atHome) return;
    setState(() => _atHome = true);
    HapticFeedback.mediumImpact();
    await context.read<AnimalSoundPlayer>().play(_pet);
    if (!mounted) return;
    context.read<FxProvider>().correct();
    context.read<ToastProvider>().push('🏠', 'Mol uyda — zo‘r!');
    await context.read<LevelProvider>().addXP(4);
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() => _atHome = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GameScaffold(
      frameAccent: const Color(0xFF2EC4B6),
      title: 'Uyga yetkaz',
      subtitle: '${_pet.label}ni uy ichiga torting',
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: DragTarget<GameAnimalSound>(
                      onWillAcceptWithDetails: (_) => !_atHome,
                      onAcceptWithDetails: (details) {
                        if (details.data.id == _pet.id) _onHome();
                      },
                      builder: (context, candidate, rejected) {
                        final hover = candidate.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 200,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: cs.primary.withOpacity(hover ? 0.18 : 0.08),
                            border: Border.all(
                              color: hover ? cs.primary : cs.outlineVariant,
                              width: hover ? 3 : 2,
                            ),
                            boxShadow: hover
                                ? [
                                    BoxShadow(
                                      color: cs.primary.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _atHome ? '✅' : '🏠',
                                style: TextStyle(fontSize: _atHome ? 40 : 44),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _atHome ? 'Xush kelibsiz!' : 'Mol uyi',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!_atHome)
                  Draggable<GameAnimalSound>(
                    data: _pet,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Text(_pet.emoji, style: const TextStyle(fontSize: 72)),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: _petBubble(cs),
                    ),
                    child: _petBubble(cs),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Text(_pet.emoji, style: const TextStyle(fontSize: 72)),
                  ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: _reset,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Qayta'),
          ),
        ],
      ),
    );
  }

  Widget _petBubble(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surfaceContainerHighest.withOpacity(0.85),
            border: Border.all(color: cs.tertiary.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: cs.tertiary.withOpacity(0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(_pet.emoji, style: const TextStyle(fontSize: 64)),
        ),
        const SizedBox(height: 8),
        Text(
          'Ushtan torting',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
