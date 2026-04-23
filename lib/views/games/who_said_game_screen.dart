import 'dart:math' as math;

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

class WhoSaidGameScreen extends StatefulWidget {
  const WhoSaidGameScreen({super.key});

  @override
  State<WhoSaidGameScreen> createState() => _WhoSaidGameScreenState();
}

class _WhoSaidGameScreenState extends State<WhoSaidGameScreen> with SingleTickerProviderStateMixin {
  final _rand = math.Random();
  late GameAnimalSound _a;
  late GameAnimalSound _b;
  late GameAnimalSound _answer;
  var _locked = false;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    _newRound();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playPrompt();
    });
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _newRound() {
    final pool = List<GameAnimalSound>.from(kGameAnimals)..shuffle(_rand);
    _a = pool[0];
    _b = pool[1];
    _answer = _rand.nextBool() ? _a : _b;
    _locked = false;
  }

  Future<void> _playPrompt() async {
    if (!mounted || _locked) return;
    await context.read<AnimalSoundPlayer>().play(_answer);
  }

  Future<void> _pick(GameAnimalSound c) async {
    if (_locked) return;
    if (c.id == _answer.id) {
      setState(() => _locked = true);
      HapticFeedback.mediumImpact();
      context.read<FxProvider>().correct();
      context.read<ToastProvider>().push('✨', 'To‘g‘ri — ${_answer.label}!');
      await context.read<LevelProvider>().addXP(3);
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _newRound();
      });
      await _playPrompt();
    } else {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
      context.read<ToastProvider>().push('🎯', 'Yana urinib ko‘ring!');
      await context.read<AnimalSoundPlayer>().play(c);
    }
  }

  Widget _bigCard(GameAnimalSound it) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _pick(it),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surfaceContainerHighest.withOpacity(0.9),
                  Color.lerp(cs.surfaceContainerHighest, cs.primary, 0.08)!,
                ],
              ),
              border: Border.all(color: cs.primary.withOpacity(0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(it.emoji, style: const TextStyle(fontSize: 68)),
                const SizedBox(height: 8),
                Text(
                  it.label,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      frameAccent: const Color(0xFFFFB703),
      title: 'Kim gapirdi?',
      subtitle: 'ROUND: tingla va tanla',
      child: Column(
        children: [
          FilledButton.tonalIcon(
            onPressed: _locked ? null : _playPrompt,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.volume_up_rounded, size: 26),
            label: const Text('Ovozni tingla', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2)),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final v = _shake.value;
                final dx = math.sin(v * math.pi * 5) * 10 * (1 - v);
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _bigCard(_a),
                  const SizedBox(width: 12),
                  _bigCard(_b),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(_newRound);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _playPrompt();
              });
            },
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text('Yangi juftlik'),
          ),
        ],
      ),
    );
  }
}
