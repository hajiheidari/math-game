import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
import '../app/feedback.dart';
import '../app/palette.dart';
import '../app/progress_store.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../monetization/monetization.dart';
import '../rewards/friend_hints_ui.dart';
import '../share/share_result.dart';
import 'game_controller.dart';
import 'game_widgets.dart';

/// One playable puzzle: a numbered level, or the daily puzzle of [date].
class GameScreen extends StatefulWidget {
  final BandConfig band;
  final Difficulty difficulty;

  /// Level number (Levels mode); 0 for a daily puzzle.
  final int level;

  /// Set for the Daily Puzzle (local calendar date).
  final DateTime? date;

  /// Where wins and unfinished games are saved. Null = nothing is saved.
  final ProgressStore? progress;

  const GameScreen({
    super.key,
    required this.band,
    required this.difficulty,
    required this.level,
    this.progress,
  }) : date = null;

  const GameScreen.daily({
    super.key,
    required this.band,
    required this.difficulty,
    required DateTime this.date,
    this.progress,
  }) : level = 0;

  bool get isDaily => date != null;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final GameController _game;
  Timer? _clock;
  Timer? _errorFlash;
  bool _resultShown = false;
  int _savedRevision = 0;
  bool _extraLifeUsed = false;

  /// Null when the screen runs without the app shell (tests): hints are free.
  Monetization? get _money => AppScope.maybeOf(context)?.monetization;

  GameFeedback? get _feedback => AppScope.maybeOf(context)?.feedback;

  // Last seen counts, to turn state changes into sound/vibration events.
  int _lastMistakes = 0;
  int _lastRemaining = 0;

  @override
  void initState() {
    super.initState();
    final puzzle = widget.isDaily
        ? generateDaily(widget.band, widget.difficulty, widget.date!)
        : generateLevel(widget.band, widget.difficulty, widget.level);
    _game = GameController(puzzle, widget.band[widget.difficulty]);
    final saved = widget.progress?.savedGame(_slot, _id);
    if (saved != null) _game.restore(saved);
    _savedRevision = _game.revision;
    _lastMistakes = _game.mistakes;
    _lastRemaining = _game.remainingBlanks;
    _game.addListener(_onGameChanged);
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _game.tick(const Duration(seconds: 1)),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _errorFlash?.cancel();
    _saveUnfinished();
    _game.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Never let the clock run while the app is in the background.
    if (state != AppLifecycleState.resumed) {
      _game.pause();
      _saveUnfinished();
    }
  }

  String get _slot => widget.isDaily
      ? ProgressStore.dailySlot(widget.band.id, widget.difficulty)
      : ProgressStore.levelSlot(widget.band.id, widget.difficulty);

  /// Level number, or yyyymmdd for a daily puzzle.
  int get _id =>
      widget.isDaily ? ProgressStore.dateId(widget.date!) : widget.level;

  /// Saves the level so it can be resumed later (only while it is not over).
  void _saveUnfinished() {
    final s = _game.status;
    if (s != GameStatus.playing && s != GameStatus.paused) return;
    _savedRevision = _game.revision;
    widget.progress?.saveGame(_slot, _id, _game.snapshot());
  }

  void _onGameChanged() {
    _playFeedback();
    if (_game.errorCell != null) {
      _errorFlash?.cancel();
      _errorFlash = Timer(const Duration(milliseconds: 700), _game.clearError);
    }
    final over =
        _game.status == GameStatus.won || _game.status == GameStatus.lost;
    if (!over && _game.revision != _savedRevision) _saveUnfinished();
    if (over && !_resultShown) {
      _resultShown = true;
      _recordResult();
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
    } else if (!over) {
      _resultShown = false;
    }
  }

  void _playFeedback() {
    final fb = mounted ? _feedback : null;
    if (_game.status == GameStatus.won && _lastRemaining > 0) {
      fb?.win();
    } else if (_game.mistakes > _lastMistakes) {
      fb?.wrong();
    } else if (_game.remainingBlanks < _lastRemaining) {
      fb?.correct();
    }
    _lastMistakes = _game.mistakes;
    _lastRemaining = _game.remainingBlanks;
  }

  void _recordResult() {
    final won = _game.status == GameStatus.won;
    // Wins earn no hints (friends do, see FriendHints); this only paces
    // interstitials in the Bazaar build.
    if (won && !widget.isDaily) _money?.onLevelWon();
    final progress = widget.progress;
    if (progress == null) return;
    final band = widget.band.id, d = widget.difficulty;
    progress.clearGame(_slot);
    if (!won) return;
    if (widget.isDaily) {
      progress.recordDaily(widget.date!, d);
    } else {
      progress.recordWin(band, d, widget.level, _game.stars);
    }
  }

