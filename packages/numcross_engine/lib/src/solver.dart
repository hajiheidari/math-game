import 'equation.dart';
import 'model.dart';

class SolveResult {
  /// Number of distinct solutions found, capped at the search limit.
  final int count;

  /// The first solution found (all number cells), if any.
  final Map<Pos, int>? solution;
  const SolveResult(this.count, this.solution);
}

/// Counts the ways to place bank tiles into the blank cells so that every
/// equation is arithmetically correct. Unused tiles (decoys) are allowed.
///
/// Uses plain arithmetic ([equationHolds]), not band rules: the player only
/// sees the numbers, so a second arithmetic solution counts even if the
/// generator would never have produced it.
SolveResult countSolutions({
  required List<EquationSlot> slots,
  required Map<Pos, int> givens,
  required Iterable<Pos> blanks,
  required Iterable<int> bank,
  int limit = 2,
}) {
  final index = <Pos, int>{};
  final positions = <Pos>[];
  int idOf(Pos p) => index.putIfAbsent(p, () {
        positions.add(p);
        return positions.length - 1;
      });

  final slotCells = [
    for (final s in slots) [for (final p in s.numberCells) idOf(p)],
  ];
  final values = List<int?>.filled(positions.length, null);
  for (var i = 0; i < positions.length; i++) {
    values[i] = givens[positions[i]];
  }
  for (final p in blanks) {
    final id = index[p];
    if (id != null) values[id] = null;
  }
  final cellSlots = List.generate(positions.length, (_) => <int>[]);
  for (var s = 0; s < slotCells.length; s++) {
    for (final c in slotCells[s]) {
      cellSlots[c].add(s);
    }
  }
  final counts = <int, int>{};
  for (final v in bank) {
    counts[v] = (counts[v] ?? 0) + 1;
  }

  final search = _Search(
    ops: [for (final s in slots) s.op],
    slotCells: slotCells,
    cellSlots: cellSlots,
    values: values,
    counts: counts,
    limit: limit,
  );
  if (!search.initiallyConsistent()) return const SolveResult(0, null);
  search.run();
  final first = search.first;
  return SolveResult(
    search.found,
    first == null ? null : {for (var i = 0; i < positions.length; i++) positions[i]: first[i]},
  );
}

class _Search {
  final List<Op> ops;
  final List<List<int>> slotCells;
  final List<List<int>> cellSlots;
  final List<int?> values;
  final Map<int, int> counts;
  final int limit;

  int found = 0;
  List<int>? first;
  int _unknown;

  _Search({
    required this.ops,
    required this.slotCells,
    required this.cellSlots,
    required this.values,
    required this.counts,
    required this.limit,
  }) : _unknown = values.where((v) => v == null).length;

  bool initiallyConsistent() {
    for (var s = 0; s < slotCells.length; s++) {
      if (!_slotOk(s)) return false;
    }
    return true;
  }

  bool _slotOk(int s) {
    final c = slotCells[s];
    final a = values[c[0]], b = values[c[1]], r = values[c[2]];
    if (a == null || b == null || r == null) return true;
    return equationHolds(ops[s], a, b, r);
  }

  bool _consistentAfter(int cell) {
    for (final s in cellSlots[cell]) {
      if (!_slotOk(s)) return false;
    }
    return true;
  }

  void _assign(int cell, int v) {
    values[cell] = v;
    counts[v] = counts[v]! - 1;
    _unknown--;
  }

  void _unassign(int cell) {
    final v = values[cell]!;
    values[cell] = null;
    counts[v] = counts[v]! + 1;
    _unknown++;
  }

  void _tryValue(int cell, int v) {
    _assign(cell, v);
    if (_consistentAfter(cell)) run();
    _unassign(cell);
  }

  void run() {
    if (found >= limit) return;
    if (_unknown == 0) {
      found++;
      first ??= [for (final v in values) v!];
      return;
    }

    // 1) An equation with one unknown forces that value.
    var branchCell = -1;
    var branchScore = -1;
    for (var s = 0; s < slotCells.length; s++) {
      final c = slotCells[s];
      var unknownAt = -1, unknowns = 0;
      for (var j = 0; j < 3; j++) {
        if (values[c[j]] == null) {
          unknowns++;
          unknownAt = j;
        }
      }
      if (unknowns == 1) {
        final v = solveMissing(
          ops[s],
          values[c[0]],
          values[c[1]],
          values[c[2]],
        );
        if (v == null || (counts[v] ?? 0) == 0) return; // dead end
        _tryValue(c[unknownAt], v);
        return;
      }
      if (unknowns == 2) {
        // Guessing one of these forces the other: prefer busy cells.
        for (var j = 0; j < 3; j++) {
          final cell = c[j];
          if (values[cell] == null && cellSlots[cell].length > branchScore) {
            branchScore = cellSlots[cell].length;
            branchCell = cell;
          }
        }
      }
    }

    // 2) Otherwise branch over distinct bank values.
    if (branchCell < 0) {
      branchCell = values.indexOf(null);
    }
    for (final v in counts.keys.toList()) {
      if (counts[v]! == 0) continue;
      _tryValue(branchCell, v);
      if (found >= limit) return;
    }
  }
}
