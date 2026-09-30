import 'config.dart';
import 'equation.dart';

enum Direction { across, down }

class Pos implements Comparable<Pos> {
  final int row;
  final int col;
  const Pos(this.row, this.col);

  Pos step(Direction d, int n) =>
      d == Direction.across ? Pos(row, col + n) : Pos(row + n, col);

  @override
  bool operator ==(Object other) => other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => row * 4099 + col;

  @override
  int compareTo(Pos other) => row != other.row ? row - other.row : col - other.col;

  @override
  String toString() => '($row,$col)';
}

/// Where an equation sits: 5 consecutive cells `A op B = C`.
class Placement {
  final Pos start;
  final Direction direction;
  const Placement(this.start, this.direction);

  Pos cell(int i) => start.step(direction, i);

  /// Cells holding numbers: A, B, C.
  List<Pos> get numberCells => [cell(0), cell(2), cell(4)];
}

/// A placed equation with its operator.
class EquationSlot extends Placement {
  final Op op;
  const EquationSlot(super.start, super.direction, this.op);
}

enum CellKind { empty, number, operator, equals }

class CellInfo {
  final CellKind kind;

  /// Operator for [CellKind.operator] cells.
  final Op? op;
  const CellInfo(this.kind, [this.op]);
  static const empty = CellInfo(CellKind.empty);
}

/// A generated puzzle, ready for the game screen.
class Puzzle {
  final String bandId;
  final Difficulty difficulty;
  final int seed;
  final int rows;
  final int cols;
  final List<EquationSlot> slots;

  /// Correct value of every number cell.
  final Map<Pos, int> solution;

  /// Number cells the player must fill (sorted row-major).
  final List<Pos> blanks;

  /// Tiles offered to the player: blank values + decoys, shuffled.
  final List<int> bank;

  final int decoyCount;

  const Puzzle({
    required this.bandId,
    required this.difficulty,
    required this.seed,
    required this.rows,
    required this.cols,
    required this.slots,
    required this.solution,
    required this.blanks,
    required this.bank,
    required this.decoyCount,
  });

  Iterable<Pos> get givens => solution.keys.where((p) => !blanks.contains(p));

  CellInfo cellAt(Pos p) {
    for (final s in slots) {
      for (var i = 0; i < 5; i++) {
        if (s.cell(i) != p) continue;
        if (i.isEven) return const CellInfo(CellKind.number);
        return i == 1 ? CellInfo(CellKind.operator, s.op) : const CellInfo(CellKind.equals);
      }
    }
    return CellInfo.empty;
  }

  Map<String, Object?> toJson() => {
        'band': bandId,
        'difficulty': difficulty.name,
        'seed': seed,
        'rows': rows,
        'cols': cols,
        'slots': [
          for (final s in slots)
            [s.start.row, s.start.col, s.direction.name, s.op.name],
        ],
        'solution': [
          for (final e in (solution.entries.toList()..sort((a, b) => a.key.compareTo(b.key))))
            [e.key.row, e.key.col, e.value],
        ],
        'blanks': [for (final p in blanks) [p.row, p.col]],
        'bank': bank,
        'decoys': decoyCount,
      };

  factory Puzzle.fromJson(Map<String, Object?> json) {
    List<Object?> list(String k) => json[k]! as List<Object?>;
    return Puzzle(
      bandId: json['band']! as String,
      difficulty: Difficulty.values.byName(json['difficulty']! as String),
      seed: json['seed']! as int,
      rows: json['rows']! as int,
      cols: json['cols']! as int,
      slots: [
        for (final s in list('slots').cast<List<Object?>>())
          EquationSlot(Pos(s[0]! as int, s[1]! as int), Direction.values.byName(s[2]! as String),
              Op.values.byName(s[3]! as String)),
      ],
      solution: {
        for (final e in list('solution').cast<List<Object?>>())
          Pos(e[0]! as int, e[1]! as int): e[2]! as int,
      },
      blanks: [
        for (final p in list('blanks').cast<List<Object?>>()) Pos(p[0]! as int, p[1]! as int),
      ],
      bank: list('bank').cast<int>().toList(),
      decoyCount: json['decoys']! as int,
    );
  }
}
