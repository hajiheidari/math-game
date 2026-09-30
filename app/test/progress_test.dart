import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/progress_store.dart';
import 'package:numcross/game/game_controller.dart';
import 'package:numcross/game/game_screen.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

Future<ProgressStore> newStore([Map<String, Object> values = const {}]) async {
  mockStorage(values);
  return ProgressStore(await SharedPreferences.getInstance());
}

int rightTile(GameController g, Pos cell) => g.bankOrder.firstWhere(
  (i) => g.tileValue(i) == g.puzzle.solution[cell] && !g.isTileUsed(i),
);

int wrongTile(GameController g, Pos cell) => g.bankOrder.firstWhere(
  (i) => g.tileValue(i) != g.puzzle.solution[cell] && !g.isTileUsed(i),
);

void main() {
  group('ProgressStore', () {
    test('wins unlock the next level; replays keep the best stars', () async {
      final s = await newStore();
      expect(s.of('18+', Difficulty.hard).nextLevel, 1);
      await s.recordWin('18+', Difficulty.hard, 1, 2);
      await s.recordWin('18+', Difficulty.hard, 2, 3);
      var p = s.of('18+', Difficulty.hard);
      expect(p.nextLevel, 3);
      expect(p.totalStars, 5);

      await s.recordWin('18+', Difficulty.hard, 1, 1); // worse: ignored
      await s.recordWin('18+', Difficulty.hard, 1, 3); // better: kept
      await s.recordWin('18+', Difficulty.hard, 9, 3); // locked: ignored
      p = s.of('18+', Difficulty.hard);
      expect(p.stars, [3, 3]);
      expect(
        s.of('18+', Difficulty.easy).nextLevel,
        1,
        reason: 'separate per difficulty',
      );
      expect(
        s.of('13-15', Difficulty.hard).nextLevel,
        1,
        reason: 'separate per band',
      );
    });

    test('unfinished games are stored per slot and id', () async {
      final s = await newStore();
      final slot = ProgressStore.levelSlot('16-17', Difficulty.easy);
      final daily = ProgressStore.dailySlot('16-17', Difficulty.easy);
      await s.saveGame(slot, 4, {'mistakes': 1});
      await s.saveGame(daily, 20260930, {'mistakes': 2});
      expect(s.savedGame(slot, 4)?['mistakes'], 1);
      expect(s.savedGame(slot, 5), isNull);
      expect(s.savedId(slot), 4);
      expect(s.savedGame(daily, 20260930)?['mistakes'], 2);
      expect(
        s.savedGame(daily, 20261001),
        isNull,
        reason:
            'yesterday'
            's daily is gone',
      );
      await s.clearGame(slot);
      expect(s.savedGame(slot, 4), isNull);
      expect(s.savedGame(daily, 20260930), isNotNull);
    });

    test('corrupt data does not crash', () async {
      final s = await newStore({
        'progress/18+/easy': 'x9',
        'game/level/18+/easy': '{oops',
        'daily': '[not a map]',
      });
      expect(s.of('18+', Difficulty.easy).stars, [1, 1]);
      expect(
        s.savedGame(ProgressStore.levelSlot('18+', Difficulty.easy), 1),
        isNull,
      );
      expect(s.solvedDays(), isEmpty);
    });
  });

  group('Daily', () {
    test('solved difficulties are tracked per date', () async {
      final s = await newStore();
      final day = DateTime(2026, 9, 30);
      await s.recordDaily(day, Difficulty.hard);
      expect(s.isDailySolved(day, Difficulty.hard), isTrue);
      expect(s.isDailySolved(day, Difficulty.easy), isFalse);
      expect(s.isDailySolved(DateTime(2026, 10, 1), Difficulty.hard), isFalse);
      expect(ProgressStore.dateId(day), 20260930);
    });

    test('streak counts consecutive days, alive until today ends', () async {
      final s = await newStore();
      // Solved Sep 27, 28, 29 (not 30 yet), and an older 5-day run in August.
      for (var d = 27; d <= 29; d++) {
        await s.recordDaily(DateTime(2026, 9, d), Difficulty.easy);
      }
      for (var d = 1; d <= 5; d++) {
        await s.recordDaily(DateTime(2026, 8, d), Difficulty.medium);
      }
      expect(
        s.currentStreak(DateTime(2026, 9, 30)),
        3,
        reason: 'today not played yet',
      );
      await s.recordDaily(DateTime(2026, 9, 30), Difficulty.expert);
      expect(s.currentStreak(DateTime(2026, 9, 30)), 4);
      expect(s.currentStreak(DateTime(2026, 10, 2)), 0, reason: 'missed Oct 1');
      expect(s.bestStreak(), 5);
    });

    test('streak crosses month and DST boundaries', () async {
      final s = await newStore();
      for (final d in [
        DateTime(2026, 3, 28),
        DateTime(2026, 3, 29),
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 1),
      ]) {
        await s.recordDaily(d, Difficulty.easy);
      }
      expect(s.currentStreak(DateTime(2026, 4, 1)), 5);
    });
  });

  group('GameController snapshot', () {
    GameController game() => GameController(
      generateLevel(band16to17, Difficulty.medium, 3),
      band16to17[Difficulty.medium],
    );

    test('round trip restores tiles, hints, mistakes and time', () {
      final a = game();
      final [c1, c2, c3, ...] = a.puzzle.blanks;
      a.place(wrongTile(a, c1), c1);
      a.place(rightTile(a, c1), c1);
      a.place(rightTile(a, c2), c2);
      a.tapCell(c3);
      a.hint();
      a.tick(const Duration(seconds: 42));

      final b = game();
      expect(b.restore(a.snapshot()), isTrue);
      expect(b.isFilled(c1) && b.isFilled(c2) && b.isFilled(c3), isTrue);
      expect(b.isHinted(c3), isTrue);
      expect(b.mistakes, 1);
      expect(b.hintsUsed, 1);
      expect(b.elapsed, const Duration(seconds: 42));
      expect(b.undo(), isTrue);
      expect(b.isFilled(c2), isFalse, reason: 'undo order survives');
    });

    test('snapshot from another puzzle is rejected', () {
      final a = game();
      final c = a.puzzle.blanks.first;
      a.place(rightTile(a, c), c);
      final other = GameController(
        generateLevel(band16to17, Difficulty.medium, 4),
        band16to17[Difficulty.medium],
      );
      final snap = a.snapshot();
      // Either the cell isn't blank there or the value doesn't match.
      final ok = other.restore(snap);
      if (ok) {
        final cell = Pos(
          ((snap['filled']! as List).first as List)[0] as int,
          ((snap['filled']! as List).first as List)[1] as int,
        );
        expect(other.puzzle.solution[cell], a.puzzle.solution[cell]);
      }
      expect(other.restore({'filled': 'nonsense'}), isFalse);
    });

    test('revision changes on moves, not on clock ticks', () {
      final g = game();
      final r0 = g.revision;
      g.tick(const Duration(seconds: 1));
      expect(g.revision, r0);
      g.place(rightTile(g, g.puzzle.blanks.first), g.puzzle.blanks.first);
      expect(g.revision, greaterThan(r0));
    });
  });

  testWidgets('winning a level advances the menu; unfinished level resumes', (
    tester,
  ) async {
    usePhone(tester);
    mockStorage({'band': '13-15', 'language': 'en', 'coins': 100});
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('next-easy'))).data,
      'Level 1',
    );

    // Level 1: finish with hints.
    await tester.tap(find.byKey(const ValueKey('difficulty-easy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    for (
      var guard = 0;
      find.byKey(const ValueKey('result-primary')).evaluate().isEmpty;
      guard++
    ) {
      expect(guard, lessThan(60), reason: 'hints stopped working');
      await tester.tap(find.byKey(const ValueKey('hint')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }
    // "Next level" -> level 2; place one tile, then leave.
    await tester.tap(find.byKey(const ValueKey('result-primary')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Level 2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hint')));
    await tester.pump();
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('next-easy'))).data,
      'Level 2',
    );

    // Relaunch: level 2 comes back with the hinted tile.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('difficulty-easy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final screen = tester.state(find.byType(GameScreen));
    expect(screen, isNotNull);
    final p = generateLevel(band13to15, Difficulty.easy, 2);
    final firstBlank = p.blanks.first;
    expect(
      find.byKey(ValueKey('cell-${firstBlank.row}-${firstBlank.col}')),
      findsOneWidget,
    );
    final filledFace = tester
        .widgetList<Widget>(
          find.byKey(ValueKey('cell-${firstBlank.row}-${firstBlank.col}')),
        )
        .first;
    expect(
      filledFace.runtimeType.toString(),
      'CellFace',
      reason: 'hinted cell restored',
    );
    await tester.pumpWidget(const SizedBox());
  });
}
