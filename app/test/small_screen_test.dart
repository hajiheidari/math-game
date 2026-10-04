import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/game/game_screen.dart';
import 'package:numcross_engine/numcross_engine.dart';

import 'helpers.dart';

/// The smallest common phone (320 x 640 dp, also the CI emulator): every
/// main screen in every language must lay out without overflow.
void useSmallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> open(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  // The list may be scrolled either way from an earlier visit.
  for (final delta in [200.0, -200.0]) {
    if (f.evaluate().isNotEmpty) break;
    try {
      await tester.scrollUntilVisible(
        f,
        delta,
        scrollable: find.byType(Scrollable).first,
      );
    } catch (_) {}
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Android back button.
Future<void> back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// Solves the puzzle on screen by tapping the right tiles.
Future<void> solveOnScreen(WidgetTester tester) async {
  final g = tester.widget<GameScreen>(find.byType(GameScreen));
  final p = g.isDaily
      ? generateDaily(g.band, g.difficulty, g.date!)
      : generateLevel(g.band, g.difficulty, g.level);
  for (final cell in p.blanks) {
    final i = [
      for (var i = 0; i < p.bank.length; i++)
        if (p.bank[i] == p.solution[cell] &&
            find.byKey(ValueKey('tile-$i')).evaluate().isNotEmpty)
          i,
    ].first;
    await tester.tap(find.byKey(ValueKey('tile-$i')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('cell-${cell.row}-${cell.col}')));
    await tester.pump();
  }
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  for (final lang in ['en', 'fa', 'ar', 'ur']) {
    testWidgets('age gate fits a small phone ($lang)', (tester) async {
      useSmallPhone(tester);
      mockStorage({'language': lang});
      await tester.pumpWidget(await launchApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('tutorial fits a small phone ($lang)', (tester) async {
      useSmallPhone(tester);
      mockStorage({'band': '13-15', 'language': lang}, false);
      await tester.pumpWidget(await launchApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tile-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-0-2')));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('menu, levels, game, settings, calendar fit ($lang)', (
      tester,
    ) async {
      useSmallPhone(tester);
      mockStorage({'band': '18+', 'language': lang});
      await tester.pumpWidget(await launchApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'menu');

      await open(tester, 'difficulty-expert');
      expect(tester.takeException(), isNull, reason: 'level select');
      await tester.tap(find.byKey(const ValueKey('continue')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: 'game');
      await back(tester);
      await back(tester);

      await open(tester, 'calendar');
      expect(tester.takeException(), isNull, reason: 'calendar');
      await back(tester);

      await tester.tap(find.byKey(const ValueKey('settings')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'settings');
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('daily win dialog with streak fits ($lang)', (tester) async {
      useSmallPhone(tester);
      mockStorage({'band': '18+', 'language': lang});
      await tester.pumpWidget(await launchApp());
      await tester.pumpAndSettle();
      await open(tester, 'daily-easy');
      await solveOnScreen(tester);
      expect(find.byKey(const ValueKey('result-streak')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
