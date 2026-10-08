import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/game/game_screen.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';
import 'package:numcross/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:numcross_engine/numcross_engine.dart';

const band = band13to15;
const difficulty = Difficulty.medium;
const level = 2;

Widget host(String lang) {
  final language = languageFor(Locale(lang));
  return LocaleScope(
    controller: LocaleController(initial: language),
    child: MaterialApp(
      locale: language.locale,
      supportedLocales: [for (final l in kLanguages) l.locale],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const GameScreen(band: band, difficulty: difficulty, level: level),
    ),
  );
}

Future<void> setPhone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Bank index of the tile whose value matches [cell], or doesn't.
int tileFor(Puzzle p, Pos cell, {bool right = true}) {
  for (var i = 0; i < p.bank.length; i++) {
    if ((p.bank[i] == p.solution[cell]) == right) return i;
  }
  throw StateError('no tile');
}

Finder cellFinder(Pos p) => find.byKey(ValueKey('cell-${p.row}-${p.col}'));
Finder tileFinder(int i) => find.byKey(ValueKey('tile-$i'));

void main() {
  final puzzle = generateLevel(band, difficulty, level);

  for (final lang in ['en', 'fa', 'ar', 'ur']) {
    testWidgets('solves by tapping and shows the result ($lang)', (
      tester,
    ) async {
      await setPhone(tester);
      await tester.pumpWidget(host(lang));
      await tester.pump();
      expect(tester.takeException(), isNull);

      for (final cell in puzzle.blanks) {
        final i = tileFor(puzzle, cell);
        // Two tiles can share a value; tap whichever copy is still in the bank.
        final tile = tileFinder(i).evaluate().isNotEmpty
            ? tileFinder(i)
            : tileFinder(puzzle.bank.lastIndexOf(puzzle.solution[cell]!));
        await tester.tap(tile);
        await tester.pump();
        await tester.tap(cellFinder(cell));
        await tester.pump();
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('result-primary')), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      // A win invites the player to share it.
      expect(find.byKey(const ValueKey('result-cheer')), findsOneWidget);
      expect(find.byKey(const ValueKey('share-result')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('drag and drop a wrong tile counts a mistake', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(host('en'));
    await tester.pump();

    final cell = puzzle.blanks.first;
    final wrong = tileFor(puzzle, cell, right: false);
    final from = tester.getCenter(tileFinder(wrong));
    final to = tester.getCenter(cellFinder(cell));
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final mistakes = tester.widget<Text>(
      find.byKey(const ValueKey('mistakes')),
    );
    expect(mistakes.data, contains('1/'));
    expect(
      tileFinder(wrong),
      findsOneWidget,
      reason: 'wrong tile returns to the bank',
    );

    // Right tile by drag.
    final right = tileFor(puzzle, cell);
    final g2 = await tester.startGesture(tester.getCenter(tileFinder(right)));
    await tester.pump(const Duration(milliseconds: 50));
    await g2.moveTo(tester.getCenter(cellFinder(cell)));
    await tester.pump();
    await g2.up();
    await tester.pump();
    expect(tileFinder(right), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pause hides the board and stops the clock', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(host('en'));
    await tester.pump(const Duration(seconds: 3));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('clock'))).data,
      '0:03',
    );

    await tester.tap(find.byKey(const ValueKey('pause')));
    await tester.pump(const Duration(seconds: 5));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('clock'))).data,
      '0:03',
    );
    expect(cellFinder(puzzle.blanks.first), findsNothing);

    await tester.tap(find.byKey(const ValueKey('pause')));
    await tester.pump();
    expect(cellFinder(puzzle.blanks.first), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('3 mistakes lose; try again restarts', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(host('fa'));
    await tester.pump();
    final cell = puzzle.blanks.first;
    final wrong = tileFor(puzzle, cell, right: false);
    for (var k = 0; k < band[difficulty].mistakesAllowed!; k++) {
      await tester.tap(tileFinder(wrong));
      await tester.pump();
      await tester.tap(cellFinder(cell));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    await tester.tap(find.byKey(const ValueKey('result-primary')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('result-primary')), findsNothing);
    final mistakes = tester.widget<Text>(
      find.byKey(const ValueKey('mistakes')),
    );
    expect(mistakes.data, contains('۰'));

    await tester.pumpWidget(const SizedBox());
  });
}
