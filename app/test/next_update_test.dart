// 0.14.0: challenges, backup (recovery code, merge), certificates, bigger
// cells on big boards, the digits setting.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numcross/app/app_controller.dart';
import 'package:numcross/app/app_prefs.dart';
import 'package:numcross/app/progress_store.dart';
import 'package:numcross/app_root.dart';
import 'package:numcross/backup/backup.dart';
import 'package:numcross/backup/save_data.dart';
import 'package:numcross/certificates/certificate_painter.dart';
import 'package:numcross/certificates/certificates.dart';
import 'package:numcross/challenge/challenge.dart';
import 'package:numcross/game/board_view.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';
import 'package:numcross/l10n/app_localizations.dart';
import 'package:numcross/screens/certificates_screen.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// The backup API of site/worker.js, in memory.
class FakeServer {
  final saves = <String, String>{};
  var calls = 0;

  late final client = MockClient((req) async {
    calls++;
    final body = jsonDecode(req.body) as Map<String, Object?>;
    final k = body['k'] as String;
    if (req.url.path.endsWith('/backup/save')) {
      saves[k] = body['d'] as String;
      return http.Response('{"ok":true}', 200);
    }
    final d = saves[k];
    return d == null
        ? http.Response('{"error":"no backup"}', 404)
        : http.Response(jsonEncode({'d': d, 'at': 1}), 200);
  });
}

Future<Backup> backupFor(
  FakeServer server,
  Map<String, Object> values, {
  VoidCallback? onRestored,
}) async {
  SharedPreferences.setMockInitialValues(values);
  return Backup(
    await SharedPreferences.getInstance(),
    client: server.client,
    onRestored: onRestored ?? () {},
  );
}

