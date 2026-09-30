import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/game/game_controller.dart';
import 'package:numcross_engine/numcross_engine.dart';

GameController newGame({Difficulty d = Difficulty.hard, int level = 1}) =>
    GameController(generateLevel(band13to15, d, level), band13to15[d]);

int rightTile(GameController g, Pos cell) => g.bankOrder.firstWhere(
  (i) => g.tileValue(i) == g.puzzle.solution[cell] && !g.isTileUsed(i),
);

int wrongTile(GameController g, Pos cell) => g.bankOrder.firstWhere(
  (i) => g.tileValue(i) != g.puzzle.solution[cell] && !g.isTileUsed(i),
);

void solveAll(GameController g) {
  for (final cell in g.puzzle.blanks) {
    g.place(rightTile(g, cell), cell);
  }
}

void main() {
  test('correct tile stays, wrong tile is a mistake and bounces back', () {
    final g = newGame();
    final cell = g.puzzle.blanks.first;
    final wrong = wrongTile(g, cell);
    expect(g.place(wrong, cell), PlaceResult.wrong);
    expect(g.mistakes, 1);
    expect(g.isFilled(cell), isFalse);
    expect(g.isTileUsed(wrong), isFalse);
    expect(g.errorCell, cell);

    final right = rightTile(g, cell);
    expect(g.place(right, cell), PlaceResult.correct);
    expect(g.isFilled(cell), isTrue);
    expect(g.isTileUsed(right), isTrue);
    expect(g.errorCell, isNull);
  });

  test('used tiles, givens and filled cells are ignored', () {
    final g = newGame();
    final [a, b, ...] = g.puzzle.blanks;
    final tile = rightTile(g, a);
    g.place(tile, a);
    expect(g.place(tile, b), PlaceResult.ignored);
    expect(
      g.place(wrongTile(g, a), a),
      PlaceResult.ignored,
      reason: 'cell already filled',
    );
    final given = g.puzzle.givens.first;
    expect(g.place(g.bankOrder.first, given), PlaceResult.ignored);
    expect(g.mistakes, 0);
  });

  test('mistake limit loses the level and blocks input', () {
    final g = newGame();
    final cell = g.puzzle.blanks.first;
    for (var i = 0; i < g.config.mistakesAllowed!; i++) {
      g.place(wrongTile(g, cell), cell);
    }
    expect(g.status, GameStatus.lost);
    expect(g.place(rightTile(g, cell), cell), PlaceResult.ignored);
  });

  test('filling every blank wins with stars', () {
    final g = newGame();
    solveAll(g);
    expect(g.status, GameStatus.won);
    expect(g.remainingBlanks, 0);
    expect(g.stars, 3);
  });

  test('stars drop with mistakes and time', () {
    final g = newGame();
    final cell = g.puzzle.blanks.first;
    g.place(wrongTile(g, cell), cell);
    g.tick(Duration(seconds: g.config.parTimeSeconds + 1));
    solveAll(g);
    expect(g.stars, 2);
  });

  test('tap tile then tap cell, and tap cell then tap tile', () {
    final g = newGame();
    final [a, b, ...] = g.puzzle.blanks;
    final ta = rightTile(g, a);
    g.tapTile(ta);
    expect(g.selectedTile, ta);
    g.tapCell(a);
    expect(g.isFilled(a), isTrue);
    expect(g.selectedTile, isNull);

    g.tapCell(b);
    expect(g.selectedCell, b);
    g.tapTile(rightTile(g, b));
    expect(g.isFilled(b), isTrue);
    expect(g.selectedCell, isNull);
  });

  test('undo takes back the last placement but not the mistakes', () {
    final g = newGame();
    final [a, b, ...] = g.puzzle.blanks;
    g.place(wrongTile(g, a), a);
    g.place(rightTile(g, a), a);
    g.place(rightTile(g, b), b);
    expect(g.undo(), isTrue);
    expect(g.isFilled(b), isFalse);
    expect(g.isFilled(a), isTrue);
    expect(g.mistakes, 1);
    expect(g.undo(), isTrue);
    expect(g.undo(), isFalse);
  });

  test('hint fills the selected cell, is not undoable, can win', () {
    final g = newGame();
    final target = g.puzzle.blanks.last;
    g.tapCell(target);
    expect(g.hint(), isTrue);
    expect(g.isFilled(target), isTrue);
    expect(g.isHinted(target), isTrue);
    expect(g.hintsUsed, 1);
    expect(g.canUndo, isFalse);
    while (g.status == GameStatus.playing) {
      expect(g.hint(), isTrue);
    }
    expect(g.status, GameStatus.won);
    expect(g.hint(), isFalse);
  });

  test('sort toggles ascending order and back', () {
    final g = newGame(d: Difficulty.expert);
    final original = g.bankOrder;
    g.toggleSort();
    final values = [for (final i in g.bankOrder) g.tileValue(i)];
    expect(values, [...values]..sort());
    g.toggleSort();
    expect(g.bankOrder, original);
  });

  test('clock runs only while playing; restart resets everything', () {
    final g = newGame();
    g.tick(const Duration(seconds: 5));
    g.pause();
    g.tick(const Duration(seconds: 5));
    expect(g.elapsed, const Duration(seconds: 5));
    g.resume();
    final cell = g.puzzle.blanks.first;
    g.place(wrongTile(g, cell), cell);
    g.place(rightTile(g, cell), cell);
    g.restart();
    expect(g.elapsed, Duration.zero);
    expect(g.mistakes, 0);
    expect(g.remainingBlanks, g.puzzle.blanks.length);
    expect(g.status, GameStatus.playing);
  });

  test('formatClock', () {
    expect(formatClock(const Duration(seconds: 65)), '1:05');
    expect(
      formatClock(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });
}