  /// Hint: free without the app shell; otherwise one from the bank. Out of
  /// hints: collect any friends have earned, else explain how to get some.
  Future<void> _onHint() async {
    final app = AppScope.maybeOf(context);
    if (app == null) {
      _game.hint();
      return;
    }
    final money = app.monetization;
    if (money.coins <= 0) await app.hints.claim(force: true);
    if (!mounted) return;
    if (money.coins > 0) {
      if (_game.hint()) await money.spendCoin();
      return;
    }
    _game.pause();
    await showFriendHintsDialog(
      context,
      theme: Palette.calm(Theme.of(context)),
    );
    if (mounted) _game.resume();
  }

  Future<void> _showResult() async {
    if (!mounted) return;
    final action = await showDialog<_ResultAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Theme(
        data: Palette.calm(Theme.of(dialogContext)),
        child: _ResultDialog(
          game: _game,
          isDaily: widget.isDaily,
          canBuyExtraLife:
              !_extraLifeUsed && (_money?.ads.rewardedReady ?? false),
          streak: widget.isDaily
              ? widget.progress?.currentStreak(widget.date!)
              : null,
          difficulty: widget.difficulty,
          level: widget.level,
          date: widget.date,
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _ResultAction.next:
        // Between levels only, paced by the brief's rules.
        await _money?.maybeShowInterstitial();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameScreen(
              band: widget.band,
              difficulty: widget.difficulty,
              level: widget.level + 1,
              progress: widget.progress,
            ),
          ),
        );
      case _ResultAction.retry:
        _game.restart();
      case _ResultAction.extraLife:
        final earned = await _money?.ads.showRewarded() ?? false;
        if (!mounted) return;
        if (earned) {
          _extraLifeUsed = true;
          _game.continueAfterLoss();
        } else {
          _resultShown = false;
          _onGameChanged(); // show the result again
        }
      case _ResultAction.menu || null:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final money = _money;
    // Calm navy/blue inside the puzzle (the menu is warm).
    return Theme(
      data: Palette.calm(Theme.of(context)),
      child: ListenableBuilder(
        listenable: Listenable.merge([_game, ?money]),
        builder: (context, _) {
          final paused = _game.status == GameStatus.paused;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.isDaily
                    ? t.menuDaily
                    : t.levelNumber(locale.n(widget.level)),
              ),
              actions: [
                if (_game.config.showTimer)
                  Center(
                    child: Text(
                      locale.n(formatClock(_game.elapsed)),
                      key: const ValueKey('clock'),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                IconButton(
                  key: const ValueKey('pause'),
                  tooltip: paused ? t.resume : t.pause,
                  icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                  onPressed: paused ? _game.resume : _game.pause,
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _Toolbar(game: _game, onHint: _onHint, coins: _money?.coins),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Center(
                        child: paused
                            ? _PausedPanel(onResume: _game.resume)
                            : GameBoard(game: _game),
                      ),
                    ),
                  ),
                  if (!paused) TileBank(game: _game, onPick: _feedback?.tap),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final GameController game;
  final VoidCallback onHint;

  /// Coin balance to show on the hint button (null = no coins system).
  final int? coins;

  const _Toolbar({required this.game, required this.onHint, this.coins});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final max = game.config.mistakesAllowed;
    final playing = game.status == GameStatus.playing;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              max == null
                  ? '${t.mistakesLabel}: ${locale.n(game.mistakes)}'
                  : t.mistakesCounter(locale.n(game.mistakes), locale.n(max)),
              key: const ValueKey('mistakes'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: game.mistakes > 0
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('undo'),
            tooltip: t.undo,
            icon: const Icon(Icons.undo),
            onPressed: game.canUndo ? game.undo : null,
          ),
          IconButton(
            key: const ValueKey('restart'),
            tooltip: t.restart,
            icon: const Icon(Icons.restart_alt),
            onPressed: playing ? game.restart : null,
          ),
          IconButton(
            key: const ValueKey('hint'),
            tooltip: t.hint,
            icon: coins == null
                ? const Icon(Icons.lightbulb_outline)
                : Badge(
                    key: const ValueKey('coins'),
                    label: Text(LocaleScope.of(context).n(coins!)),
                    child: const Icon(Icons.lightbulb_outline),
                  ),
            onPressed: playing ? onHint : null,
          ),
        ],
      ),
    );
  }
}

class _PausedPanel extends StatelessWidget {
  final VoidCallback onResume;
  const _PausedPanel({required this.onResume});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(t.paused, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onResume,
          icon: const Icon(Icons.play_arrow),
          label: Text(t.resume),
        ),
      ],
    );
  }
}

