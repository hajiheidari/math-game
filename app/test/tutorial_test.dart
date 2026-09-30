import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/screens/menu_screen.dart';
import 'package:numcross/screens/tutorial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

Future<void> place(WidgetTester tester, int tile, String cell) async {
  await tester.tap(find.byKey(ValueKey('tile-$tile')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('cell-$cell')));
  await tester.pump();
}

void main() {
  testWidgets('first visit runs the tutorial, then the menu', (tester) async {
    usePhone(tester);
    mockStorage({'band': '16-17', 'language': 'en'}, false);
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    expect(find.byType(TutorialScreen), findsOneWidget);

    // Step 1: 3 + ? = 7, tiles [5, 4]. Wrong first.
    await place(tester, 0, '0-2');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('tutorial-text'))).data,
      startsWith('Not quite'),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await place(tester, 1, '0-2');
    await tester.pump(const Duration(milliseconds: 800));

    // Step 2: 2 + ? = 6 crossing ? × 3 = ?, tiles [12, 8, 4].
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('tutorial-text'))).data,
      startsWith('Some boxes'),
    );
    await place(tester, 2, '0-2');
    await place(tester, 0, '4-2');
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.byKey(const ValueKey('tutorial-finish')));
    await tester.pumpAndSettle();
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(find.byType(TutorialScreen), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool('tutorialDone'),
      isTrue,
    );

    // Not shown again.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    expect(find.byType(TutorialScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  for (final lang in ['fa', 'ar', 'ur']) {
    testWidgets('tutorial renders in $lang and can be skipped', (tester) async {
      usePhone(tester);
      mockStorage({'band': '18+', 'language': lang}, false);
      await tester.pumpWidget(await launchApp());
      await tester.pumpAndSettle();
      expect(find.byType(TutorialScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('tutorial-skip')));
      await tester.pumpAndSettle();
      expect(find.byType(MenuScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('settings: sound and vibration switches persist', (tester) async {
    usePhone(tester);
    mockStorage({'band': '18+', 'language': 'en'});
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('haptics')), 100);
    for (final key in ['sound', 'haptics']) {
      await tester.ensureVisible(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pump();
    }
    await tester.pump();
    final p = await SharedPreferences.getInstance();
    expect(p.getBool('sound'), isFalse);
    expect(p.getBool('haptics'), isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
