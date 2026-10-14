import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Apple Game Center (iPhone / iPad): the player signs in quietly at launch
/// and their best numbers go to three leaderboards. Native side:
/// ios/Runner/AppDelegate.swift. Nothing happens on Android or the web, or
/// when the player does not use Game Center.
///
/// The leaderboards must exist in App Store Connect with these ids
/// (docs/NEXT.md); until then Apple just ignores the scores.
class GameCenter extends ChangeNotifier {
  static const _channel = MethodChannel('adadi/game_center');

  static const streakBoard = 'adadi.best_streak';
  static const levelsBoard = 'adadi.levels';
  static const starsBoard = 'adadi.stars';

  bool get available => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool _signedIn = false;
  bool get signedIn => _signedIn;

  Future<void> signIn() async {
    if (!available || _signedIn) return;
    try {
      _signedIn = await _channel.invokeMethod<bool>('signIn') ?? false;
      notifyListeners();
    } on Object catch (e) {
      debugPrint('Game Center: $e');
    }
  }

  /// Sends the player's best numbers (Game Center keeps the best of each).
  Future<void> submit({
    required int bestStreak,
    required int levels,
    required int stars,
  }) async {
    if (!_signedIn) return;
    try {
      await _channel.invokeMethod<bool>('submit', {
        'scores': {
          streakBoard: bestStreak,
          levelsBoard: levels,
          starsBoard: stars,
        },
      });
    } on Object catch (e) {
      debugPrint('Game Center: $e');
    }
  }

  /// Opens Game Center's leaderboards.
  Future<void> show() async {
    if (!_signedIn) await signIn();
    if (!_signedIn) return;
    try {
      await _channel.invokeMethod<bool>('show');
    } on Object catch (e) {
      debugPrint('Game Center: $e');
    }
  }
}
