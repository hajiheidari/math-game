import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/i18n/digits.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';

import 'helpers.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  test('Urdu gets tall line height and a non-Nastaliq numeral font', () {
    final ur = languageForCode('ur');
    expect(ur.lineHeight, greaterThanOrEqualTo(1.8));
    expect(ur.numeralFontFamily, 'Vazirmatn');
    // Other languages keep Material's heights and their own font for numbers.
    for (final code in ['en', 'fa', 'ar']) {
      final lang = languageForCode(code);
      expect(lang.lineHeight, isNull, reason: code);
      expect(lang.numeralFontFamily, lang.fontFamily, reason: code);
    }
  });

  test('every language has every string (no missing or extra keys)', () {
    final english = _keys(_arb('en'));
    for (final lang in kLanguages) {
      expect(_keys(_arb(lang.code)), english, reason: 'app_${lang.code}.arb');
    }
  });

  test('every ARB file is registered in kLanguages', () {
    final files = Directory('lib/l10n')
        .listSync()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.startsWith('app_') && n.endsWith('.arb'))
        .map((n) => n.substring(4, n.length - 4))
        .toSet();
    expect(files, {for (final l in kLanguages) l.code});
  });

  test('digit conversion', () {
    expect(localizeDigits('12 + 30 = 42', DigitSet.persian), '۱۲ + ۳۰ = ۴۲');
    expect(localizeDigits('144', DigitSet.arabicIndic), '١٤٤');
    expect(localizeDigits('13-15', DigitSet.western), '13-15');
  });

  test('digit modes per language', () {
    final c = LocaleController(initial: languageFor(const Locale('fa')));
    expect(c.n(125), '۱۲۵');
    c.digitMode = DigitMode.western;
    expect(c.n(125), '125');
    c.language = languageFor(const Locale('ur'));
    c.digitMode = DigitMode.auto;
    expect(c.n(125), '125');
    c.digitMode = DigitMode.native;
    expect(c.n(125), '۱۲۵');
  });

  for (final lang in kLanguages) {
    testWidgets(
      'menu and settings render in ${lang.code} with the right direction',
      (tester) async {
        usePhone(tester);
        mockStorage({'band': '18+'});
        await tester.pumpWidget(await launchApp(lang: lang.code));
        await tester.pumpAndSettle();

        final rtl = {'fa', 'ar', 'ur'}.contains(lang.code);
        final ctx = tester.element(find.byType(Scaffold));
        expect(
          Directionality.of(ctx),
          rtl ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const ValueKey('settings')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
