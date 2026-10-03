// Full player journey on a real Android device/emulator, with real plugins
// (storage, sounds, Google Mobile Ads in test mode). Takes a screenshot of
// each screen. Run on CI by .github/workflows/emulator.yml:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numcross/app/app_prefs.dart';
import 'package:numcross/app/crash_guard.dart';
import 'package:numcross/game/game_screen.dart';
import 'package:numcross/main.dart';
import 'package:numcross/screens/menu_screen.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final WidgetsBinding binding;
var _shot = 0;

/// Waits for the UI to calm down; the game clock ticks forever, so a
/// time-boxed settle is enough.
Future<void> settle(WidgetTester tester, [int ms = 600]) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  } catch (_) {}
  await tester.pump(Duration(milliseconds: ms));
}

Future<void> shot(WidgetTester tester, String name) async {
  await settle(tester);
  _shot++;
  final b = binding;
  if (b is IntegrationTestWidgetsFlutterBinding) {
    await b.takeScreenshot('${_shot.toString().padLeft(2, '0')}-$name');
  }
}

Future<void> tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 250));
}

Finder key(String k) => find.byKey(ValueKey(k));

/// Android back button.
Future<void> back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await settle(tester);
}

Future<void> backToMenu(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    if (find.byType(MenuScreen).hitTestable().evaluate().isNotEmpty) return;
    await back(tester);
  }
  expect(find.byType(MenuScreen).hitTestable(), findsOneWidget);
}

/// The puzzle on screen, rebuilt from the GameScreen's parameters.
Puzzle currentPuzzle(WidgetTester tester) {
  final g = tester.widget<GameScreen>(find.byType(GameScreen));
  return g.isDaily
      ? generateDaily(g.band, g.difficulty, g.date!)
      : generateLevel(g.band, g.difficulty, g.level);
}

/// Places the correct tile on [cells] (default: every blank).
Future<void> solve(WidgetTester tester, {int leaveOpen = 0}) async {
  final p = currentPuzzle(tester);
  final cells = p.blanks.toList();
  for (final cell in cells.take(cells.length - leaveOpen)) {
    final value = p.solution[cell];
    // Two tiles can share a value: use one that is still in the bank.
    final i = [
      for (var i = 0; i < p.bank.length; i++)
        if (p.bank[i] == value && key('tile-$i').evaluate().isNotEmpty) i,
    ].first;
    await tap(tester, key('tile-$i'));
    await tap(tester, key('cell-${cell.row}-${cell.col}'));
  }
}

void expectNoErrors(WidgetTester tester, String where) {
  expect(tester.takeException(), isNull, reason: where);
  expect(CrashGuard.report.value, isNull, reason: where);
}

void main() {
  binding = const bool.fromEnvironment('ON_HOST')
      ? TestWidgetsFlutterBinding.ensureInitialized()
      : IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full journey: age, tutorial, levels, hint, daily, languages', (
    tester,
  ) async {
    if (const bool.fromEnvironment('ON_HOST')) {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
    }
    final storage = await SharedPreferences.getInstance();
    await storage.clear();
    final b = binding;
    if (b is IntegrationTestWidgetsFlutterBinding) {
      await b.convertFlutterSurfaceToImage();
    }

    await tester.pumpWidget(
      CrashOverlay(child: AdadiApp.fromPrefs(await AppPrefs.load())),
    );
    await settle(tester);

    await shot(tester, 'age-gate');
    await tap(tester, key('age-picker'));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('15'),
      48,
      scrollable: find.byType(Scrollable).last,
    );
    await settle(tester);
    await tester.tap(find.text('15').last);
    await settle(tester);
    await tap(tester, key('age-continue'));
    await settle(tester);
    expect(key('tile-0'), findsOneWidget, reason: 'tutorial after age gate');

    // Tutorial: 3 + ? = 7 (tiles 5, 4), then 2 + ? = 6 × 3 (tiles 12, 8, 4).
    await shot(tester, 'tutorial-1');
    await tap(tester, key('tile-0'));
    await tap(tester, key('cell-0-2'));
    await shot(tester, 'tutorial-wrong-tile');
    await tester.pump(const Duration(milliseconds: 800));
    await tap(tester, key('tile-1'));
    await tap(tester, key('cell-0-2'));
    await tester.pump(const Duration(milliseconds: 800));
    await shot(tester, 'tutorial-2');
    await tap(tester, key('tile-2'));
    await tap(tester, key('cell-0-2'));
    await tap(tester, key('tile-0'));
    await tap(tester, key('cell-4-2'));
    await tester.pump(const Duration(milliseconds: 800));
    await tap(tester, key('tutorial-finish'));
    await settle(tester);
    expect(find.byType(MenuScreen), findsOneWidget);

    // Ads + consent start ~1 s after the menu appears: give them time.
    await tester.pump(const Duration(seconds: 6));
    await shot(tester, 'menu');
    expectNoErrors(tester, 'menu + ads start');

    // Level 1 (easy).
    await tap(tester, key('difficulty-easy'));
    await settle(tester);
    await shot(tester, 'level-select');
    await tap(tester, key('continue'));
    await settle(tester);
    await shot(tester, 'level-1');
    await solve(tester);
    await settle(tester, 1500);
    expect(key('result-primary'), findsOneWidget);
    await shot(tester, 'level-1-won');

    // Level 2: solve all but one cell, then use a hint for the last.
    await tap(tester, key('result-primary'));
    await settle(tester);
    expect(find.byType(GameScreen), findsOneWidget);
    await solve(tester, leaveOpen: 1);
    await shot(tester, 'level-2-before-hint');
    await tap(tester, key('hint'));
    await settle(tester, 1500);
    await shot(tester, 'level-2-after-hint');
    expect(key('result-primary'), findsOneWidget);
    expectNoErrors(tester, 'levels');

    // Back to the menu, then today's daily puzzle.
    await backToMenu(tester);
    await tap(tester, key('daily-easy'));
    await settle(tester);
    await shot(tester, 'daily');
    await solve(tester);
    await settle(tester, 1500);
    await shot(tester, 'daily-won');
    expectNoErrors(tester, 'daily');
    await backToMenu(tester);
    await tap(tester, key('calendar'));
    await settle(tester);
    await shot(tester, 'calendar');
    await back(tester);

    // Settings, then every other language: menu + a game screen.
    for (final lang in ['fa', 'ar', 'ur']) {
      await tap(tester, key('settings'));
      await settle(tester);
      if (lang == 'fa') await shot(tester, 'settings');
      await tap(tester, key('lang-$lang'));
      await settle(tester);
      await shot(tester, 'settings-$lang');
      await back(tester);
      await shot(tester, 'menu-$lang');
      await tap(tester, key('difficulty-medium'));
      await settle(tester);
      await tap(tester, key('continue'));
      await settle(tester);
      await shot(tester, 'game-$lang');
      await backToMenu(tester);
      expectNoErrors(tester, 'language $lang');
    }
  });
}
