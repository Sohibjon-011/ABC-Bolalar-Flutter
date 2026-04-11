import 'dart:async';

import 'package:just_audio/just_audio.dart';

class AudioProvider {
  final AudioPlayer _player = AudioPlayer();
  int _cancelId = 0;

  Future<void> init() async {
    // No-op for now; kept for symmetry and future config.
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> stop() async {
    _cancelId++;
    try {
      await _player.stop();
    } catch (_) {}
  }

  /// Plays an asset path like `public/MP4/1.ogg`.
  Future<void> playAsset(String assetPath) async {
    final id = ++_cancelId;
    await _playAssetInternal(id, assetPath);
  }

  Future<void> playSequence(
    List<String> assetPaths, {
    void Function(int index)? onStep,
  }) async {
    final id = ++_cancelId;
    try {
      await _player.stop();
    } catch (_) {}
    for (var i = 0; i < assetPaths.length; i++) {
      if (id != _cancelId) return;
      onStep?.call(i);
      await _playAssetInternal(id, assetPaths[i]);
      if (id != _cancelId) return;
      await _waitForEndedOrError(id);
    }
  }

  Future<void> _playAssetInternal(int id, String assetPath) async {
    try {
      await _player.stop();
      if (id != _cancelId) return;
      await _player.setAudioSource(AudioSource.asset(assetPath));
      if (id != _cancelId) return;
      await _player.setVolume(1);
      await _player.play();
    } catch (_) {
      // Swallow, matching the Vue behavior (best-effort).
    }
  }

  Future<void> _waitForEndedOrError(int id) async {
    final completer = Completer<void>();
    StreamSubscription<PlayerState>? sub;
    sub = _player.playerStateStream.listen((st) {
      if (id != _cancelId) {
        completer.complete();
        sub?.cancel();
        return;
      }
      if (st.processingState == ProcessingState.completed) {
        completer.complete();
        sub?.cancel();
      }
    }, onError: (_) {
      completer.complete();
      sub?.cancel();
    });
    await completer.future.timeout(const Duration(seconds: 30), onTimeout: () {});
  }
}