void main() {
  group('challenge links', () {
    test('a level and a daily survive the round trip', () {
      final level = Challenge(
        band: band16to17,
        difficulty: Difficulty.hard,
        level: 12,
        time: const Duration(minutes: 2, seconds: 31),
      );
      expect(level.code, '12lc-47');
      final back = Challenge.decode(level.code)!;
      expect(back.band, band16to17);
      expect(back.difficulty, Difficulty.hard);
      expect(back.level, 12);
      expect(back.time, level.time);
      expect(back.puzzle.solution, level.puzzle.solution);

      final daily = Challenge(
        band: band18plus,
        difficulty: Difficulty.expert,
        date: DateTime(2026, 10, 14),
        time: const Duration(seconds: 400),
      );
      final d = Challenge.fromUri(
        Uri.parse(daily.link('https://adadi.espadna.com', 'abcdefghjk')),
      )!;
      expect(d.date, DateTime(2026, 10, 14));
      expect(d.isDaily, isTrue);
      expect(d.band, band18plus);
    });

    test('cut off or made-up codes are refused', () {
      for (final bad in [
        null,
        '',
        '12lc',
        '92lc-47',
        '14lc-47',
        '12d1-2',
        'x',
      ]) {
        expect(Challenge.decode(bad), isNull, reason: '$bad');
      }
      // 2026-02-30 is not a date.
      expect(Challenge.decode('00d${20260230.toRadixString(36)}-10'), isNull);
    });

    test('verdict', () {
      const a = Duration(seconds: 90), b = Duration(seconds: 100);
      expect(verdictFor(a, b), Verdict.win);
      expect(verdictFor(b, a), Verdict.lose);
      expect(verdictFor(a, a), Verdict.tie);
    });
  });

  group('save merge', () {
    test('keeps the best of each, never less', () {
      final mine = SaveData({
        'progress/13-15/easy': '3321',
        'daily': '{"2026-10-01":1,"2026-10-02":2}',
        'coins': 1,
        'band': '13-15',
        'ref/secret': 'mine',
      });
      final other = SaveData({
        'progress/13-15/easy': '13333',
        'progress/18+/hard': '2',
        'daily': '{"2026-10-02":1,"2026-10-03":8}',
        'coins': 4,
        'band': '18+',
        'sound': false,
        'ref/secret': 'theirs',
      });
      final m = merge(mine, other).values;
      expect(m['progress/13-15/easy'], '33333');
      expect(m['progress/18+/hard'], '2');
      expect(jsonDecode(m['daily'] as String), {
        '2026-10-01': 1,
        '2026-10-02': 3,
        '2026-10-03': 8,
      });
      expect(m['coins'], 4);
      expect(m['band'], '13-15', reason: "this device's setting");
      expect(m['sound'], false);
      expect(m['ref/secret'], 'mine');
      expect(
        merge(mine, other, adoptIdentity: true).values['ref/secret'],
        'theirs',
      );
    });

    test('encode / decode keep the types', () {
      final s = SaveData({
        'a': 'x',
        'b': 3,
        'c': true,
        'd': ['p', 'q'],
      });
      final back = SaveData.decode(s.encode(device: 'dev', key: 'k'))!;
      expect(back.values, s.values);
      expect(back.device, 'dev');
      expect(back.key, 'k');
      expect(SaveData.decode('nonsense'), isNull);
    });
  });

  group('recovery code', () {
    test('format and parse (Persian digits, dashes, case)', () {
      expect(Backup.format('abcdefghjkmn'), 'ABCD-EFGH-JKMN');
      expect(Backup.parse('abcd-efgh-jkmn'), 'abcdefghjkmn');
      expect(Backup.parse(' ABCD EFGH JKMN '), 'abcdefghjkmn');
      expect(Backup.parse('abcd-efgh-jk۲۳'), 'abcdefghjk23');
      expect(Backup.parse('abcd-efgh-jkm'), isNull);
      expect(Backup.parse('abcd-efgh-jkm0'), isNull, reason: 'no 0 in codes');
    });

    test('an empty install uploads nothing', () async {
      final server = FakeServer();
      final b = await backupFor(server, {'band': '13-15'});
      await b.sync();
      expect(server.calls, 0);
      expect(b.key, isNull);
    });

    test(
      'progress is saved under a code and comes back on another phone',
      () async {
        final server = FakeServer();
        final first = await backupFor(server, {
          'band': '13-15',
          'progress/13-15/easy': '332',
          'coins': 2,
          'ref/secret': 'secret-of-the-first-phone',
        });
        await first.sync();
        final code = first.key!;
        expect(code, hasLength(12));
        expect(server.saves, contains(code));

        var restored = 0;
        final second = await backupFor(server, {
          'band': '18+',
          'progress/13-15/easy': '1',
          'daily': '{"2026-10-05":1}',
        }, onRestored: () => restored++);
        expect(await second.restore('nope'), RestoreResult.badCode);
        expect(await second.restore('aaaa-bbbb-cccc'), RestoreResult.notFound);
        expect(await second.restore(Backup.format(code)), RestoreResult.done);
        final p = await SharedPreferences.getInstance();
        expect(p.getString('progress/13-15/easy'), '332');
        expect(p.getString('daily'), '{"2026-10-05":1}');
        expect(p.getInt('coins'), 2);
        expect(p.getString('band'), '18+');
        expect(p.getString('ref/secret'), 'secret-of-the-first-phone');
        expect(second.key, code);
        expect(restored, greaterThan(0));
      },
    );

    test('saves at most every 3 hours unless forced', () async {
      final server = FakeServer();
      final b = await backupFor(server, {'progress/13-15/easy': '3'});
      await b.sync();
      final after = server.calls;
      await b.sync();
      expect(server.calls, after);
      await b.sync(force: true);
      expect(server.calls, greaterThan(after));
    });
  });

  group('certificates', () {
    setUpAll(initializeDateFormatting);

    Future<Certificates> certsWith(Map<String, Object> values) async {
      SharedPreferences.setMockInitialValues(values);
      final p = await SharedPreferences.getInstance();
      return Certificates(
        p,
        ProgressStore(p),
        now: () => DateTime(2026, 10, 14),
      );
    }

    test('a 7-day streak and 25 levels earn certificates, once', () async {
      final days = {
        for (var d = 1; d <= 7; d++)
          ProgressStore.dateKey(DateTime(2026, 10, d)): d == 3 ? 15 : 1,
      };
      final c = await certsWith({
        'daily': jsonEncode(days),
        'progress/13-15/easy': '3' * 20,
        'progress/18+/expert': '2' * 5,
      });
      final fresh = await c.check();
      expect(fresh.map((e) => e.kind), [
        CertKind.streak7,
        CertKind.levels25,
        CertKind.allDaily,
      ]);
      expect(c.unseen, 3);
      expect(await c.check(), isEmpty);
      await c.markSeen();
      expect(c.unseen, 0);
      expect(c.of(CertKind.streak7)!.date, DateTime(2026, 10, 14));
    });

    testWidgets('a certificate draws in every language', (tester) async {
      for (final code in ['en', 'fa', 'ar', 'ur']) {
        final t = await AppLocalizations.delegate.load(Locale(code));
        final locale = LocaleController(initial: languageForCode(code));
        final texts = certTexts(
          t,
          locale,
          Cert(CertKind.streak30, DateTime(2026, 10, 14)),
          'Sara',
        );
        expect(texts.heading, isNotEmpty);
        final png = await tester.runAsync(
          () => CertificatePainter(texts, locale.language).png(),
        );
        expect(png, isNotNull);
        expect(png!.length, greaterThan(10000));
      }
    });
  });

  test('operator-only rows and columns are narrow: bigger number cells', () {
    final p = generateLevel(band18plus, Difficulty.expert, 3);
    final cols = BoardGrid.tracks(p, rows: false);
    expect(cols.where((u) => u < 1), isNotEmpty);
    final units = cols.fold(0.0, (a, b) => a + b);
    // The same width now holds bigger cells than with equal tracks.
    expect(360 / units, greaterThan(360 / p.cols * 1.15));
  });

  testWidgets('a big board can be zoomed', (tester) async {
    usePhone(tester);
    mockStorage({'band': '18+', 'language': 'en'});
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    await tapVisible(tester, const ValueKey('difficulty-expert'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('board-zoom')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zoom')));
    await tester.pump();
    final viewer = tester.widget<InteractiveViewer>(
      find.byKey(const ValueKey('board-zoom')),
    );
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('digits: no choice in English, a working one in Persian', (
    tester,
  ) async {
    usePhone(tester);
    mockStorage({'band': '13-15', 'language': 'en'});
    await tester.pumpWidget(await launchApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('digits-western')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('lang-fa')));
    await tester.pumpAndSettle();
    final native = find.byKey(const ValueKey('digits-native'));
    expect(tester.widget<ChoiceChip>(native).selected, isTrue);
    await tester.tap(find.byKey(const ValueKey('digits-western')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('digits-western')))
          .selected,
      isTrue,
    );
    expect(tester.widget<ChoiceChip>(native).selected, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a friend opens a challenge, plays it and sees who won', (
    tester,
  ) async {
    usePhone(tester);
    mockStorage({'band': '18+', 'language': 'en'});
    final prefs = await AppPrefs.load();
    final challenge = Challenge(
      band: band13to15,
      difficulty: Difficulty.easy,
      level: 1,
      time: const Duration(hours: 1),
    );
    final app = AppController(prefs)..pendingChallenge = challenge;
    await tester.pumpWidget(
      AdadiApp(
        locale: LocaleController(initial: languageForCode('en')),
        app: app,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('challenge-dialog')), findsOneWidget);
    expect(find.textContaining('1:00:00'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('challenge-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('versus-time')), findsOneWidget);

    final p = challenge.puzzle;
    for (final cell in p.blanks) {
      final value = p.solution[cell]!;
      final tile = [
        for (var i = 0; i < p.bank.length; i++)
          if (p.bank[i] == value &&
              find.byKey(ValueKey('tile-$i')).evaluate().isNotEmpty)
            i,
      ].first;
      await tester.tap(find.byKey(ValueKey('tile-$tile')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('cell-${cell.row}-${cell.col}')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('versus-verdict')), findsOneWidget);
    expect(find.text('You beat your friend! 🎉'), findsOneWidget);
    // A friend's puzzle is not the player's level 1.
    expect(prefs.shared.getString('progress/13-15/easy'), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
