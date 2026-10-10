import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';
import 'package:numcross/l10n/app_localizations.dart';
import 'package:numcross/rewards/friend_hints.dart';
import 'package:numcross/share/brag_lines.dart';
import 'package:numcross/share/share_result.dart';
import 'package:numcross_engine/numcross_engine.dart';

const link = 'https://adadi.espadna.com/?r=abcdefghjk';

ResultShare result({
  Difficulty difficulty = Difficulty.hard,
  int mistakes = 1,
  bool daily = false,
}) => ResultShare(
  isDaily: daily,
  date: daily ? DateTime(2026, 10, 8) : null,
  level: 12,
  difficulty: difficulty,
  stars: 2,
  elapsed: const Duration(minutes: 2, seconds: 31),
  mistakes: mistakes,
  streak: daily ? 5 : null,
);

Future<AppLocalizations> strings(String code) =>
    AppLocalizations.delegate.load(Locale(code));

LocaleController localeFor(String code) =>
    LocaleController(initial: languageForCode(code));

void main() {
  // The app gets this from GlobalMaterialLocalizations.
  setUpAll(initializeDateFormatting);

  test('every language has the same number of lines in each list', () {
    for (final b in kBragLines.values) {
      expect(b.me.length, b.you.length);
      expect(b.meFlawless.length, b.youFlawless.length);
    }
    expect(kBragLines.keys, containsAll(['en', 'fa', 'ar', 'ur']));
  });

  test('easy and medium are left out of what is shared', () async {
    final t = await strings('en');
    final en = localeFor('en');
    for (final d in Difficulty.values) {
      final text = result(difficulty: d).text(t, en, link: link);
      final shown = d == Difficulty.hard || d == Difficulty.expert;
      for (final name in ['Easy', 'Medium', 'Hard', 'Expert']) {
        expect(
          text.contains(name),
          shown && name == (d == Difficulty.hard ? 'Hard' : 'Expert'),
          reason: '$d / $name',
        );
      }
    }
  });

  test('the dialog line and the shared line tell the same joke', () {
    final r = result();
    final b = bragLinesFor('fa');
    expect(b.you.indexOf(r.cheer('fa')), b.me.indexOf(r.brag('fa')));
    final flawless = result(mistakes: 0);
    expect(b.youFlawless, contains(flawless.cheer('fa')));
    expect(b.meFlawless, contains(flawless.brag('fa')));
  });

  test('shared text: brag, title, stars and stats, streak, link', () async {
    final t = await strings('en');
    final text = result(
      daily: true,
      mistakes: 0,
    ).text(t, localeFor('en'), link: link);
    final lines = text.split('\n');
    expect(bragLinesFor('en').meFlawless, contains(lines[0]));
    expect(lines[1], 'Adadi · Daily Puzzle · 8 October 2026 · Hard');
    expect(lines[2], '⭐⭐  Time 2:31 · No mistakes');
    expect(lines[3], '🔥 5-day streak');
    expect(lines[4], 'Can you beat me? $link');
  });

  test('Persian: Jalali date and Persian digits', () async {
    final t = await strings('fa');
    final text = result(daily: true).text(t, localeFor('fa'), link: link);
    expect(text, contains('۱۶ مهر ۱۴۰۵'));
    expect(text, contains('۲:۳۱'));
  });

  test('the link follows the site: espadna.ir stays in Iran', () {
    expect(
      FriendHints.siteFor(Uri.parse('https://adadi.espadna.com/')),
      'https://adadi.espadna.com',
    );
  });

  // Renders the card in every language; the PNGs go to build/share_cards/
  // for a look (fonts loaded so the text is real, not test boxes).
  testWidgets('result card renders', (tester) async {
    await tester.runAsync(() async {
      for (final family in ['Vazirmatn', 'Roboto']) {
        final font = FontLoader(family)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                File('assets/fonts/Vazirmatn.ttf').readAsBytesSync(),
              ),
            ),
          );
        await font.load();
      }
      final urdu = FontLoader('NotoNastaliqUrdu')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('assets/fonts/NotoNastaliqUrdu.ttf').readAsBytesSync(),
            ),
          ),
        );
      await urdu.load();
      final out = Directory('build/share_cards')..createSync(recursive: true);
      for (final code in ['en', 'fa', 'ar', 'ur']) {
        final png = await renderResultCard(
          result(daily: code == 'fa' || code == 'ur'),
          await strings(code),
          localeFor(code),
        );
        expect(png, isNotNull);
        expect(png!.sublist(1, 4), Uint8List.fromList('PNG'.codeUnits));
        File('${out.path}/$code.png').writeAsBytesSync(png);
      }
    });
  });
}
