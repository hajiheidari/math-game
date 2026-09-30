import 'package:numcross_engine/numcross_engine.dart';
import 'package:test/test.dart';

void main() {
  group('applyOp / equationHolds', () {
    test('basic arithmetic', () {
      expect(applyOp(Op.add, 7, 15), 22);
      expect(applyOp(Op.sub, 20, 5), 15);
      expect(applyOp(Op.mul, 6, 7), 42);
      expect(applyOp(Op.div, 42, 7), 6);
    });

    test('never negative', () {
      expect(applyOp(Op.sub, 5, 20), isNull);
      expect(equationHolds(Op.sub, 5, 20, -15), isFalse);
    });

    test('never fractional, never divide by zero', () {
      expect(applyOp(Op.div, 10, 4), isNull);
      expect(applyOp(Op.div, 10, 0), isNull);
      expect(equationHolds(Op.div, 10, 4, 2), isFalse);
    });
  });

  group('solveMissing', () {
    test('each position, each operator', () {
      expect(solveMissing(Op.add, null, 15, 22), 7);
      expect(solveMissing(Op.add, 7, null, 22), 15);
      expect(solveMissing(Op.sub, null, 5, 15), 20);
      expect(solveMissing(Op.sub, 20, null, 15), 5);
      expect(solveMissing(Op.mul, null, 7, 42), 6);
      expect(solveMissing(Op.mul, 6, null, 42), 7);
      expect(solveMissing(Op.div, null, 7, 6), 42);
      expect(solveMissing(Op.div, 42, null, 6), 7);
      expect(solveMissing(Op.div, 42, 7, null), 6);
    });

    test('no whole non-negative answer => null', () {
      expect(solveMissing(Op.add, 30, null, 22), isNull);
      expect(solveMissing(Op.mul, null, 5, 42), isNull);
      expect(solveMissing(Op.div, 42, null, 5), isNull);
      expect(solveMissing(Op.sub, 5, null, 15), isNull);
    });
  });

  group('NumberRules.allows (band rules)', () {
    final teen = band13to15[Difficulty.expert].numbers;

    test('times tables up to 12x12 only', () {
      expect(teen.allows(Op.mul, 12, 12, 144), isTrue);
      expect(teen.allows(Op.mul, 13, 11, 143), isFalse);
      expect(teen.allows(Op.div, 144, 12, 12), isTrue);
      expect(teen.allows(Op.div, 130, 13, 10), isFalse);
    });

    test('range limits', () {
      expect(teen.allows(Op.add, 100, 45, 145), isFalse);
      expect(teen.allows(Op.sub, 10, 10, 0), isFalse, reason: 'no zeros');
    });

    test('no x1 or ÷1 by default', () {
      expect(teen.allows(Op.mul, 1, 9, 9), isFalse);
      expect(teen.allows(Op.div, 9, 1, 9), isFalse);
      expect(teen.allows(Op.div, 9, 9, 1), isFalse);
    });

    test('disallowed operators', () {
      final easy = band13to15[Difficulty.easy].numbers;
      expect(easy.allows(Op.mul, 2, 3, 6), isFalse);
    });
  });
}
