import 'config.dart';
import 'model.dart';
import 'rng.dart';

/// Equation positions only (no operators or numbers yet).
class Layout {
  final List<Placement> slots;
  final int rows;
  final int cols;
  const Layout(this.slots, this.rows, this.cols);
}

class _Cell {
  final bool isNumber;
  int? across;
  int? down;
  _Cell(this.isNumber);

  int? slotIn(Direction d) => d == Direction.across ? across : down;
  void setSlot(Direction d, int i) => d == Direction.across ? across = i : down = i;
}

class _Candidate {
  final Placement placement;
  final double weight;
  const _Candidate(this.placement, this.weight);
}

/// Grows a connected crossword of equations, one equation at a time.
///
/// Crossings only happen on number cells (A, B or C of both equations).
/// Like a word crossword, equations never touch side by side and never run
/// into each other end to end, so every row/column run is one equation.
class LayoutBuilder {
  final LayoutRules rules;
  final SeededRandom rng;

  final _grid = <Pos, _Cell>{};
  final _slots = <Placement>[];
  int _minR = 0, _maxR = 0, _minC = 0, _maxC = 0;

  LayoutBuilder(this.rules, this.rng);

  static Direction _perp(Direction d) =>
      d == Direction.across ? Direction.down : Direction.across;

  /// Returns null if [count] equations could not be fitted.
  Layout? build(int count) {
    _grid.clear();
    _slots.clear();
    final first = Placement(
        const Pos(0, 0), rng.chance(0.5) ? Direction.across : Direction.down);
    _minR = _maxR = _minC = _maxC = 0;
    _place(first);

    while (_slots.length < count) {
      final candidates = _candidates();
      if (candidates.isEmpty) return null;
      final i = rng.weightedIndex([for (final c in candidates) c.weight]);
      _place(candidates[i].placement);
    }
    return _normalized();
  }

  List<_Candidate> _candidates() {
    final seen = <String>{};
    final out = <_Candidate>[];
    final oldArea = (_maxR - _minR + 1) * (_maxC - _minC + 1);
    for (final entry in _grid.entries) {
      final cell = entry.value;
      if (!cell.isNumber) continue;
      for (final dir in Direction.values) {
        if (cell.slotIn(dir) != null) continue;
        for (final k in const [0, 2, 4]) {
          final start = entry.key.step(dir, -k);
          final key = '${start.row},${start.col},${dir.index}';
          if (!seen.add(key)) continue;
          final crossings = _crossings(start, dir);
          if (crossings < 1) continue;

          final end = start.step(dir, 4);
          final minR = _min(_minR, start.row), maxR = _max(_maxR, end.row);
          final minC = _min(_minC, start.col), maxC = _max(_maxC, end.col);
          final h = maxR - minR + 1, w = maxC - minC + 1;
          if (h > rules.maxRows || w > rules.maxCols) continue;

          var weight = 1.0;
          if (crossings > 1) weight *= 1 + rules.crossingBias * 30 * (crossings - 1);
          // Prefer compact grids: they fit phone screens better.
          weight /= 1 + (h * w - oldArea) * 0.08;
          out.add(_Candidate(Placement(start, dir), weight));
        }
      }
    }
    return out;
  }

  /// Number of existing cells the placement would cross, or -1 if illegal.
  int _crossings(Pos start, Direction dir) {
    if (_grid.containsKey(start.step(dir, -1)) || _grid.containsKey(start.step(dir, 5))) {
      return -1;
    }
    final perp = _perp(dir);
    var crossings = 0;
    for (var i = 0; i < 5; i++) {
      final p = start.step(dir, i);
      final existing = _grid[p];
      if (existing != null) {
        if (!i.isEven || !existing.isNumber || existing.slotIn(dir) != null) return -1;
        crossings++;
      } else if (_grid.containsKey(p.step(perp, 1)) || _grid.containsKey(p.step(perp, -1))) {
        return -1;
      }
    }
    return crossings;
  }

  void _place(Placement p) {
    final index = _slots.length;
    _slots.add(p);
    for (var i = 0; i < 5; i++) {
      final pos = p.cell(i);
      final cell = _grid.putIfAbsent(pos, () => _Cell(i.isEven));
      cell.setSlot(p.direction, index);
    }
    final end = p.cell(4);
    _minR = _min(_minR, p.start.row);
    _maxR = _max(_maxR, end.row);
    _minC = _min(_minC, p.start.col);
    _maxC = _max(_maxC, end.col);
  }

  Layout _normalized() => Layout(
        [
          for (final s in _slots)
            Placement(Pos(s.start.row - _minR, s.start.col - _minC), s.direction),
        ],
        _maxR - _minR + 1,
        _maxC - _minC + 1,
      );

  static int _min(int a, int b) => a < b ? a : b;
  static int _max(int a, int b) => a > b ? a : b;
}
