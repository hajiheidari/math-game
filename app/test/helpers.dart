import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/app_controller.dart';
import 'package:numcross/app/app_prefs.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';
import 'package:numcross/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phone-sized test surface (360 x 780 dp).
void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Fresh device storage with [values]. The tutorial counts as already seen
/// unless [tutorialDone] is false.
void mockStorage([
  Map<String, Object> values = const {},
  bool tutorialDone = true,
]) => SharedPreferences.setMockInitialValues({
  if (tutorialDone) 'tutorialDone': true,
  ...values,
});

/// The app as `main()` builds it, reading the mocked storage.
/// [lang] overrides the saved/device language; [now] fixes the clock.
Future<AdadiApp> launchApp({String? lang, DateTime Function()? now}) async {
  final prefs = await AppPrefs.load();
  if (lang == null && now == null) return AdadiApp.fromPrefs(prefs);
  return AdadiApp(
    locale: LocaleController(
      initial: languageForCode(lang ?? prefs.languageCode),
      digitMode: prefs.digitMode,
    ),
    app: AppController(prefs, now: now ?? DateTime.now),
  );
}

/// Scrolls [key] into view (the menu is longer than a phone screen), then
/// taps it.
Future<void> tapVisible(WidgetTester tester, Key key) async {
  final target = find.byKey(key);
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
}
