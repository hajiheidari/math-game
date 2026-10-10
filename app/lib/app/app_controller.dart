import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../monetization/monetization.dart';
import '../rewards/friend_hints.dart';
import 'app_prefs.dart';
import 'feedback.dart';
import 'progress_store.dart';

enum GateState { needsAge, blocked, ready }

/// App-level state: age gate result and current age band.
class AppController extends ChangeNotifier {
  final AppPrefs prefs;
  BandConfig? _band;
  bool _blocked;

  /// Levels progress (local only).
  final ProgressStore progress;

  /// Current time; replaceable in tests.
  final DateTime Function() now;

  /// Today's local calendar date (the Daily Puzzle's date).
  DateTime get today {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Coins, ads and the remove-ads unlock.
  final Monetization monetization;

  /// Sound and vibration.
  final GameFeedback feedback;

  /// Hints earned by friends opening the player's links.
  late final FriendHints hints;

  AppController(
    this.prefs, {
    this.now = DateTime.now,
    Monetization? monetization,
    GameFeedback? feedback,
    FriendHints? hints,
  }) : monetization = monetization ?? Monetization(prefs.shared),
       feedback = feedback ?? GameFeedback(prefs.shared),
       _blocked = prefs.isBlocked,
       _band = _bandOrNull(prefs.bandId),
       progress = ProgressStore(prefs.shared) {
    this.hints = hints ?? FriendHints(prefs.shared, this.monetization);
  }

  static BandConfig? _bandOrNull(String? id) {
    if (id == null) return null;
    for (final b in kBands) {
      if (b.id == id) return b;
    }
    return null; // band removed from config: ask again
  }

  GateState get gate => _blocked
      ? GateState.blocked
      : _band == null
      ? GateState.needsAge
      : GateState.ready;

  BandConfig get band => _band!;

  /// Age from the gate. Only the band (or the block) is stored, never [age].
  Future<void> submitAge(int age) async {
    if (_blocked) return;
    final band = bandForAge(age);
    if (band == null) {
      _blocked = true;
      notifyListeners();
      await prefs.block();
    } else {
      _band = band;
      notifyListeners();
      await prefs.setBand(band.id);
    }
  }

  /// Settings: switch band. Every configured band is 13+.
  Future<void> setBand(BandConfig band) async {
    if (_blocked || band.minAge < kMinimumAge || band == _band) return;
    _band = band;
    notifyListeners();
    await prefs.setBand(band.id);
    await monetization.bandChanged(band);
  }
}
