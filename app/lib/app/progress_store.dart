import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge/challenge.dart';

/// Levels-mode progress for one band x difficulty.
class LevelProgress {
  /// Best stars per completed level; index 0 = level 1. Levels are unlocked
  /// in order, so this is also the list of completed levels.
  final List<int> stars;
  const LevelProgress(this.stars);

  int get completed => stars.length;

  /// The level to play next (first not yet completed).
  int get nextLevel => stars.length + 1;
  int get totalStars => stars.fold(0, (a, b) => a + b);

  /// Stars for [level], or 0 if not completed.
  int starsFor(int level) =>
      level >= 1 && level <= stars.length ? stars[level - 1] : 0;

  bool isUnlocked(int level) => level >= 1 && level <= nextLevel;
}

/// Local progress storage. Formats:
///   `progress/<band>/<difficulty>` = best stars as a digit string ("3321")
///   `game/<slot>`                   = JSON of an unfinished game, if any
///   `daily`                         = solved daily puzzles by date
class ProgressStore extends ChangeNotifier {
  final SharedPreferences _p;
  ProgressStore(this._p);

  static String _progressKey(String band, Difficulty d) =>
      'progress/$band/${d.name}';

  LevelProgress of(String band, Difficulty d) {
    final raw = _p.getString(_progressKey(band, d)) ?? '';
    return LevelProgress([
      // Anything but 1-3 (corrupt data) counts as a 1-star completion.
      for (final c in raw.codeUnits) (c >= 0x31 && c <= 0x33) ? c - 0x30 : 1,
    ]);
  }

  /// Records a completed level. Completing the next level unlocks the one
  /// after it; replays only improve the best stars.
  Future<void> recordWin(
    String band,
    Difficulty d,
    int level,
    int stars,
  ) async {
    final current = of(band, d).stars.toList();
    if (level == current.length + 1) {
      current.add(stars);
    } else if (level >= 1 && level <= current.length) {
      if (stars <= current[level - 1]) return;
      current[level - 1] = stars;
    } else {
      return; // not unlocked: ignore
    }
    await _p.setString(_progressKey(band, d), current.join());
    notifyListeners();
  }

  // --- Unfinished games ---------------------------------------------------

  /// Save slot for Levels mode (one unfinished level per band x difficulty).
  static String levelSlot(String band, Difficulty d) => 'level/$band/${d.name}';

  /// Save slot for the Daily Puzzle (one unfinished daily per band x difficulty).
  static String dailySlot(String band, Difficulty d) => 'daily/$band/${d.name}';

  /// Save slot for a friend's challenge (one per puzzle).
  static String challengeSlot(Challenge c) =>
      'challenge/${c.code.split('-').first}';

  /// The unfinished game in [slot], if it is puzzle [id] (level or date).
  Map<String, Object?>? savedGame(String slot, int id) {
    final json = _readGame(slot);
    return json != null && json['id'] == id ? json : null;
  }

  /// Id (level number or yyyymmdd) of the unfinished game in [slot].
  int? savedId(String slot) => _readGame(slot)?['id'] as int?;

  Map<String, Object?>? _readGame(String slot) {
    final raw = _p.getString('game/$slot');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, Object?>;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveGame(String slot, int id, Map<String, Object?> snapshot) =>
      _p.setString('game/$slot', jsonEncode({...snapshot, 'id': id}));

  Future<void> clearGame(String slot) => _p.remove('game/$slot');

  // --- Daily Puzzle ---------------------------------------------------------
  // `daily` = JSON {"2026-09-30": bitmask of solved difficulties}. Global
  // (not per band) so a band change keeps the streak.

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// yyyymmdd, used as the saved-game id of a daily puzzle.
  static int dateId(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  Map<String, int> _daily() {
    final raw = _p.getString('daily');
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, Object?>).map(
        (k, v) => MapEntry(k, v as int),
      );
    } on Object {
      return {};
    }
  }

  bool isDailySolved(DateTime date, Difficulty d) =>
      ((_daily()[dateKey(date)] ?? 0) & (1 << d.index)) != 0;

  /// Calendar days (local dates) with at least one solved daily puzzle.
  Set<DateTime> solvedDays() => {
    for (final k in _daily().keys)
      if (DateTime.tryParse(k) case final d?) DateTime(d.year, d.month, d.day),
  };

  Future<void> recordDaily(DateTime date, Difficulty d) async {
    final all = _daily();
    final key = dateKey(date);
    all[key] = (all[key] ?? 0) | (1 << d.index);
    await _p.setString('daily', jsonEncode(all));
    notifyListeners();
  }

  /// Most daily puzzles (difficulties) solved on one calendar day.
  int mostDailiesInADay() {
    var best = 0;
    for (final mask in _daily().values) {
      var n = 0;
      for (var m = mask; m != 0; m >>= 1) {
        n += m & 1;
      }
      if (n > best) best = n;
    }
    return best;
  }

  /// After a backup was merged into storage.
  void reload() => notifyListeners();

  /// Consecutive days with a solved daily, ending today — or yesterday, so
  /// the streak stays alive until today is over.
  int currentStreak(DateTime today) {
    final days = solvedDays();
    var day = DateTime(today.year, today.month, today.day);
    if (!days.contains(day)) day = _addDays(day, -1);
    var n = 0;
    while (days.contains(day)) {
      n++;
      day = _addDays(day, -1);
    }
    return n;
  }

  int bestStreak() {
    final days = solvedDays();
    var best = 0;
    for (final d in days) {
      if (days.contains(_addDays(d, -1))) continue; // not a run start
      var n = 0;
      var x = d;
      while (days.contains(x)) {
        n++;
        x = _addDays(x, 1);
      }
      if (n > best) best = n;
    }
    return best;
  }

  /// Calendar-day arithmetic that ignores daylight-saving shifts.
  static DateTime _addDays(DateTime d, int n) =>
      DateTime(d.year, d.month, d.day + n);
}
