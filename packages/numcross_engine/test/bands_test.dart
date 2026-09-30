import 'package:numcross_engine/numcross_engine.dart';
import 'package:test/test.dart';

void main() {
  test('under 13 has no band', () {
    for (var age = 0; age < 13; age++) {
      expect(bandForAge(age), isNull);
    }
  });

  test('ages map to the right band', () {
    expect(bandForAge(13)!.id, '13-15');
    expect(bandForAge(15)!.id, '13-15');
    expect(bandForAge(16)!.id, '16-17');
    expect(bandForAge(17)!.id, '16-17');
    expect(bandForAge(18)!.id, '18+');
    expect(bandForAge(99)!.id, '18+');
  });

  test('every band has all four difficulties and sane rules', () {
    for (final band in kBands) {
      expect(band.minAge, greaterThanOrEqualTo(kMinimumAge));
      for (final d in Difficulty.values) {
        final cfg = band[d];
        expect(cfg.difficulty, d);
        expect(cfg.numbers.minValue, greaterThanOrEqualTo(1));
        expect(cfg.numbers.maxValue, lessThanOrEqualTo(999));
        expect(cfg.blankRatio, inExclusiveRange(0, 1));
        expect(cfg.layout.minEquations, lessThanOrEqualTo(cfg.layout.maxEquations));
      }
    }
  });

  test('13-15 stays within 12x12 tables and 144', () {
    for (final d in Difficulty.values) {
      final n = band13to15[d].numbers;
      expect(n.maxFactor, lessThanOrEqualTo(12));
      expect(n.maxValue, lessThanOrEqualTo(144));
    }
  });

  test('stars and mistakes', () {
    final cfg = band18plus[Difficulty.easy];
    expect(computeStars(cfg, mistakes: 0, seconds: cfg.parTimeSeconds), 3);
    expect(computeStars(cfg, mistakes: 1, seconds: cfg.parTimeSeconds), 2);
    expect(computeStars(cfg, mistakes: 2, seconds: 1), 1);
    expect(isOutOfMistakes(cfg, 2), isFalse);
    expect(isOutOfMistakes(cfg, 3), isTrue);
  });
}
