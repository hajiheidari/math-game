import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
import '../game/game_controller.dart';
import '../game/game_widgets.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';

/// Tutorial rules: no mistake limit, no timer.
const _tutorialConfig = DifficultyConfig(
  difficulty: Difficulty.easy,
  numbers: NumberRules(
    minValue: 1,
    maxValue: 20,
    opWeights: {Op.add: 1},
    maxFactor: 12,
  ),
  layout: LayoutRules(minEquations: 1, maxEquations: 2, maxRows: 5, maxCols: 5),
  blankRatio: 0.5,
  decoys: 1,
  mistakesAllowed: null,
  showTimer: false,
  parTimeSeconds: 60,
);

/// Step 1: `3 + ? = 7` with tiles 5 and 4.
Puzzle _stepOne() => Puzzle(
  bandId: 'tutorial',
  difficulty: Difficulty.easy,
  seed: 0,
  rows: 1,
  cols: 5,
  slots: [EquationSlot(Pos(0, 0), Direction.across, Op.add)],
  solution: {Pos(0, 0): 3, Pos(0, 2): 4, Pos(0, 4): 7},
  blanks: [Pos(0, 2)],
  bank: [5, 4],
  decoyCount: 1,
);

/// Step 2: `2 + ? = 6` across, crossing `? × 3 = ?` down.
Puzzle _stepTwo() => Puzzle(
  bandId: 'tutorial',
  difficulty: Difficulty.easy,
  seed: 0,
  rows: 5,
  cols: 5,
  slots: [
    EquationSlot(Pos(0, 0), Direction.across, Op.add),
    EquationSlot(Pos(0, 2), Direction.down, Op.mul),
  ],
  solution: {
    Pos(0, 0): 2,
    Pos(0, 2): 4,
    Pos(0, 4): 6,
    Pos(2, 2): 3,
    Pos(4, 2): 12,
  },
  blanks: [Pos(0, 2), Pos(4, 2)],
  bank: [12, 8, 4],
  decoyCount: 1,
);

/// Short interactive "how to play". Shown before the first game and from
/// Settings. Completing or skipping it marks it done.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _step = 0; // 0, 1 = puzzles; 2 = done panel
  late GameController _game;
  Timer? _advance;
  Timer? _errorFlash;

  @override
  void initState() {
    super.initState();
    _game = _controllerFor(_stepOne());
  }

  GameController _controllerFor(Puzzle p) =>
      GameController(p, _tutorialConfig)..addListener(_onChanged);

  void _onChanged() {
    final fb = AppScope.maybeOf(context)?.feedback;
    if (_game.errorCell != null) {
      fb?.wrong();
      _errorFlash?.cancel();
      _errorFlash = Timer(const Duration(milliseconds: 700), _game.clearError);
    }
    if (_game.status == GameStatus.won && _advance == null) {
      fb?.correct();
      _advance = Timer(const Duration(milliseconds: 700), _next);
    }
    setState(() {});
  }

  void _next() {
    _advance = null;
    _errorFlash?.cancel();
    setState(() {
      _step++;
      if (_step == 1) {
        _game.dispose();
        _game = _controllerFor(_stepTwo());
      }
    });
  }

  void _finish() {
    AppScope.maybeOf(context)?.prefs.setTutorialDone();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _advance?.cancel();
    _errorFlash?.cancel();
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    if (_step >= 2) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.tutorialTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    t.tutorialDone,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(t.tutorialDoneBody, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  FilledButton(
                    key: const ValueKey('tutorial-finish'),
                    onPressed: _finish,
                    child: Text(t.startPlaying),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final instruction = _game.errorCell != null
        ? t.tutorialWrong
        : _step == 0
        ? t.tutorialStep1
        : t.tutorialStep2;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.tutorialTitle),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            key: const ValueKey('tutorial-skip'),
            onPressed: _finish,
            child: Text(t.skip),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: _game.errorCell != null
                    ? scheme.errorContainer
                    : scheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        LocaleScope.of(context).n('${_step + 1}/2'),
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          instruction,
                          key: const ValueKey('tutorial-text'),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Center(child: GameBoard(game: _game)),
              ),
            ),
            TileBank(
              game: _game,
              onPick: AppScope.maybeOf(context)?.feedback.tap,
            ),
          ],
        ),
      ),
    );
  }
}
