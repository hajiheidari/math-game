import 'package:flutter/material.dart';

import '../game/game_controller.dart' show formatClock;
import '../i18n/dates.dart';
import '../i18n/labels.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import 'challenge.dart';

/// "You got a challenge!": the friend's puzzle and time. True = start.
Future<bool?> showChallengeDialog(BuildContext context, Challenge c) =>
    showDialog<bool>(
      context: context,
      builder: (context) {
        final t = AppLocalizations.of(context);
        final locale = LocaleScope.of(context);
        final text = Theme.of(context).textTheme;
        final scheme = Theme.of(context).colorScheme;
        final puzzle = [
          if (c.isDaily) ...[
            t.menuDaily,
            formatLongDate(locale, c.date!),
          ] else
            t.levelNumber(locale.n(c.level)),
          difficultyName(t, c.difficulty),
        ].join(' · ');
        final time = locale.n(formatClock(c.time));
        return AlertDialog(
          key: const ValueKey('challenge-dialog'),
          icon: Icon(Icons.sports_score, size: 44, color: scheme.primary),
          title: Text(t.challengeReceived, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(puzzle, textAlign: TextAlign.center, style: text.titleSmall),
              const SizedBox(height: 12),
              Text(
                time,
                style: text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(t.challengeBody(time), textAlign: TextAlign.center),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.later),
            ),
            FilledButton.icon(
              key: const ValueKey('challenge-start'),
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.play_arrow),
              label: Text(t.challengeStart),
            ),
          ],
        );
      },
    );
