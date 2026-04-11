import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FxProvider extends ChangeNotifier {
  int _nonce = 0;
  int get nonce => _nonce;

  bool _show = false;
  bool get show => _show;

  void correct() {
    _nonce++;
    _show = true;
    notifyListeners();

    // Success feedback (sound + light haptic).
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    // Tarmoqdan Lottie yuklanishi uchun biroz uzoqroq.
    Timer(const Duration(milliseconds: 2800), () {
      _show = false;
      notifyListeners();
    });
  }
}

