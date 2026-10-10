// App Store screenshots, rendered by the app itself at Apple's sizes:
//   SCREENSHOTS=1 flutter test test/store_screenshots_test.dart
// writes docs/store/appstore/{iphone,ipad}-N.png (iPhone 6.9": 1320x2868,
// iPad 13": 2064x2752). Skipped in normal test runs.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/progress_store.dart';
import 'package:numcross_engine/numcross_engine.dart';

import 'helpers.dart';

const _shot = ValueKey('store-shot');
final _out = Directory('../docs/store/appstore');

const devices = {
  'iphone': (size: Size(1320, 2868), ratio: 3.0),
  'ipad': (size: Size(2064, 2752), ratio: 2.0),
};

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(f).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent;
  final material = '${sdk.path}/artifacts/material_fonts';
  // Emoji: see kEmojiFallback.
  const emoji = '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf';
  await load('Roboto', [
    for (final w in ['Regular', 'Medium', 'Bold']) '$material/Roboto-$w.ttf',
  ]);
  if (File(emoji).existsSync()) await load('NotoColorEmoji', [emoji]);
  await load('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
  await load('Vazirmatn', ['assets/fonts/Vazirmatn.ttf']);
}

Future<void> _save(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_shot),
    );
    final image = await boundary.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${_out.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Puts the right tile into [cell].
Future<void> _place(WidgetTester tester, Puzzle p, Pos cell) async {
  var tile = -1;
  for (var i = 0; i < p.bank.length; i++) {
    if (p.bank[i] == p.solution[cell] &&
        find.byKey(ValueKey('tile-$i')).evaluate().isNotEmpty) {
      tile = i;
    }
  }
  final tileFinder = find.byKey(ValueKey('tile-$tile'));
  await tester.ensureVisible(tileFinder);
  await tester.tap(tileFinder);
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('cell-${cell.row}-${cell.col}')));
  await tester.pump();
}

void main() {
  final run = Platform.environment['SCREENSHOTS'] == '1';
  final today = DateTime(2026, 10, 10, 9, 30);

  Map<String, Object> storage(String lang) => {
    'band': '18+',
    'language': lang,
    'coins': 6,
    'daily': jsonEncode({
      for (final back in [1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13])
        ProgressStore.dateKey(today.subtract(Duration(days: back))): 3,
    }),
    'progress/18+/easy': '3333333332',
    'progress/18+/medium': '33233',
    'progress/18+/hard': '32',
  };

  for (final entry in devices.entries) {
    final device = entry.key;
    testWidgets('store screenshots: $device', skip: !run, (tester) async {
      await tester.runAsync(_loadFonts);
      _out.createSync(recursive: true);
      tester.view.physicalSize = entry.value.size;
      tester.view.devicePixelRatio = entry.value.ratio;
      addTearDown(tester.view.reset);

      Future<void> launch(String lang) async {
        // A fresh app (the same widget tree would keep the old screens).
        await tester.pumpWidget(const SizedBox());
        mockStorage(storage(lang));
        await tester.pumpWidget(
          RepaintBoundary(
            key: _shot,
            child: await launchApp(now: () => today),
          ),
        );
        await _settle(tester);
      }

      // 1. Menu: daily puzzle, streak, difficulties.
      await launch('en');
      await _save(tester, '$device-1');

      // 2. A hard level, half solved.
      final puzzle = generateLevel(band18plus, Difficulty.hard, 3);
      await tester.tap(find.byKey(const ValueKey('difficulty-hard')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('level-3')));
      await _settle(tester);
      final blanks = puzzle.blanks.toList();
      for (final cell in blanks.take(blanks.length ~/ 2)) {
        await _place(tester, puzzle, cell);
      }
      await _settle(tester);
      await _save(tester, '$device-2');

      // 3. Solved: stars, the fun line and "Show your friends".
      for (final cell in blanks.skip(blanks.length ~/ 2)) {
        await _place(tester, puzzle, cell);
      }
      await _settle(tester);
      await _save(tester, '$device-3');

      // 4. Daily calendar with a streak.
      await launch('en');
      await tester.tap(find.byKey(const ValueKey('calendar')));
      await _settle(tester);
      await _save(tester, '$device-4');

      // 5. The same game in Persian (also Arabic and Urdu).
      await launch('fa');
      await tester.tap(find.byKey(const ValueKey('difficulty-medium')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('level-6')));
      await _settle(tester);
      final fa = generateLevel(band18plus, Difficulty.medium, 6);
      for (final cell in fa.blanks.take(3)) {
        await _place(tester, fa, cell);
      }
      await _settle(tester);
      await _save(tester, '$device-5');

      await tester.pumpWidget(const SizedBox());
    });
  }
}
