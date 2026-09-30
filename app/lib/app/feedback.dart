import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSound { tap, correct, wrong, win }

/// Plays a sound. Separate so tests (and web without audio) stay silent.
abstract class SoundPlayer {
  Future<void> play(GameSound sound);
}

class SilentPlayer implements SoundPlayer {
  @override
  Future<void> play(GameSound sound) async {}
}

/// Short synthesized effects from `assets/sounds` (see tool/make_sounds.js).
class AssetSoundPlayer implements SoundPlayer {
  final Map<GameSound, AudioPlayer> _players = {};

  @override
  Future<void> play(GameSound sound) async {
    try {
      final player = _players.putIfAbsent(sound, () {
        final p = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
        p.setReleaseMode(ReleaseMode.stop);
        return p;
      });
      await player.stop();
      await player.play(AssetSource('sounds/${sound.name}.wav'));
    } on Object {
      // Audio is a nicety; never let it break the game.
    }
  }
}

/// Sound + vibration with the user's on/off settings (`sound`, `haptics`).
class GameFeedback extends ChangeNotifier {
  final SharedPreferences _p;
  final SoundPlayer _sound;

  GameFeedback(this._p, {SoundPlayer? sound})
    : _sound = sound ?? SilentPlayer();

  bool get soundOn => _p.getBool('sound') ?? true;
  bool get hapticsOn => _p.getBool('haptics') ?? true;

  set soundOn(bool v) {
    _p.setBool('sound', v);
    notifyListeners();
  }

  set hapticsOn(bool v) {
    _p.setBool('haptics', v);
    notifyListeners();
  }

  void tap() {
    if (hapticsOn) HapticFeedback.selectionClick();
    if (soundOn) _sound.play(GameSound.tap);
  }

  void correct() {
    if (hapticsOn) HapticFeedback.lightImpact();
    if (soundOn) _sound.play(GameSound.correct);
  }

  void wrong() {
    if (hapticsOn) HapticFeedback.heavyImpact();
    if (soundOn) _sound.play(GameSound.wrong);
  }

  void win() {
    if (hapticsOn) HapticFeedback.mediumImpact();
    if (soundOn) _sound.play(GameSound.win);
  }
}
