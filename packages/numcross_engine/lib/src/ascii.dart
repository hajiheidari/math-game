import 'model.dart';

/// Plain-text rendering for debugging and the preview CLI.
/// Blanks show as `__`, or their answer when [showSolution] is true.
String renderAscii(Puzzle puzzle, {bool showSolution = false}) {
  final buf = StringBuffer();
  for (var r = 0; r < puzzle.rows; r++) {
    for (var c = 0; c < puzzle.cols; c++) {
      final p = Pos(r, c);
      final info = puzzle.cellAt(p);
      final String text;
      switch (info.kind) {
        case CellKind.empty:
          text = '';
        case CellKind.operator:
          text = info.op!.symbol;
        case CellKind.equals:
          text = '=';
        case CellKind.number:
          final blank = puzzle.blanks.contains(p);
          text = blank && !showSolution ? '__' : '${puzzle.solution[p]}';
      }
      buf.write(text.padLeft(4));
    }
    buf.writeln();
  }
  return buf.toString();
}
