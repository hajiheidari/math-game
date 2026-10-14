import 'package:numcross_engine/numcross_engine.dart';

import '../app/progress_store.dart';

/// "Can you beat my time?" (Amir, 2026-10-14, like Tiaro): every shared win
/// carries the puzzle and the sender's time, and the friend who opens the
/// link plays the very same puzzle against that time.
///
/// The puzzle is rebuilt from its seed (band, difficulty and level, or the
/// daily puzzle's date), so the link stays short:
///   `https://adadi.espadna.com/?c=13l12-2n&r=<invite code>`
///   `c = <band index><difficulty index><l|d><level | yyyymmdd, base 36>-<seconds, base 36>`
/// The `r` part is the sender's invite code: the friend opening it earns
/// the sender a coin (lib/rewards/friend_hints.dart).
class Challenge {
  final BandConfig band;
  final Difficulty difficulty;

  /// Level number (Levels mode), or 0 for a daily puzzle.
  final int level;

  /// The daily puzzle's date (daily only).
  final DateTime? date;

  /// The sender's time.
  final Duration time;

  const Challenge({
    required this.band,
    required this.difficulty,
    this.level = 0,
    this.date,
    required this.time,
  });

  bool get isDaily => date != null;

  Puzzle get puzzle => isDaily
      ? generateDaily(band, difficulty, date!)
      : generateLevel(band, difficulty, level);

  String get code {
    final b = kBands.indexOf(band);
    final id = isDaily ? ProgressStore.dateId(date!) : level;
    return '$b${difficulty.index}${isDaily ? 'd' : 'l'}'
        '${id.toRadixString(36)}-${time.inSeconds.toRadixString(36)}';
  }

  static final _pattern = RegExp(
    r'^([0-9])([0-3])([ld])([0-9a-z]{1,8})-([0-9a-z]{1,6})$',
  );

  /// Null when the code is cut off or made up.
  static Challenge? decode(String? code) {
    final m = _pattern.firstMatch((code ?? '').trim().toLowerCase());
    if (m == null) return null;
    final b = int.parse(m[1]!), d = int.parse(m[2]!);
    if (b >= kBands.length) return null;
    final id = int.tryParse(m[4]!, radix: 36);
    final secs = int.tryParse(m[5]!, radix: 36);
    if (id == null || secs == null || id <= 0) return null;
    final time = Duration(seconds: secs);
    final band = kBands[b], difficulty = Difficulty.values[d];
    if (m[3] == 'l') {
      if (id > 100000) return null;
      return Challenge(
        band: band,
        difficulty: difficulty,
        level: id,
        time: time,
      );
    }
    final y = id ~/ 10000, mo = id ~/ 100 % 100, day = id % 100;
    final date = DateTime(y, mo, day);
    if (y < 2026 || y > 2100 || date.month != mo || date.day != day) {
      return null;
    }
    return Challenge(
      band: band,
      difficulty: difficulty,
      date: date,
      time: time,
    );
  }

  /// The challenge in a page address (`?c=`), if any.
  static Challenge? fromUri(Uri page) => decode(page.queryParameters['c']);

  /// Link for friends: the web game with this challenge and the sender's
  /// invite code ([site] from FriendHints.siteFor).
  String link(String site, String inviteCode) => '$site/?c=$code&r=$inviteCode';
}

/// How the friend did against the sender.
enum Verdict { win, lose, tie }

Verdict verdictFor(Duration mine, Duration theirs) {
  final a = mine.inSeconds, b = theirs.inSeconds;
  return a < b
      ? Verdict.win
      : a > b
      ? Verdict.lose
      : Verdict.tie;
}
