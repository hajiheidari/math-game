import 'package:numcross_engine/numcross_engine.dart';
import 'package:test/test.dart';

const levelsPerConfig = 25;

void main() {
  for (final band in kBands) {
    for (final difficulty in Difficulty.values) {
      final cfg = band[difficulty];
      group('${band.id} ${difficulty.name}', () {
        final puzzles = [
          for (var l = 1; l <= levelsPerConfig; l++) generateLevel(band, difficulty, l),
        ];

        test('every equation is correct and follows band rules', () {
          for (final p in puzzles) {
            for (final s in p.slots) {
              final [a, b, c] = [for (final cell in s.numberCells) p.solution[cell]!];
              expect(equationHolds(s.op, a, b, c), isTrue, reason: '$a ${s.op.symbol} $b = $c');
              expect(cfg.numbers.allows(s.op, a, b, c), isTrue,
                  reason: 'band rule broken: $a ${s.op.symbol} $b = $c');
            }
            for (final v in p.solution.values) {
              expect(v, greaterThanOrEqualTo(0));
              expect(cfg.numbers.inRange(v), isTrue);
            }
          }
        });

        test('shape matches config', () {
          for (final p in puzzles) {
            expect(p.slots.length, inInclusiveRange(1, cfg.layout.maxEquations));
            expect(p.rows, lessThanOrEqualTo(cfg.layout.maxRows));
            expect(p.cols, lessThanOrEqualTo(cfg.layout.maxCols));
            expect(p.decoyCount, lessThanOrEqualTo(cfg.decoys));
            expect(p.bank.length, p.blanks.length + p.decoyCount);
          }
          final avgEqs = puzzles.map((p) => p.slots.length).reduce((a, b) => a + b) / puzzles.length;
          expect(avgEqs, greaterThanOrEqualTo(cfg.layout.minEquations - 0.5));
        });

        test('bank = blank answers + decoys', () {
          for (final p in puzzles) {
            final remaining = List.of(p.bank);
            for (final cell in p.blanks) {
              expect(remaining.remove(p.solution[cell]), isTrue);
            }
            expect(remaining.length, p.decoyCount);
          }
        });

        test('exactly one solution, equal to the stored one', () {
          for (final p in puzzles) {
            final r = countSolutions(
              slots: p.slots,
              givens: {for (final g in p.givens) g: p.solution[g]!},
              blanks: p.blanks,
              bank: p.bank,
              limit: 3,
            );
            expect(r.count, 1);
            for (final cell in p.blanks) {
              expect(r.solution![cell], p.solution[cell]);
            }
          }
        });

        test('blank ratio near target', () {
          final avg = puzzles
                  .map((p) => p.blanks.length / p.solution.length)
                  .reduce((a, b) => a + b) /
              puzzles.length;
          expect(avg, closeTo(cfg.blankRatio, 0.08));
        });
      });
    }
  }

  group('deterministic seeding', () {
    test('same level => identical puzzle', () {
      for (final band in kBands) {
        for (final d in Difficulty.values) {
          final a = generateLevel(band, d, 42).toJson();
          final b = generateLevel(band, d, 42).toJson();
          expect(a, b);
        }
      }
    });

    test('different levels differ', () {
      final seen = <String>{};
      for (var l = 1; l <= 20; l++) {
        seen.add(generateLevel(band18plus, Difficulty.medium, l).toJson()['solution'].toString());
      }
      expect(seen.length, 20);
    });

    test('daily: same date => same puzzle, next day => different', () {
      final day = DateTime(2026, 9, 30);
      final a = generateDaily(band16to17, Difficulty.hard, day).toJson();
      final b = generateDaily(band16to17, Difficulty.hard, DateTime(2026, 9, 30, 23, 59)).toJson();
      final c = generateDaily(band16to17, Difficulty.hard, DateTime(2026, 10, 1)).toJson();
      expect(a, b);
      expect(a, isNot(c));
    });

    test('seeds are stable (golden values)', () {
      // If these change, every player's levels change. Only update on purpose
      // together with generatorNamespace.
      // Reference values from the JavaScript Mulberry32 / FNV-1a.
      final rng = SeededRandom(1);
      expect(rng.nextUint32(), 2693262067);
      expect(rng.nextUint32(), 11749833);
      expect(fnv1a32('a'), 0xE40C292C);
    });

    test('JSON round trip', () {
      final p = generateLevel(band13to15, Difficulty.hard, 3);
      expect(Puzzle.fromJson(p.toJson()).toJson(), p.toJson());
    });
  });

  test('generation time stays within budget (<300 ms each)', () {
    final sw = Stopwatch();
    var worst = 0;
    for (final band in kBands) {
      for (final d in Difficulty.values) {
        for (var l = 100; l < 105; l++) {
          sw
            ..reset()
            ..start();
          generateLevel(band, d, l);
          worst = worst > sw.elapsedMilliseconds ? worst : sw.elapsedMilliseconds;
        }
      }
    }
    expect(worst, lessThan(300));
  });
}
