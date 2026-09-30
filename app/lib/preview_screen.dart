import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import 'game/board_view.dart';
import 'game/game_screen.dart';
import 'i18n/digits.dart';
import 'i18n/labels.dart';
import 'i18n/languages.dart';
import 'i18n/locale_controller.dart';
import 'l10n/app_localizations.dart';

/// Step-1 design preview: browse generated puzzles in every language.
/// Replaced by the real menu and game screen in later steps.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  BandConfig _band = band13to15;
  Difficulty _difficulty = Difficulty.easy;
  int _level = 1;
  bool _showSolution = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final puzzle = generateLevel(_band, _difficulty, _level);
    final cfg = _band[_difficulty];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('play'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                GameScreen(band: _band, difficulty: _difficulty, level: _level),
          ),
        ),
        icon: const Icon(Icons.play_arrow),
        label: Text(t.play),
      ),
      appBar: AppBar(
        title: Text(t.previewTitle),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<AppLanguage>(
              value: locale.language,
              icon: const Icon(Icons.translate),
              onChanged: (l) => locale.language = l!,
              items: [
                for (final l in kLanguages)
                  DropdownMenuItem(value: l, child: Text(l.nativeName)),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${t.ageGroup}:'),
                for (final b in kBands)
                  ChoiceChip(
                    label: Text(bandLabel(t, locale, b)),
                    selected: b == _band,
                    onSelected: (_) => setState(() => _band = b),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in Difficulty.values)
                  ChoiceChip(
                    label: Text(difficultyName(t, d)),
                    selected: d == _difficulty,
                    onSelected: (_) => setState(() => _difficulty = d),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _level > 1 ? () => setState(() => _level--) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  t.levelNumber(locale.n(_level)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () => setState(() => _level++),
                  icon: const Icon(Icons.chevron_right),
                ),
                const Spacer(),
                Flexible(
                  flex: 100,
                  child: Text(
                    t.mistakesCounter(
                      locale.n(0),
                      locale.n(cfg.mistakesAllowed ?? '∞'),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: BoardView(puzzle: puzzle, showSolution: _showSolution),
            ),
            const SizedBox(height: 16),
            Text(t.tiles, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            // Tiles are separate items, so they may flow RTL; each number
            // stays a left-to-right digit run.
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in puzzle.bank)
                  Chip(
                    label: Text(
                      locale.n(v),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.showSolution),
              value: _showSolution,
              onChanged: (v) => setState(() => _showSolution = v),
            ),
            Text(t.digits, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (mode, label) in [
                  (DigitMode.auto, t.digitsAuto),
                  (DigitMode.western, t.digitsWestern),
                  (DigitMode.native, t.digitsNative),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: locale.digitMode == mode,
                    onSelected: (_) => locale.digitMode = mode,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(t.streakDays(7, locale.n(7))),
            Text(t.ageGateBlocked(locale.n(kMinimumAge))),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
