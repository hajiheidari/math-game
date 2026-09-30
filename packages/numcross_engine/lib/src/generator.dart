import 'config.dart';
import 'filler.dart';
import 'layout_builder.dart';
import 'model.dart';
import 'rng.dart';
import 'seed.dart';
import 'solver.dart';

class GenerationFailure implements Exception {
  final String message;
  GenerationFailure(this.message);
  @override
  String toString() => 'GenerationFailure: $message';
}

/// Builds a puzzle deterministically from [seed]:
/// 1. layout of intersecting equations,
/// 2. full valid solution under the band rules,
/// 3. blanks removed one by one, keeping the solution unique,
/// 4. bank = removed numbers + decoys (each decoy re-checked),
/// 5. final solver check: exactly one solution.
Puzzle generatePuzzle(DifficultyConfig cfg, {required int seed, String bandId = ''}) {
  final rng = SeededRandom(seed);
  Puzzle? best;
  var bestBlanks = -1;

  for (var attempt = 0; attempt < 60; attempt++) {
    final lr = cfg.layout;
    final count = rng.range(lr.minEquations, lr.maxEquations);
    final layout = LayoutBuilder(lr, rng).build(count);
    if (layout == null) continue;

    for (var fillTry = 0; fillTry < 4; fillTry++) {
      final filled = Filler(cfg.numbers, rng).fill(layout);
      if (filled == null) continue;
      final (slots, solution) = filled;

      final numberCells = solution.keys.toList();
      final target = (cfg.blankRatio * numberCells.length).round().clamp(1, numberCells.length);
      final blanks = _carveBlanks(slots, solution, numberCells, target, rng);
      final bank = [for (final p in blanks) solution[p]!];
      final decoys = _addDecoys(cfg, slots, solution, blanks, bank, rng);
      rng.shuffle(bank);

      final check = countSolutions(
        slots: slots,
        givens: {for (final e in solution.entries) if (!blanks.contains(e.key)) e.key: e.value},
        blanks: blanks,
        bank: bank,
      );
      if (check.count != 1) continue;

      final puzzle = Puzzle(
        bandId: bandId,
        difficulty: cfg.difficulty,
        seed: seed,
        rows: layout.rows,
        cols: layout.cols,
        slots: slots,
        solution: solution,
        blanks: blanks.toList()..sort(),
        bank: bank,
        decoyCount: decoys,
      );
      // Accept when close enough to the target blank count; otherwise keep
      // the best so far and try a fresh fill.
      if (blanks.length >= target - 1) return puzzle;
      if (blanks.length > bestBlanks) {
        best = puzzle;
        bestBlanks = blanks.length;
      }
    }
  }
  if (best != null) return best;
  throw GenerationFailure('No puzzle for ${cfg.difficulty.name} (seed $seed)');
}

/// Puzzle for level [level] (1-based) of the Levels mode.
Puzzle generateLevel(BandConfig band, Difficulty difficulty, int level) => generatePuzzle(
      band[difficulty],
      seed: levelSeed(band.id, difficulty, level),
      bandId: band.id,
    );

/// Today's Daily Puzzle for a band and difficulty.
Puzzle generateDaily(BandConfig band, Difficulty difficulty, DateTime date) => generatePuzzle(
      band[difficulty],
      seed: dailySeed(date, band.id, difficulty),
      bandId: band.id,
    );

/// Blanks cells in random order, skipping any cell whose removal would make
/// the puzzle ambiguous.
Set<Pos> _carveBlanks(
  List<EquationSlot> slots,
  Map<Pos, int> solution,
  List<Pos> numberCells,
  int target,
  SeededRandom rng,
) {
  final order = List.of(numberCells);
  rng.shuffle(order);
  final blanks = <Pos>{};
  final givens = Map.of(solution);
  for (final p in order) {
    if (blanks.length >= target) break;
    blanks.add(p);
    givens.remove(p);
    final r = countSolutions(
      slots: slots,
      givens: givens,
      blanks: blanks,
      bank: [for (final b in blanks) solution[b]!],
    );
    if (r.count != 1) {
      blanks.remove(p);
      givens[p] = solution[p]!;
    }
  }
  return blanks;
}

/// Adds plausible wrong tiles (near misses of real values) that do not open
/// up a second solution. Returns how many were added.
int _addDecoys(
  DifficultyConfig cfg,
  List<EquationSlot> slots,
  Map<Pos, int> solution,
  Set<Pos> blanks,
  List<int> bank,
  SeededRandom rng,
) {
  if (cfg.decoys == 0 || blanks.isEmpty) return 0;
  final givens = {
    for (final e in solution.entries) if (!blanks.contains(e.key)) e.key: e.value,
  };
  final values = solution.values.toList();
  var added = 0;
  for (var t = 0; t < cfg.decoys * 10 && added < cfg.decoys; t++) {
    final v = _nearMiss(rng.pick(values), rng);
    if (!cfg.numbers.inRange(v) || bank.contains(v)) continue;
    final r = countSolutions(slots: slots, givens: givens, blanks: blanks, bank: [...bank, v]);
    if (r.count == 1) {
      bank.add(v);
      added++;
    }
  }
  return added;
}

int _nearMiss(int v, SeededRandom rng) {
  switch (rng.nextInt(5)) {
    case 0:
      return v + (rng.chance(0.5) ? 1 : -1);
    case 1:
      return v + (rng.chance(0.5) ? 2 : -2);
    case 2:
      return v + (rng.chance(0.5) ? 10 : -10);
    case 3:
      final reversed = int.parse(v.toString().split('').reversed.join());
      return reversed == v ? v + 11 : reversed;
    default:
      return v * 2;
  }
}
