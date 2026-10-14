import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../backup/backup.dart';
import '../certificates/certificates.dart';
import '../challenge/challenge.dart';
import '../monetization/monetization.dart';
import '../rewards/friend_hints.dart';
import '../services/game_center.dart';
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

  /// Coins earned by friends opening the player's links.
  late final FriendHints hints;

  /// Recovery code, iCloud copy.
  late final Backup backup;

  late final Certificates certificates;

  final GameCenter gameCenter;

  /// A friend's challenge to open once the menu shows (web: `?c=`).
  Challenge? pendingChallenge;

  AppController(
    this.prefs, {
    this.now = DateTime.now,
    Monetization? monetization,
    GameFeedback? feedback,
    FriendHints? hints,
    Backup? backup,
    GameCenter? gameCenter,
  }) : monetization = monetization ?? Monetization(prefs.shared),
       feedback = feedback ?? GameFeedback(prefs.shared),
       gameCenter = gameCenter ?? GameCenter(),
       _blocked = prefs.isBlocked,
       _band = _bandOrNull(prefs.bandId),
       progress = ProgressStore(prefs.shared) {
    this.hints = hints ?? FriendHints(prefs.shared, this.monetization);
    certificates = Certificates(prefs.shared, progress, now: now);
    this.backup = backup ?? Backup(prefs.shared, onRestored: _reloadAll);
  }

  /// Another save was merged into storage: everything reads it again.
  void _reloadAll() {
    progress.reload();
    certificates.reload();
    monetization.reload();
    hints.reload();
    notifyListeners();
  }

  /// Once the menu shows: iCloud copy, Game Center, backup, certificates.
  /// Returns certificates earned just now (e.g. after a restore).
  Future<List<Cert>> onMenu() async {
    if (_blocked) return const [];
    await backup.restoreFromCloud();
    unawaited(gameCenter.signIn().then((_) => _submitScores()));
    unawaited(backup.sync());
    return certificates.check();
  }

  /// After every won puzzle. Returns certificates earned just now.
  Future<List<Cert>> onWin({
    required bool daily,
    required Difficulty difficulty,
  }) async {
    if (_blocked) return const [];
    unawaited(backup.sync(force: daily));
    unawaited(_submitScores());
    return certificates.check();
  }

  Future<void> _submitScores() async {
    final m = Milestones.of(progress);
    var stars = 0;
    for (final b in kBands) {
      for (final d in Difficulty.values) {
        stars += progress.of(b.id, d).totalStars;
      }
    }
    await gameCenter.submit(
      bestStreak: m.bestStreak,
      levels: m.levels,
      stars: stars,
    );
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
