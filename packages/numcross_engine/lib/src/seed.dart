import 'config.dart';
import 'rng.dart';

/// Bump when the generator changes in a way that alters puzzles, so seeds from
/// different generator versions never collide.
const String generatorNamespace = 'numcross/v1';

/// FNV-1a 32-bit hash over UTF-16 code units. Platform independent.
int fnv1a32(String input) {
  var hash = 0x811C9DC5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = SeededRandom.imul(hash, 0x01000193);
  }
  return hash;
}

/// Seed for the endless Levels mode: same band + difficulty + level number
/// always gives the same puzzle.
int levelSeed(String bandId, Difficulty difficulty, int level) =>
    fnv1a32('$generatorNamespace|level|$bandId|${difficulty.name}|$level');

/// Seed for the Daily Puzzle: date + band + difficulty. Uses the calendar
/// date only (the caller passes the player's local date).
int dailySeed(DateTime date, String bandId, Difficulty difficulty) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return fnv1a32('$generatorNamespace|daily|$y-$m-$d|$bandId|${difficulty.name}');
}