enum _ResultAction { next, retry, menu, extraLife }

class _ResultDialog extends StatelessWidget {
  final GameController game;
  final bool isDaily;

  /// Daily streak after this result (daily wins only).
  final int? streak;

  /// Offer "watch an ad for one more mistake" (lost levels only).
  final bool canBuyExtraLife;

  /// What a win shares (see [ResultShare]).
  final Difficulty difficulty;
  final int level;
  final DateTime? date;

  const _ResultDialog({
    required this.game,
    this.isDaily = false,
    this.streak,
    this.canBuyExtraLife = false,
    required this.difficulty,
    required this.level,
    this.date,
  });

  ResultShare get _share => ResultShare(
    isDaily: isDaily,
    date: date,
    level: level,
    difficulty: difficulty,
    stars: game.stars,
    elapsed: game.elapsed,
    mistakes: game.mistakes,
    streak: streak,
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final won = game.status == GameStatus.won;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget stat(IconData icon, String label, String value, String key) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(height: 2),
                Text(
                  value,
                  key: ValueKey(key),
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  label,
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      title: Text(
        won ? (isDaily ? t.dailyComplete : t.levelComplete) : t.outOfMistakes,
        textAlign: TextAlign.center,
        style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (won)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    // Stars pop in one after another.
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: MediaQuery.of(context).disableAnimations
                          ? Duration.zero
                          : Duration(milliseconds: 350 + i * 180),
                      curve: Interval(i * 0.25, 1, curve: Curves.easeOutBack),
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Icon(
                        i < game.stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 48,
                        color: i < game.stars ? Palette.star : scheme.outline,
                      ),
                    ),
                ],
              ),
            if (won && streak != null && streak! > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Palette.flame,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  // Flexible: wraps instead of overflowing on small phones.
                  Flexible(
                    child: Text(
                      t.streakDays(streak!, locale.n(streak!)),
                      key: const ValueKey('result-streak'),
                      textAlign: TextAlign.center,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!won && canBuyExtraLife) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const ValueKey('extra-life'),
                onPressed: () =>
                    Navigator.pop(context, _ResultAction.extraLife),
                icon: const Icon(Icons.play_circle_outline),
                label: Text(t.extraLife, textAlign: TextAlign.center),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                stat(
                  Icons.timer_outlined,
                  t.time,
                  locale.n(formatClock(game.elapsed)),
                  'result-time',
                ),
                const SizedBox(width: 10),
                stat(
                  Icons.close_rounded,
                  t.mistakesLabel,
                  locale.n(game.mistakes),
                  'result-mistakes',
                ),
              ],
            ),
            if (won) ...[
              const SizedBox(height: 14),
              // A fun line that invites the player to share the win: dark
              // text on a soft sun banner, apart from the rest.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Palette.sun.withValues(alpha: dark ? 0.22 : 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _share.cheer(locale.language.code),
                  key: const ValueKey('result-cheer'),
                  textAlign: TextAlign.center,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamilyFallback: emojiFallback,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _ShareButton(result: _share),
              ),
              const SizedBox(height: 6),
              Text(
                t.shareForHints,
                key: const ValueKey('share-for-hints'),
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (won && isDaily)
          TextButton(
            key: const ValueKey('result-primary'),
            onPressed: () => Navigator.pop(context, _ResultAction.menu),
            child: Text(t.menu),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context, _ResultAction.menu),
            child: Text(t.menu),
          ),
          FilledButton(
            key: const ValueKey('result-primary'),
            onPressed: () => Navigator.pop(
              context,
              won ? _ResultAction.next : _ResultAction.retry,
            ),
            child: Text(won ? t.nextLevel : t.tryAgain),
          ),
        ],
      ],
    );
  }
}

/// "Show your friends": opens the share sheet; says "Copied" when the text
/// went to the clipboard instead (web without a share sheet).
class _ShareButton extends StatefulWidget {
  final ResultShare result;
  const _ShareButton({required this.result});

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  bool _busy = false;
  bool _copied = false;

  Future<void> _share() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    final outcome = await shareResult(context, widget.result, origin: origin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _copied = outcome == ShareOutcome.copied;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // The one warm spot in the puzzle: sharing is what we want players to do.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Palette.hero,
        borderRadius: BorderRadius.circular(28),
      ),
      child: FilledButton.icon(
        key: const ValueKey('share-result'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: _busy ? null : _share,
        icon: Icon(_copied ? Icons.check : Icons.ios_share_rounded),
        label: Text(
          _copied ? t.shareCopied : t.shareResult,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
