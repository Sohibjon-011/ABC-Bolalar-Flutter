import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// To'g'ri javob effekti. Oq fon yo'q — faqat yengil qorong'ulash + Lottie yoki zaxira.
class VictoryFxOverlay extends StatefulWidget {
  const VictoryFxOverlay({super.key, required this.visible, required this.nonce});

  final bool visible;
  final int nonce;

  @override
  State<VictoryFxOverlay> createState() => _VictoryFxOverlayState();
}

class _VictoryFxOverlayState extends State<VictoryFxOverlay> with SingleTickerProviderStateMixin {
  static const String _lottieJsonUrl =
      'https://lottie.host/672628e2-d147-48c2-9afa-28c58de40f8d/jLE2fQstVx.json';

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _fallback(ColorScheme cs) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration_rounded, size: 88, color: cs.tertiary),
          const SizedBox(height: 8),
          Text(
            'Ajoyib!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cs.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: Material(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Lottie.network(
                _lottieJsonUrl,
                key: ValueKey<int>(widget.nonce),
                repeat: true,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(cs),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
