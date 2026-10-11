import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> openAndSolveWithHints(WidgetTester tester, Key button) async {
  await tester.tap(find.byKey(button));
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
}

void main() {
  testWidgets('solve today\'s daily: streak, disabled button, calendar', (
    tester,
  ) async {
    usePhone(tester);
    mockStorage({
      'coins': 100,
      'band': '18+',
      'language': 'en',
      // Solved yesterday already.
      'daily': '{"2026-09-29": 1}',
    });
    await tester.pumpWidget(
      await launchApp(now: () => DateTime(2026, 9, 30, 21, 15)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('daily-date'))).data,
      '30 September 2026',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('daily-streak'))).data,
      '1',
    );

    await openAndSolveWithHints(tester, const ValueKey('daily-easy'));
    expect(find.text('Daily puzzle solved!'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('result-streak'))).data,
      '2-day streak',
    );
    await tester.tap(find.byKey(const ValueKey('result-primary')));
    await tester.pumpAndSettle();

    // Back on the menu: easy is done for today, streak updated.
    final easy = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('daily-easy')),
        matching: find.byType(InkWell),
      ),
    );
    expect(easy.onTap, isNull);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('daily-streak'))).data,
      '2',
    );

    await tester.tap(find.byKey(const ValueKey('calendar')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('calendar-streak'))).data,
      '2-day streak',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('month-title'))).data,
      'September 2026',
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Persian shows the Jalali date and calendar', (tester) async {
    usePhone(tester);
    mockStorage({'band': '16-17', 'language': 'fa'});
    await tester.pumpWidget(await launchApp(now: () => DateTime(2026, 9, 30)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('daily-date'))).data,
      '۸ مهر ۱۴۰۵',
    );
    await tester.tap(find.byKey(const ValueKey('calendar')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('month-title'))).data,
      'مهر ۱۴۰۵',
    );
    expect(tester.takeException(), isNull);
  });

  for (final lang in ['ar', 'ur']) {
    testWidgets('daily card and calendar render in $lang', (tester) async {
      usePhone(tester);
      mockStorage({'band': '13-15', 'language': lang});
      await tester.pumpWidget(
        await launchApp(now: () => DateTime(2026, 9, 30)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('calendar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
