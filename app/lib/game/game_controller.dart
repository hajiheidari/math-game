import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';

enum GameStatus { playing, paused, won, lost }

enum PlaceResult { correct, wrong, ignored }

/// State and rules of one level. No widgets, so it can be unit tested.
///
/// Rules: a tile dropped on a blank is checked at once. Correct tiles stay;
/// a wrong tile counts as a mistake and goes back to the bank. Reaching the
/// band's mistake limit loses the level. Filling every blank wins it.
class GameController extends ChangeNotifier {
  final Puzzle puzzle;
  final DifficultyConfig config;

  GameController(this.puzzle, this.config)
    : _blanks = puzzle.blanks.toSet(),
      _order = List.generate(puzzle.bank.length, (i) => i);

  final Set<Pos> _blanks;

  /// Blank cell -> index of the bank tile placed there.
  final Map<Pos, int> _filled = {};
  final Set<Pos> _hinted = {};
  final List<Pos> _undoStack = [];
  List<int> _order;
  bool _sorted = false;

  int _revision = 0;
  int _mistakes = 0;
  int _hintsUsed = 0;
  Duration _elapsed = Duration.zero;
  GameStatus _status = GameStatus.playing;

  int? _selectedTile;
  Pos? _selectedCell;
  Pos? _errorCell;

  // --- Read-only state -----------------------------------------------------

  GameStatus get status => _status;

  /// Bumps whenever something worth saving changes (not on clock ticks).
  int get revision => _revision;
  int get mistakes => _mistakes;
  int get hintsUsed => _hintsUsed;
  Duration get elapsed => _elapsed;
  bool get isSorted => _sorted;
  int? get selectedTile => _selectedTile;
  Pos? get selectedCell => _selectedCell;

  /// Cell that just received a wrong tile (for a short red flash).
  Pos? get errorCell => _errorCell;

  /// Bank tile indexes in display order.
  List<int> get bankOrder => List.unmodifiable(_order);
  int tileValue(int index) => puzzle.bank[index];
  bool isTileUsed(int index) => _filled.containsValue(index);

  bool isBlank(Pos p) => _blanks.contains(p);
  bool isFilled(Pos p) => _filled.containsKey(p);
  bool isHinted(Pos p) => _hinted.contains(p);
  bool get canUndo => _undoStack.isNotEmpty && _status == GameStatus.playing;
  int get remainingBlanks => _blanks.length - _filled.length;

  int get stars =>
      computeStars(config, mistakes: _mistakes, seconds: _elapsed.inSeconds);

  // --- Actions -------------------------------------------------------------

  /// Tries to put bank tile [tileIndex] on [cell].
  PlaceResult place(int tileIndex, Pos cell) {
    if (_status != GameStatus.playing ||
        !_blanks.contains(cell) ||
        _filled.containsKey(cell) ||
        isTileUsed(tileIndex)) {
      return PlaceResult.ignored;
    }
    _selectedTile = null;
    _selectedCell = null;
    if (puzzle.bank[tileIndex] == puzzle.solution[cell]) {
      _filled[cell] = tileIndex;
      _undoStack.add(cell);
      _errorCell = null;
      if (_filled.length == _blanks.length) _status = GameStatus.won;
      _saveable();
      return PlaceResult.correct;
    }
    _mistakes++;
    _errorCell = cell;
    if (isOutOfMistakes(config, _mistakes)) _status = GameStatus.lost;
    _saveable();
    return PlaceResult.wrong;
  }

  /// Tap on a bank tile: places it on the selected cell, or (de)selects it.
  void tapTile(int index) {
    if (_status != GameStatus.playing || isTileUsed(index)) return;
    final cell = _selectedCell;
    if (cell != null) {
      place(index, cell);
      return;
    }
    _selectedTile = _selectedTile == index ? null : index;
    notifyListeners();
  }

  /// Tap on a grid cell: places the selected tile, or (de)selects the cell.
  void tapCell(Pos cell) {
    if (_status != GameStatus.playing ||
        !_blanks.contains(cell) ||
        _filled.containsKey(cell)) {
      return;
    }
    final tile = _selectedTile;
    if (tile != null) {
      place(tile, cell);
      return;
    }
    _selectedCell = _selectedCell == cell ? null : cell;
    notifyListeners();
  }

  void clearError() {
    if (_errorCell == null) return;
    _errorCell = null;
    notifyListeners();
  }

  /// Takes back the last tile the player placed (hints can't be undone).
  /// Mistakes are not refunded.
  bool undo() {
    if (!canUndo) return false;
    _filled.remove(_undoStack.removeLast());
    _selectedTile = null;
    _selectedCell = null;
    _saveable();
    return true;
  }

