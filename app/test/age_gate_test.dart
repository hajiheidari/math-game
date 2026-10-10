import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/app_controller.dart';
import 'package:numcross/app/app_prefs.dart';
import 'package:numcross/game/game_screen.dart';
import 'package:numcross/screens/age_gate_screen.dart';
import 'package:numcross/screens/menu_screen.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

Future<void> pickAge(WidgetTester tester, int age) async {
  await tester.tap(find.byKey(const ValueKey('age-picker')));
  await tester.pumpAndSettle();
  // The menu only builds visible rows, so scroll until the age exists.
  await tester.scrollUntilVisible(
    find.text('$age'),
    48,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('$age').last);
  await tester.pumpAndSettle();
}

Future<Set<String>> storedKeys() async =>
    (await SharedPreferences.getInstance()).getKeys();

void main() {
  group('AppController', () {
    test('13+ stores only the band id, never the age', () async {
      mockStorage({}, false);
      final app = AppController(await AppPrefs.load());
      expect(app.gate, GateState.needsAge);
      await app.submitAge(16);
      expect(app.gate, GateState.ready);
      expect(app.band.id, '16-17');
      final p = await SharedPreferences.getInstance();
      expect(p.getKeys(), {'band'});
      expect(p.getString('band'), '16-17');
    });

    test('under 13 blocks, wipes other data, and survives restarts', () async {
      mockStorage({'language': 'fa', 'digits': 'native'});
      final app = AppController(await AppPrefs.load());
      await app.submitAge(12);
      expect(app.gate, GateState.blocked);
      expect(await storedKeys(), {'blocked'});

      final again = AppController(await AppPrefs.load());
      expect(again.gate, GateState.blocked);
      await again.submitAge(30);
      expect(
        again.gate,
        GateState.blocked,
        reason: 'cannot re-enter a different age',
      );
      expect(await storedKeys(), {'blocked'});
    });

    test('band can be changed later', () async {
      mockStorage({'band': '13-15'});
      final app = AppController(await AppPrefs.load());
      expect(app.band.id, '13-15');
      await app.setBand(band18plus);
      expect(app.band, band18plus);
      expect((await SharedPreferences.getInstance()).getString('band'), '18+');
    });

    test('unknown stored band asks again', () async {
      mockStorage({'band': 'removed-band'});
      expect(AppController(await AppPrefs.load()).gate, GateState.needsAge);
    });
  });

  testWidgets('first launch: nothing preselected, continue disabled', (
    tester,
  ) async {
    usePhone(tester);
    mockStorage();
    await tester.pumpWidget(await launchApp(lang: 'en'));
    await tester.pumpAndSettle();
    expect(find.byType(AgeGateScreen), findsOneWidget);
    expect(find.text('Select your age'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('age-continue')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('under 13 sees the block message, also after relaunch', (
    tester,
  ) async {
    usePhone(tester);
    mockStorage();
    await tester.pumpWidget(await launchApp(lang: 'en'));
    await tester.pumpAndSettle();
    await pickAge(tester, 10);
    await tester.tap(find.byKey(const ValueKey('age-continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('blocked-message')), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(await launchApp(lang: 'en'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('blocked-message')), findsOneWidget);
    expect(find.byType(AgeGateScreen), findsNothing);
  });

  testWidgets('13+ goes to the menu and can start a level', (tester) async {
    usePhone(tester);
    mockStorage();
    await tester.pumpWidget(await launchApp(lang: 'en'));
    await tester.pumpAndSettle();
    await pickAge(tester, 14);
    await tester.tap(find.byKey(const ValueKey('age-continue')));
    await tester.pumpAndSettle();
    expect(find.byType(MenuScreen), findsOneWidget);

    await tapVisible(tester, const ValueKey('difficulty-easy'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GameScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('settings: language, digits and band persist', (tester) async {
    usePhone(tester);
    mockStorage({'band': '13-15', 'language': 'en'});
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('lang-ar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('digits-western')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('band-18+')),
      100,
    );
    await tester.tap(find.byKey(const ValueKey('band-18+')));
    await tester.pumpAndSettle();

    final p = await SharedPreferences.getInstance();
    expect(p.getString('language'), 'ar');
    expect(p.getString('digits'), 'western');
    expect(p.getString('band'), '18+');

    // Relaunch picks everything up.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(MenuScreen))),
      TextDirection.rtl,
    );
  });
}
