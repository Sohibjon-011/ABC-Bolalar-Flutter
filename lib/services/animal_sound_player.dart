import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/game_animal_sound.dart';
import '../providers/audio_provider.dart';

/// Avvalo `assets/game_sounds/animals/` dagi fayl, bo'lmasa TTS onomatopeya (bolalar o'yini uslubi).
class AnimalSoundPlayer {
  AnimalSoundPlayer(this._audio);

  final AudioProvider _audio;
  final FlutterTts _tts = FlutterTts();
  var _ttsReady = false;

  static const _assetPrefix = 'assets/game_sounds/animals/';

  Future<void> ready() async {
    if (_ttsReady) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.18);
      await _tts.setVolume(1.0);
      final dynamic raw = await _tts.getLanguages;
      final langs = raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
      if (langs.contains('uz-UZ')) {
        await _tts.setLanguage('uz-UZ');
      } else if (langs.contains('ru-RU')) {
        await _tts.setLanguage('ru-RU');
      } else {
        await _tts.setLanguage('en-US');
      }
      _ttsReady = true;
    } catch (e, st) {
      debugPrint('AnimalSoundPlayer TTS init: $e\n$st');
      _ttsReady = false;
    }
  }

  Future<void> play(GameAnimalSound sound) async {
    await ready();
    await _audio.stop();

    final file = sound.assetFile?.trim();
    if (file != null && file.isNotEmpty) {
      final ok = await _audio.tryPlayAsset('$_assetPrefix$file');
      if (ok) return;
    }

    if (!_ttsReady) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
      return;
    }

    try {
      await _tts.stop();
      await _tts.speak(sound.ttsCue);
    } catch (e, st) {
      debugPrint('AnimalSoundPlayer TTS speak: $e\n$st');
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  void dispose() {
    Future.microtask(() async {
      try {
        await _tts.stop();
      } catch (_) {}
    });
  }
}
