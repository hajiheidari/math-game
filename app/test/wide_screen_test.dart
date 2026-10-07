import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app_root.dart';
import 'package:numcross/screens/menu_screen.dart';

import 'helpers.dart';

void main() {
  for (final lang in ['en', 'fa']) {
    testWidgets('wide monitor: the game stays a phone-width column ($lang)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      mockStorage({'band': '18+', 'language': lang});
      await tester.pumpWidget(await launchApp());
      await tester.pumpAndSettle();
      final menu = tester.getRect(find.byType(MenuScreen));
      expect(menu.width, PhoneColumn.maxWidth);
      expect(menu.center.dx, 960); // centered
      expect(tester.takeException(), isNull);

      // Settings (with the new Contact support row) also fits.
      await tester.tap(find.byKey(const ValueKey('settings')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('contact-support')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('espadna.support@gmail.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('phones are untouched', (tester) async {
    usePhone(tester);
    mockStorage({'band': '18+', 'language': 'en'});
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(MenuScreen)).width, 360);
    await tester.pumpWidget(const SizedBox());
  });
}
