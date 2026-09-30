import 'package:numcross_engine/numcross_engine.dart';
import 'package:test/test.dart';

void main() {
  // Two crossing equations:
  //   A + B = C      (across, row 0)
  //   A          (down from A)  A × D = E
  const across = EquationSlot(Pos(0, 0), Direction.across, Op.add);
  const down = EquationSlot(Pos(0, 0), Direction.down, Op.mul);
  const slots = [across, down];
  const a = Pos(0, 0), b = Pos(0, 2), c = Pos(0, 4), d = Pos(2, 0), e = Pos(4, 0);

  test('unique: one blank forced by its equation', () {
    final r = countSolutions(
      slots: slots,
      givens: {a: 3, b: 4, d: 5, e: 15},
      blanks: [c],
      bank: [7],
    );
    expect(r.count, 1);
    expect(r.solution![c], 7);
  });

  test('ambiguous: two ways to use the bank', () {
    // 3 + ? = ?  with bank {4, 7} and {5, 8}: both 4/7 and ... only one pair
    // sums correctly, but swapping B and C with bank {2, 5, 3, 8}? Build a
    // real ambiguity: A and B both blank in A + B = 10 with bank {4, 6}.
    final r = countSolutions(
      slots: [across],
      givens: {c: 10},
      blanks: [a, b],
      bank: [4, 6],
    );
    expect(r.count, 2);
  });

  test('duplicate tiles are not counted twice', () {
    final r = countSolutions(
      slots: [across],
      givens: {c: 10},
      blanks: [a, b],
      bank: [5, 5],
    );
    expect(r.count, 1);
  });

  test('decoy that fits nowhere keeps it unique', () {
    final r = countSolutions(
      slots: slots,
      givens: {a: 3, b: 4, d: 5},
      blanks: [c, e],
      bank: [7, 15, 99],
    );
    expect(r.count, 1);
    expect(r.solution![e], 15);
  });

  test('no solution', () {
    final r = countSolutions(
      slots: [across],
      givens: {a: 3, b: 4},
      blanks: [c],
      bank: [8],
    );
    expect(r.count, 0);
  });

  test('wrong givens are rejected up front', () {
    final r = countSolutions(
      slots: [across],
      givens: {a: 3, b: 4, c: 8},
      blanks: const [],
      bank: const [],
    );
    expect(r.count, 0);
  });
}
