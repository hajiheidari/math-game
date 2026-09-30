import 'dart:math' as math;

import 'equation.dart';

enum Difficulty { easy, medium, hard, expert }

/// Which numbers and operators a puzzle may contain.
class NumberRules {
  /// Smallest number allowed anywhere in the grid. Must be >= 1: zero makes
  /// equations like `0 × ? = 0` ambiguous and trivial.
  final int minValue;

  /// Largest number allowed anywhere in the grid (operands and results).
  final int maxValue;

  /// Relative frequency of each operator. Omitted operators are not used.
  final Map<Op, int> opWeights;

  /// For ×: both factors <= maxFactor. For ÷: divisor and quotient
  /// <= maxFactor (i.e. division is the inverse of the allowed times table).
  final int maxFactor;

  /// Whether ×1 and ÷1 (and a ÷ a = 1) are allowed. They are dull, so off by
  /// default.
  final bool allowUnitFactors;

  const NumberRules({
    required this.minValue,
    required this.maxValue,
    required this.opWeights,
    required this.maxFactor,
    this.allowUnitFactors = false,
  });

  int get minFactor =>
      allowUnitFactors ? math.max(minValue, 1) : math.max(minValue, 2);

  bool inRange(int v) => v >= minValue && v <= maxValue;

  /// Band rule check for one equation. Stricter than [equationHolds].
  bool allows(Op op, int a, int b, int c) {
    if (!opWeights.containsKey(op)) return false;
    if (!inRange(a) || !inRange(b) || !inRange(c)) return false;
    if (!equationHolds(op, a, b, c)) return false;
    switch (op) {
      case Op.add:
      case Op.sub:
        return true;
      case Op.mul:
        return a >= minFactor && b >= minFactor && a <= maxFactor && b <= maxFactor;
      case Op.div:
        return b >= minFactor && c >= minFactor && b <= maxFactor && c <= maxFactor;
    }
  }
}

/// Shape of the grid.
class LayoutRules {
  final int minEquations;
  final int maxEquations;
  final int maxRows;
  final int maxCols;

  /// 0..1. Higher = prefer placements that cross several existing equations
  /// at once (denser, loop-y grids with more intersections).
  final double crossingBias;

  const LayoutRules({
    required this.minEquations,
    required this.maxEquations,
    required this.maxRows,
    required this.maxCols,
    this.crossingBias = 0.2,
  });
}

/// All knobs for one band x difficulty.
class DifficultyConfig {
  final Difficulty difficulty;
  final NumberRules numbers;
  final LayoutRules layout;

  /// Share of number cells that start blank (0..1). The generator gets as
  /// close as it can while keeping the solution unique.
  final double blankRatio;

  /// Extra wrong tiles in the bank.
  final int decoys;

  /// Mistakes that end the level. Null = unlimited.
  final int? mistakesAllowed;

  final bool showTimer;

  /// Target solve time used for stars.
  final int parTimeSeconds;

  const DifficultyConfig({
    required this.difficulty,
    required this.numbers,
    required this.layout,
    required this.blankRatio,
    required this.decoys,
    required this.mistakesAllowed,
    required this.showTimer,
    required this.parTimeSeconds,
  });
}

/// An age band with its own set of difficulties.
class BandConfig {
  final String id;
  final int minAge;

  /// Inclusive; null = no upper bound.
  final int? maxAge;
  final Map<Difficulty, DifficultyConfig> difficulties;

  const BandConfig({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.difficulties,
  });

  DifficultyConfig operator [](Difficulty d) => difficulties[d]!;

  bool containsAge(int age) => age >= minAge && (maxAge == null || age <= maxAge!);
}
