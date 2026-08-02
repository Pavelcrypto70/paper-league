import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum DeskSfx { tap, fill, win, loss }

class DeskAudio {
  DeskAudio._();
  static final DeskAudio instance = DeskAudio._();

  final _pool = <AudioPlayer>[];
  int _cursor = 0;
  bool enabled = true;

  Future<void> play(DeskSfx sfx) async {
    if (!enabled) return;
    try {
      final file = switch (sfx) {
        DeskSfx.tap => 'sfx/tap.wav',
        DeskSfx.fill => 'sfx/fill.wav',
        DeskSfx.win => 'sfx/win.wav',
        DeskSfx.loss => 'sfx/loss.wav',
      };
      final vol = switch (sfx) {
        DeskSfx.tap => 0.35,
        DeskSfx.fill => 0.5,
        DeskSfx.win => 0.55,
        DeskSfx.loss => 0.5,
      };
      final player = await _nextPlayer();
      await player.stop();
      await player.setVolume(vol);
      await player.play(AssetSource(file));
    } catch (_) {
      if (kDebugMode) {
        // Missing assets / exotic platforms — silent.
      }
    }
  }

  Future<AudioPlayer> _nextPlayer() async {
    if (_pool.length < 3) {
      final p = AudioPlayer();
      await p.setPlayerMode(PlayerMode.lowLatency);
      _pool.add(p);
      return p;
    }
    final p = _pool[_cursor % _pool.length];
    _cursor++;
    return p;
  }
}
