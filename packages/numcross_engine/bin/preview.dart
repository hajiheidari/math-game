// Prints a generated puzzle.
//   dart run bin/preview.dart <band> <difficulty> <level>
//   dart run bin/preview.dart 18+ expert 7
import 'package:numcross_engine/numcross_engine.dart';

void main(List<String> args) {
  final band = bandById(args.isNotEmpty ? args[0] : '13-15');
  final difficulty = Difficulty.values.byName(args.length > 1 ? args[1] : 'easy');
  final level = args.length > 2 ? int.parse(args[2]) : 1;

  final sw = Stopwatch()..start();
  final puzzle = generateLevel(band, difficulty, level);
  sw.stop();

  print('Band ${band.id} · ${difficulty.name} · level $level '
      '(${puzzle.slots.length} equations, ${puzzle.rows}x${puzzle.cols}, '
      '${puzzle.blanks.length}/${puzzle.solution.length} blank, '
      '${puzzle.decoyCount} decoys, ${sw.elapsedMilliseconds} ms)\n');
  print(renderAscii(puzzle));
  print('Bank: ${puzzle.bank.join('  ')}\n');
  print('Solution:\n${renderAscii(puzzle, showSolution: true)}');
}