  /// Fills one blank with its answer: the selected cell if any, otherwise
  /// the first open blank in reading order. Paying for it (coin or rewarded
  /// ad) is the caller's job.
  bool hint() {
    if (_status != GameStatus.playing) return false;
    final open = puzzle.blanks.where((p) => !_filled.containsKey(p));
    if (open.isEmpty) return false;
    final sel = _selectedCell;
    final cell = sel != null && !_filled.containsKey(sel) ? sel : open.first;
    final value = puzzle.solution[cell];
    final tile = _order.firstWhere(
      (i) => puzzle.bank[i] == value && !isTileUsed(i),
      orElse: () => -1,
    );
    if (tile < 0) return false;
    _filled[cell] = tile;
    _hinted.add(cell);
    _hintsUsed++;
    _selectedTile = null;
    _selectedCell = null;
    _errorCell = null;
    if (_filled.length == _blanks.length) _status = GameStatus.won;
    _saveable();
    return true;
  }

  /// Toggles between shuffled (original) and ascending order.
  void toggleSort() {
    _sorted = !_sorted;
    _order = List.generate(puzzle.bank.length, (i) => i);
    if (_sorted) {
      _order.sort((a, b) => puzzle.bank[a].compareTo(puzzle.bank[b]));
    }
    notifyListeners();
  }

  void restart() {
    _filled.clear();
    _hinted.clear();
    _undoStack.clear();
    _mistakes = 0;
    _hintsUsed = 0;
    _elapsed = Duration.zero;
    _status = GameStatus.playing;
    _selectedTile = null;
    _selectedCell = null;
    _errorCell = null;
    _saveable();
  }

  /// Extra life (after a rewarded ad): back to one mistake below the limit.
  bool continueAfterLoss() {
    final max = config.mistakesAllowed;
    if (_status != GameStatus.lost || max == null) return false;
    _mistakes = max - 1;
    _status = GameStatus.playing;
    _errorCell = null;
    _saveable();
    return true;
  }

  void pause() {
    if (_status != GameStatus.playing) return;
    _status = GameStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (_status != GameStatus.paused) return;
    _status = GameStatus.playing;
    notifyListeners();
  }

  /// Advances the clock; only counts while playing.
  void tick(Duration delta) {
    if (_status != GameStatus.playing) return;
    _elapsed += delta;
    notifyListeners();
  }

  void _saveable() {
    _revision++;
    notifyListeners();
  }

  // --- Saving an unfinished game -------------------------------------------

  /// Unfinished-game state for local saving (see [restore]).
  Map<String, Object?> snapshot() => {
    'filled': [
      for (final e in _filled.entries)
        [e.key.row, e.key.col, e.value, if (_hinted.contains(e.key)) 1],
    ],
    'mistakes': _mistakes,
    'hints': _hintsUsed,
    'elapsedMs': _elapsed.inMilliseconds,
  };

  /// Restores a [snapshot]. Returns false and changes nothing if it doesn't
  /// fit this puzzle (e.g. after a generator change) or the level was over.
  bool restore(Map<String, Object?> json) {
    try {
      final filled = <Pos, int>{};
      final hinted = <Pos>{};
      for (final raw
          in (json['filled']! as List<Object?>).cast<List<Object?>>()) {
        final pos = Pos(raw[0]! as int, raw[1]! as int);
        final tile = raw[2]! as int;
        if (!_blanks.contains(pos) ||
            tile < 0 ||
            tile >= puzzle.bank.length ||
            puzzle.bank[tile] != puzzle.solution[pos] ||
            filled.containsValue(tile)) {
          return false;
        }
        filled[pos] = tile;
        if (raw.length > 3) hinted.add(pos);
      }
      final mistakes = json['mistakes']! as int;
      if (isOutOfMistakes(config, mistakes) ||
          filled.length == _blanks.length) {
        return false;
      }
      _filled
        ..clear()
        ..addAll(filled);
      _hinted
        ..clear()
        ..addAll(hinted);
      _undoStack
        ..clear()
        ..addAll(filled.keys.where((p) => !hinted.contains(p)));
      _mistakes = mistakes;
      _hintsUsed = json['hints']! as int;
      _elapsed = Duration(milliseconds: json['elapsedMs']! as int);
      _status = GameStatus.playing;
      notifyListeners();
      return true;
    } on Object {
      return false;
    }
  }
}

/// `m:ss`, or `h:mm:ss` past an hour. Callers localize the digits.
String formatClock(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}
