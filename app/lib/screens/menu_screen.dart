import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
import '../app/palette.dart';
import '../game/game_screen.dart';
import '../i18n/dates.dart';
import '../i18n/labels.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../rewards/friend_hints_ui.dart';
import 'calendar_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

/// Home: pick a difficulty in the player's band and play.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  Timer? _startAds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onboard();
      _collectHints();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _collectHints();
  }

  /// Hints friends earned for the player since last time (FriendHints).
  Future<void> _collectHints() async {
    if (!mounted) return;
    final n = await AppScope.of(context).hints.claim();
    if (n == 0 || !mounted) return;
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.friendHintsReceived(LocaleScope.of(context).n(n))),
      ),
    );
  }

  /// First visit: the short tutorial. Then consent, ATT prompt and ads —
  /// after onboarding, never on the very first frame.
  Future<void> _onboard() async {
    if (!mounted) return;
    final app = AppScope.of(context);
    if (!app.prefs.tutorialDone) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const TutorialScreen()));
    }
    if (!mounted) return;
    _startAds = Timer(const Duration(seconds: 1), () {
      if (mounted) app.monetization.start(app.band);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _startAds?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final band = AppScope.of(context).band;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.appTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('settings'),
            tooltip: t.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      // One screen, no scrolling on phones (Amir, 2026-10-11); scrolls only
      // when the screen is too short (small phones, large text).
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppScope.of(context).progress,
          builder: (context, _) => LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 20),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DailyCard(band: band),
                      const SizedBox(height: 12),
                      const FriendHintsCard(),
                      const SizedBox(height: 16),
                      Text(
                        t.menuLevels,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      // The tiles take the rest of the screen (no scrolling), up to
                      // a size that still looks full on big phones and tablets.
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 540),
                            child: _LevelsGrid(band: band),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Today's puzzle in each difficulty (2 x 2 buttons), the streak and a
/// calendar link, on the warm hero gradient.
class _DailyCard extends StatelessWidget {
  final BandConfig band;
  const _DailyCard({required this.band});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final store = app.progress;
    final today = app.today;
    final streak = store.currentStreak(today);
    final textTheme = Theme.of(context).textTheme;
    const onHero = Colors.white;

    Widget button(Difficulty d) => _DailyButton(
      band: band,
      difficulty: d,
      solved: store.isDailySolved(today, d),
    );

    return DecoratedBox(
      key: const ValueKey('daily-card'),
      decoration: BoxDecoration(
        gradient: Palette.hero,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Palette.coral.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 10, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.menuDaily,
                        style: textTheme.titleLarge?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        formatLongDate(locale, today),
                        key: const ValueKey('daily-date'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: onHero.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: onHero,
                        size: 20,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        locale.n(streak),
                        key: const ValueKey('daily-streak'),
                        style: textTheme.titleMedium?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('calendar'),
                  tooltip: t.calendar,
                  color: onHero,
                  icon: const Icon(Icons.calendar_month_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: button(Difficulty.easy)),
                      const SizedBox(width: 10),
                      Expanded(child: button(Difficulty.medium)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: button(Difficulty.hard)),
                      const SizedBox(width: 10),
                      Expanded(child: button(Difficulty.expert)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A white button on the hero card: the difficulty's color, its meter and
/// name. Solved puzzles stay closed (with a check) until tomorrow's.
class _DailyButton extends StatelessWidget {
  final BandConfig band;
  final Difficulty difficulty;
  final bool solved;
  const _DailyButton({
    required this.band,
    required this.difficulty,
    required this.solved,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final color = Palette.difficulty(difficulty);
    return Material(
      key: ValueKey('daily-${difficulty.name}'),
      color: Colors.white.withValues(alpha: solved ? 0.35 : 1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: solved
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen.daily(
                    band: band,
                    difficulty: difficulty,
                    date: app.today,
                    progress: app.progress,
                  ),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              solved
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 22,
                    )
                  : _DifficultyMeter(level: difficulty.index + 1, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  difficultyName(t, difficulty),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: solved ? Colors.white : Palette.ink,
                  ),
                ),
              ),
              if (!solved)
                Icon(Icons.play_arrow_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// The four difficulties of Levels mode, two per row.
class _LevelsGrid extends StatelessWidget {
  final BandConfig band;
  const _LevelsGrid({required this.band});

  @override
  Widget build(BuildContext context) {
    Widget row(Difficulty a, Difficulty b) => Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _DifficultyCard(band: band, difficulty: a),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DifficultyCard(band: band, difficulty: b),
          ),
        ],
      ),
    );
    return Column(
      children: [
        row(Difficulty.easy, Difficulty.medium),
        const SizedBox(height: 12),
        row(Difficulty.hard, Difficulty.expert),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final BandConfig band;
  final Difficulty difficulty;
  const _DifficultyCard({required this.band, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final cfg = band[difficulty];
    final textTheme = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = Palette.difficulty(difficulty);
    final store = AppScope.of(context).progress;
    final progress = store.of(band.id, difficulty);
    return Material(
      key: ValueKey('difficulty-${difficulty.name}'),
      color: color.withValues(alpha: dark ? 0.22 : 0.13),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LevelSelectScreen(band: band, difficulty: difficulty),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _DifficultyMeter(
                        level: difficulty.index + 1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Operators are language-neutral symbols; keep them LTR.
                    // They shrink on very narrow phones.
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              cfg.numbers.opWeights.keys
                                  .map((o) => o.symbol)
                                  .join(''),
                              style: textTheme.labelLarge?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  difficultyName(t, difficulty),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  t.equationsRange(
                    locale.n(cfg.layout.minEquations),
                    locale.n(cfg.layout.maxEquations),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        t.levelNumber(locale.n(progress.nextLevel)),
                        key: ValueKey('next-${difficulty.name}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.star_rounded,
                      size: 17,
                      color: Palette.star,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      locale.n(progress.totalStars),
                      style: textTheme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Four small bars, [level] of them filled.
class _DifficultyMeter extends StatelessWidget {
  final int level;
  final Color color;
  const _DifficultyMeter({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 5,
            height: 10.0 + i * 5,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: i < level ? color : color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
