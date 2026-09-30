// THE tuning file: every age band and difficulty knob lives here.
//
// Rules that apply to all bands (enforced by the generator and by tests):
// - results are never negative or fractional (whole numbers only);
// - division is always exact;
// - no zeros (minValue >= 1) and no x1 / ÷1 unless allowUnitFactors is set.

import 'config.dart';
import 'equation.dart';

/// Nobody under this age may play. There are no child bands in this app.
const int kMinimumAge = 13;

const _plusMinus = {Op.add: 1, Op.sub: 1};
const _noDivide = {Op.add: 2, Op.sub: 2, Op.mul: 3};
const _allFour = {Op.add: 2, Op.sub: 2, Op.mul: 3, Op.div: 3};

/// 13–15: + − × ÷, times tables up to 12×12, numbers 1–144, 4–8 equations,
/// friendlier pacing and more givens.
const BandConfig band13to15 = BandConfig(
  id: '13-15',
  minAge: 13,
  maxAge: 15,
  difficulties: {
    Difficulty.easy: DifficultyConfig(
      difficulty: Difficulty.easy,
      numbers: NumberRules(minValue: 1, maxValue: 20, opWeights: _plusMinus, maxFactor: 12),
      layout: LayoutRules(minEquations: 4, maxEquations: 5, maxRows: 9, maxCols: 9),
      blankRatio: 0.35,
      decoys: 0,
      mistakesAllowed: 5,
      showTimer: false,
      parTimeSeconds: 150,
    ),
    Difficulty.medium: DifficultyConfig(
      difficulty: Difficulty.medium,
      numbers: NumberRules(minValue: 1, maxValue: 50, opWeights: _noDivide, maxFactor: 10),
      layout: LayoutRules(minEquations: 5, maxEquations: 6, maxRows: 9, maxCols: 9),
      blankRatio: 0.45,
      decoys: 1,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 210,
    ),
    Difficulty.hard: DifficultyConfig(
      difficulty: Difficulty.hard,
      numbers: NumberRules(minValue: 1, maxValue: 100, opWeights: _allFour, maxFactor: 12),
      layout: LayoutRules(minEquations: 6, maxEquations: 7, maxRows: 11, maxCols: 11),
      blankRatio: 0.5,
      decoys: 2,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 270,
    ),
    Difficulty.expert: DifficultyConfig(
      difficulty: Difficulty.expert,
      numbers: NumberRules(minValue: 1, maxValue: 144, opWeights: _allFour, maxFactor: 12),
      layout: LayoutRules(minEquations: 7, maxEquations: 8, maxRows: 11, maxCols: 11, crossingBias: 0.3),
      blankRatio: 0.55,
      decoys: 3,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 330,
    ),
  },
);

/// 16–17: all four operations, up to 3 digits, 8–12 equations.
const BandConfig band16to17 = BandConfig(
  id: '16-17',
  minAge: 16,
  maxAge: 17,
  difficulties: {
    Difficulty.easy: DifficultyConfig(
      difficulty: Difficulty.easy,
      numbers: NumberRules(minValue: 1, maxValue: 200, opWeights: _noDivide, maxFactor: 12),
      layout: LayoutRules(minEquations: 8, maxEquations: 9, maxRows: 11, maxCols: 11),
      blankRatio: 0.45,
      decoys: 1,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 270,
    ),
    Difficulty.medium: DifficultyConfig(
      difficulty: Difficulty.medium,
      numbers: NumberRules(minValue: 1, maxValue: 500, opWeights: _allFour, maxFactor: 15),
      layout: LayoutRules(minEquations: 9, maxEquations: 10, maxRows: 11, maxCols: 11, crossingBias: 0.3),
      blankRatio: 0.5,
      decoys: 2,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 360,
    ),
    Difficulty.hard: DifficultyConfig(
      difficulty: Difficulty.hard,
      numbers: NumberRules(minValue: 1, maxValue: 999, opWeights: _allFour, maxFactor: 25),
      layout: LayoutRules(minEquations: 10, maxEquations: 11, maxRows: 13, maxCols: 13, crossingBias: 0.4),
      blankRatio: 0.55,
      decoys: 3,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 450,
    ),
    Difficulty.expert: DifficultyConfig(
      difficulty: Difficulty.expert,
      numbers: NumberRules(minValue: 1, maxValue: 999, opWeights: _allFour, maxFactor: 40),
      layout: LayoutRules(minEquations: 11, maxEquations: 12, maxRows: 13, maxCols: 13, crossingBias: 0.5),
      blankRatio: 0.6,
      decoys: 4,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 540,
    ),
  },
);

/// 18+: all four operations, up to 3 digits, 10–16 equations, dense
/// intersections at the top end.
const BandConfig band18plus = BandConfig(
  id: '18+',
  minAge: 18,
  maxAge: null,
  difficulties: {
    Difficulty.easy: DifficultyConfig(
      difficulty: Difficulty.easy,
      numbers: NumberRules(minValue: 1, maxValue: 300, opWeights: _allFour, maxFactor: 12),
      layout: LayoutRules(minEquations: 10, maxEquations: 11, maxRows: 13, maxCols: 13, crossingBias: 0.3),
      blankRatio: 0.45,
      decoys: 2,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 360,
    ),
    Difficulty.medium: DifficultyConfig(
      difficulty: Difficulty.medium,
      numbers: NumberRules(minValue: 1, maxValue: 999, opWeights: _allFour, maxFactor: 20),
      layout: LayoutRules(minEquations: 11, maxEquations: 13, maxRows: 13, maxCols: 13, crossingBias: 0.4),
      blankRatio: 0.55,
      decoys: 3,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 480,
    ),
    Difficulty.hard: DifficultyConfig(
      difficulty: Difficulty.hard,
      numbers: NumberRules(minValue: 1, maxValue: 999, opWeights: _allFour, maxFactor: 30),
      layout: LayoutRules(minEquations: 13, maxEquations: 14, maxRows: 13, maxCols: 13, crossingBias: 0.6),
      blankRatio: 0.62,
      decoys: 4,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 600,
    ),
    Difficulty.expert: DifficultyConfig(
      difficulty: Difficulty.expert,
      numbers: NumberRules(minValue: 1, maxValue: 999, opWeights: _allFour, maxFactor: 50),
      layout: LayoutRules(minEquations: 15, maxEquations: 16, maxRows: 13, maxCols: 13, crossingBias: 0.8),
      blankRatio: 0.7,
      decoys: 5,
      mistakesAllowed: 3,
      showTimer: true,
      parTimeSeconds: 780,
    ),
  },
);

const List<BandConfig> kBands = [band13to15, band16to17, band18plus];

/// Band for an age, or null when the player is under [kMinimumAge].
BandConfig? bandForAge(int age) {
  if (age < kMinimumAge) return null;
  for (final band in kBands) {
    if (band.containsAge(age)) return band;
  }
  return null;
}

BandConfig bandById(String id) => kBands.firstWhere((b) => b.id == id);
