import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
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
        title: Text(t.appTitle),
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
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppScope.of(context).progress,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DailyCard(band: band),
              const SizedBox(height: 16),
              const FriendHintsCard(),
              const SizedBox(height: 24),
              Text(
                t.menuLevels,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                t.chooseDifficulty,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final d in Difficulty.values) ...[
                _DifficultyCard(band: band, difficulty: d),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Today's puzzle in each difficulty, the streak and a calendar link.
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      key: const ValueKey('daily-card'),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.menuDaily, style: textTheme.titleLarge),
                      Text(
                        formatLongDate(locale, today),
                        key: const ValueKey('daily-date'),
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFE8672A),
                ),
                const SizedBox(width: 2),
                Text(
                  locale.n(streak),
                  key: const ValueKey('daily-streak'),
                  style: textTheme.titleMedium,
                ),
                IconButton(
                  key: const ValueKey('calendar'),
                  tooltip: t.calendar,
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in Difficulty.values)
                  _dailyButton(context, d, store.isDailySolved(today, d)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyButton(BuildContext context, Difficulty d, bool solved) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return FilledButton.tonalIcon(
      key: ValueKey('daily-${d.name}'),
      // Solved puzzles stay closed until tomorrow's.
      onPressed: solved
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen.daily(
                  band: band,
                  difficulty: d,
                  date: app.today,
                  progress: app.progress,
                ),
              ),
            ),
      icon: Icon(solved ? Icons.check_circle : Icons.play_arrow, size: 18),
      label: Text(difficultyName(t, d)),
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
    final scheme = Theme.of(context).colorScheme;
    final store = AppScope.of(context).progress;
    final progress = store.of(band.id, difficulty);
    return Card(
      key: ValueKey('difficulty-${difficulty.name}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LevelSelectScreen(band: band, difficulty: difficulty),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _DifficultyMeter(
                level: difficulty.index + 1,
                color: scheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficultyName(t, difficulty),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.equationsRange(
                        locale.n(cfg.layout.minEquations),
                        locale.n(cfg.layout.maxEquations),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          t.levelNumber(locale.n(progress.nextLevel)),
                          key: ValueKey('next-${difficulty.name}'),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF2B01E),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              locale.n(progress.totalStars),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Operators are language-neutral symbols; keep them LTR.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  cfg.numbers.opWeights.keys.map((o) => o.symbol).join(' '),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: scheme.primary),
                ),
              ),
            ],
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
