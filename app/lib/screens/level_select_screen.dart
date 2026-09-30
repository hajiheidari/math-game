import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
import '../app/progress_store.dart';
import '../game/game_screen.dart';
import '../i18n/labels.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';

/// Levels of one difficulty: continue, or replay a completed level.
class LevelSelectScreen extends StatelessWidget {
  final BandConfig band;
  final Difficulty difficulty;

  const LevelSelectScreen({
    super.key,
    required this.band,
    required this.difficulty,
  });

  static void open(
    BuildContext context,
    ProgressStore progress,
    BandConfig band,
    Difficulty difficulty,
    int level,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          band: band,
          difficulty: difficulty,
          level: level,
          progress: progress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final store = AppScope.of(context).progress;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final p = store.of(band.id, difficulty);
        final next = p.nextLevel;
        return Scaffold(
          appBar: AppBar(title: Text(difficultyName(t, difficulty))),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: FilledButton.icon(
                      key: const ValueKey('continue'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () =>
                          open(context, store, band, difficulty, next),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        '${t.continuePlaying} · ${t.levelNumber(locale.n(next))}',
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      t.levelsCompleted(locale.n(p.completed)),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 76,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    // Completed levels plus the current one.
                    itemCount: next,
                    itemBuilder: (context, i) {
                      final level = i + 1;
                      return _LevelTile(
                        key: ValueKey('level-$level'),
                        label: locale.n(level),
                        stars: p.starsFor(level),
                        current: level == next,
                        onTap: () =>
                            open(context, store, band, difficulty, level),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LevelTile extends StatelessWidget {
  final String label;
  final int stars;
  final bool current;
  final VoidCallback onTap;

  const _LevelTile({
    super.key,
    required this.label,
    required this.stars,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Material(
      color: current ? s.primary : s.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: current ? s.onPrimary : s.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!current)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: i < stars ? const Color(0xFFF2B01E) : s.outline,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
