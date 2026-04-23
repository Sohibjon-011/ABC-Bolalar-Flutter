import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/level_provider.dart';
import '../../providers/toast_provider.dart';
import 'game_scaffold.dart';

class SurpriseBoxGameScreen extends StatefulWidget {
  const SurpriseBoxGameScreen({super.key});

  @override
  State<SurpriseBoxGameScreen> createState() => _SurpriseBoxGameScreenState();
}

class _SurpriseBoxGameScreenState extends State<SurpriseBoxGameScreen> with TickerProviderStateMixin {
  final _rand = math.Random();
  var _open = false;
  var _idx = 0;

  static const _surprises = [
    '🎈',
    '⭐',
    '🍭',
    '🦋',
    '🎵',
    '🌈',
    '🧸',
    '🍎',
  ];

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final Animation<double> _popScale = CurvedAnimation(parent: _pop, curve: Curves.elasticOut);

  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _pop.dispose();
    _wobble.dispose();
    super.dispose();
  }

  void _tapBox() {
    HapticFeedback.lightImpact();
    if (!_open) {
      setState(() {
        _open = true;
        _idx = _rand.nextInt(_surprises.length);
      });
      _pop.forward(from: 0);
      context.read<ToastProvider>().push('🎁', 'Loot box ochildi!');
      context.read<LevelProvider>().addXP(1);
    } else {
      setState(() {
        _open = false;
        _pop.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GameScaffold(
      frameAccent: const Color(0xFFE85D75),
      title: 'Kutilmagan quti',
      subtitle: 'Loot box — syurpriz!',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _tapBox,
            child: AnimatedBuilder(
              animation: _wobble,
              builder: (context, child) {
                if (_open) return child!;
                final a = math.sin(_wobble.value * math.pi * 2) * 0.04;
                return Transform.rotate(angle: a, child: child);
              },
              child: AnimatedScale(
                scale: _open ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.tertiary.withOpacity(0.45),
                        cs.primary.withOpacity(0.35),
                        Color.lerp(cs.tertiary, cs.primary, 0.3)!.withOpacity(0.25),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _open ? '📭' : '🎁',
                        style: const TextStyle(fontSize: 92),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _open ? 'Yopish uchun teg' : 'Ochish uchun teg!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: cs.onSurface.withOpacity(0.88),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          if (_open)
            ScaleTransition(
              scale: _popScale,
              child: Text(
                _surprises[_idx],
                style: const TextStyle(fontSize: 104),
              ),
            ),
        ],
      ),
    );
  }
}
