import 'config.dart';
import 'equation.dart';
import 'layout_builder.dart';
import 'model.dart';
import 'rng.dart';

/// Picks operators and fills every number cell with a valid solution that
/// follows the band's [NumberRules]. Randomised backtracking over equations.
///
/// The operator of each equation is chosen while filling it (weighted random
/// order, falling back to the others), so equations whose cells were already
/// set by crossings can still be completed in dense, looped grids.
class Filler {
  final NumberRules rules;
  final SeededRandom rng;

  /// Max candidate triples tried per equation before backtracking further.
  final int perSlot;

  late List<Placement> _slots;
  late List<Op?> _ops;
  late List<int> _order;
  final _values = <Pos, int>{};
  int _budget = 0;

  Filler(this.rules, this.rng, {this.perSlot = 12});

  /// All allowed operators, in weighted random order (no repeats).
  List<Op> _opOrder() {
    final ops = rules.opWeights.keys.toList();
    final weights = [for (final o in ops) rules.opWeights[o]!.toDouble()];
    final out = <Op>[];
    while (ops.isNotEmpty) {
      final i = rng.weightedIndex(weights);
      out.add(ops.removeAt(i));
      weights.removeAt(i);
    }
    return out;
  }

  /// Returns the slots with operators and the solution, or null on failure.
  (List<EquationSlot>, Map<Pos, int>)? fill(Layout layout, {int budget = 3000}) {
    _slots = layout.slots;
    _ops = List.filled(_slots.length, null);
    _order = _bfsOrder();
    _values.clear();
    _budget = budget;
    if (!_fillFrom(0)) return null;
    return (
      [
        for (var i = 0; i < _slots.length; i++)
          EquationSlot(_slots[i].start, _slots[i].direction, _ops[i]!),
      ],
      Map.of(_values),
    );
  }

  /// Breadth-first from equation 0 so each next equation shares a cell with
  /// something already filled (keeps backtracking local).
  List<int> _bfsOrder() {
    final cellOwners = <Pos, List<int>>{};
    for (var i = 0; i < _slots.length; i++) {
      for (final p in _slots[i].numberCells) {
        cellOwners.putIfAbsent(p, () => []).add(i);
      }
    }
    final order = <int>[0];
    final seen = {0};
    for (var k = 0; k < order.length; k++) {
      for (final p in _slots[order[k]].numberCells) {
        for (final j in cellOwners[p]!) {
          if (seen.add(j)) order.add(j);
        }
      }
    }
    return order;
  }

  bool _fillFrom(int k) {
    if (k == _order.length) return true;
    if (--_budget < 0) return false;
    final slotIndex = _order[k];
    final cells = _slots[slotIndex].numberCells;
    final known = [for (final p in cells) _values[p]];
    for (final op in _opOrder()) {
      _ops[slotIndex] = op;
      for (final triple in candidates(op, known[0], known[1], known[2])) {
        final assigned = <Pos>[];
        for (var j = 0; j < 3; j++) {
          if (known[j] == null) {
            _values[cells[j]] = triple[j];
            assigned.add(cells[j]);
          }
        }
        if (_fillFrom(k + 1)) return true;
        for (final p in assigned) {
          _values.remove(p);
        }
        if (_budget < 0) return false;
      }
    }
    _ops[slotIndex] = null;
    return false;
  }

  /// Up to [perSlot] random valid `[a, b, c]` triples consistent with the
  /// already known values.
  List<List<int>> candidates(Op op, int? a, int? b, int? c) {
    final out = <List<int>>[];
    void tryAdd(int? x, int? y, int? z) {
      if (x != null && y != null && z != null && rules.allows(op, x, y, z)) {
        out.add([x, y, z]);
      }
    }

    final known = (a != null ? 1 : 0) + (b != null ? 1 : 0) + (c != null ? 1 : 0);
    if (known == 3) {
      tryAdd(a, b, c);
      return out;
    }
    if (known == 2) {
      final m = solveMissing(op, a, b, c);
      tryAdd(a ?? m, b ?? m, c ?? m);
      return out;
    }
    if (known == 1) {
      for (var v = rules.minValue; v <= rules.maxValue; v++) {
        if (a != null) {
          tryAdd(a, v, applyOp(op, a, v));
        } else if (b != null) {
          tryAdd(v, b, applyOp(op, v, b));
        } else {
          tryAdd(v, solveMissing(op, v, null, c), c);
        }
      }
      rng.shuffle(out);
      return out.length > perSlot ? out.sublist(0, perSlot) : out;
    }

    // Nothing known yet: sample.
    final lo = rules.minValue, hi = rules.maxValue;
    final fLo = rules.minFactor, fHi = rules.maxFactor;
    final seen = <int>{};
    for (var t = 0; t < perSlot * 8 && out.length < perSlot; t++) {
      int x, y;
      switch (op) {
        case Op.add:
          if (hi - lo < lo) return out;
          x = rng.range(lo, hi - lo);
          y = rng.range(lo, hi - x);
        case Op.sub:
          if (hi < 2 * lo) return out;
          x = rng.range(2 * lo, hi);
          y = rng.range(lo, x - lo);
        case Op.mul:
          if (fLo > fHi) return out;
          x = rng.range(fLo, fHi);
          final yHi = _minInt(fHi, hi ~/ x);
          if (yHi < fLo) continue;
          y = rng.range(fLo, yHi);
        case Op.div:
          if (fLo > fHi) return out;
          y = rng.range(fLo, fHi);
          final qHi = _minInt(fHi, hi ~/ y);
          if (qHi < fLo) continue;
          x = y * rng.range(fLo, qHi);
      }
      if (!seen.add(x * 100003 + y)) continue;
      tryAdd(x, y, applyOp(op, x, y));
    }
    return out;
  }

  static int _minInt(int a, int b) => a < b ? a : b;
}
