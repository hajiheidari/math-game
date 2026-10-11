import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:share_plus/share_plus.dart';

import '../app/app_scope.dart';
import '../app/palette.dart';
import '../game/game_controller.dart' show formatClock;
import '../i18n/dates.dart';
import '../i18n/labels.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../rewards/friend_hints.dart';
import 'brag_lines.dart';
import 'web_share.dart';

/// A won puzzle, as the player shares it (picture card + text).
class ResultShare {
  final bool isDaily;

  /// The daily puzzle's date (daily only).
  final DateTime? date;
  final int level;
  final Difficulty difficulty;
  final int stars;
  final Duration elapsed;
  final int mistakes;

  /// Daily streak after this win (daily only).
  final int? streak;

  const ResultShare({
    required this.isDaily,
    this.date,
    required this.level,
    required this.difficulty,
    required this.stars,
    required this.elapsed,
    required this.mistakes,
    this.streak,
  });

  /// Easy and medium are left out of what is shared: only a hard or expert
  /// win is worth bragging about (Amir, 2026-10-08).
  bool get showsDifficulty =>
      difficulty == Difficulty.hard || difficulty == Difficulty.expert;

  bool get flawless => mistakes == 0;

  /// Same pick for the same result, so the dialog and the post match.
  int get _seed => elapsed.inSeconds + level * 7 + (date?.day ?? 0);

  /// Line on the result dialog ("you ..."), inviting the player to share.
  String cheer(String languageCode) {
    final b = bragLinesFor(languageCode);
    final list = flawless ? b.youFlawless : b.you;
    return list[_seed % list.length];
  }

  /// First line of the shared post ("I ...").
  String brag(String languageCode) {
    final b = bragLinesFor(languageCode);
    final list = flawless ? b.meFlawless : b.me;
    return list[_seed % list.length];
  }

  /// "Daily Puzzle · 16 Mehr 1405" / "Level 12 · Hard".
  String title(AppLocalizations t, LocaleController locale) => [
    if (isDaily && date != null) ...[
      t.menuDaily,
      formatLongDate(locale, date!),
    ] else
      t.levelNumber(locale.n(level)),
    if (showsDifficulty) difficultyName(t, difficulty),
  ].join(' · ');

  /// "Time 2:31 · No mistakes".
  String stats(AppLocalizations t, LocaleController locale) => [
    '${t.time} ${locale.n(formatClock(elapsed))}',
    if (flawless)
      t.shareNoMistakes
    else
      '${t.mistakesLabel} ${locale.n(mistakes)}',
  ].join(' · ');

  String? streakText(AppLocalizations t, LocaleController locale) =>
      isDaily && (streak ?? 0) > 1
      ? t.streakDays(streak!, locale.n(streak!))
      : null;

  /// The text that goes with the picture (or alone on the web).
  /// [link]: the player's link with their invite code (FriendHints.link).
  String text(
    AppLocalizations t,
    LocaleController locale, {
    required String link,
  }) {
    final streakLine = streakText(t, locale);
    return [
      brag(locale.language.code),
      '${t.appTitle} · ${title(t, locale)}',
      '${'⭐' * stars}  ${stats(t, locale)}',
      if (streakLine != null) '🔥 $streakLine',
      '${t.shareBeatMe} $link',
    ].join('\n');
  }
}

/// Extra fonts for the emoji in the fun lines. Empty in the app: the
/// phone's own emoji font draws them (naming an emoji font here made iOS draw
/// plain digits with it: "1 0 0 %"). Tests set it to draw emoji in
/// screenshots (test/store_screenshots_test.dart).
List<String> emojiFallback = const [];

enum ShareOutcome { shared, copied, failed }

/// Opens the share sheet: picture + text on phones; text on the web (the
/// browser's share sheet, or the clipboard when it has none). The link in it
/// carries the player's invite code: friends who open it earn them hints.
Future<ShareOutcome> shareResult(
  BuildContext context,
  ResultShare result, {
  Rect? origin,
}) async {
  final t = AppLocalizations.of(context);
  final locale = LocaleScope.of(context);
  final link = AppScope.of(context).hints.link(Uri.base);
  final text = result.text(t, locale, link: link);
  final png = kIsWeb ? null : await renderResultCard(result, t, locale);
  return _share(text, png: png, origin: origin);
}

/// "Invite friends": a short message with the player's link.
Future<ShareOutcome> shareInvite(BuildContext context, {Rect? origin}) {
  final t = AppLocalizations.of(context);
  final link = AppScope.of(context).hints.link(Uri.base);
  return _share(t.inviteMessage(link), origin: origin);
}

Future<ShareOutcome> _share(String text, {Uint8List? png, Rect? origin}) async {
  try {
    if (kIsWeb) {
      if (await webShareText(text)) return ShareOutcome.shared;
      await Clipboard.setData(ClipboardData(text: text));
      return ShareOutcome.copied;
    }
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        // null, not []: iOS rejects an empty file list ("Non-empty paths
        // expected"), which made the invite fall back to copying.
        files: png == null
            ? null
            : [XFile.fromData(png, mimeType: 'image/png', name: 'adadi.png')],
        fileNameOverrides: png != null ? ['adadi.png'] : null,
        sharePositionOrigin: origin,
      ),
    );
    return ShareOutcome.shared;
  } catch (e) {
    debugPrint('share failed: $e');
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return ShareOutcome.copied;
    } catch (_) {
      return ShareOutcome.failed;
    }
  }
}

// --- The picture card -------------------------------------------------------

const _cardSize = Size(1080, 1350); // 4:5, fits feeds, stories and chats.
const _ink = Palette.ink;
const _gold = Palette.sun;

/// Draws the result card as a PNG (null if the engine cannot render it).
Future<Uint8List?> renderResultCard(
  ResultShare r,
  AppLocalizations t,
  LocaleController locale,
) async {
  final lang = locale.language;
  final dir = lang.code == 'en' ? TextDirection.ltr : TextDirection.rtl;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final w = _cardSize.width, h = _cardSize.height;

  canvas.drawRect(
    Offset.zero & _cardSize,
    Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(w, h),
        [const Color(0xFF14B8A6), Palette.brandDark, const Color(0xFF134E5E)],
        [0, 0.55, 1],
      ),
  );

  // Faint number grid in the background: the game's look.
  final faint = Paint()..color = Colors.white.withValues(alpha: 0.05);
  for (var y = 0; y < 6; y++) {
    for (var x = 0; x < 5; x++) {
      if ((x + y) % 3 == 0) continue;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40 + x * 210.0, 40 + y * 220.0, 180, 180),
          const Radius.circular(28),
        ),
        faint,
      );
    }
  }

  // The middle block is measured first (draw = false) and shrunk by [scale]
  // when a tall script (Urdu Nastaliq) would run into the footer.
  var scale = 1.0;
  var draw = true;
  double paint(
    String text,
    double top, {
    required double size,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w700,
    double maxWidth = 920,
    String? family,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          // Roboto: Android's own font; elsewhere the system font stands in.
          fontFamily: family ?? lang.fontFamily ?? 'Roboto',
          fontSize: size * scale,
          fontWeight: weight,
          color: color,
          height: lang.lineHeight ?? 1.3,
          fontFamilyFallback: emojiFallback,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: dir,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    if (draw) p.paint(canvas, Offset((w - p.width) / 2, top));
    final height = p.height;
    p.dispose();
    return top + height;
  }

  // An equation of tiles, like the board: 7 + 5 = 12.
  const tiles = ['7', '+', '5', '=', '12'];
  const tile = 132.0, gap = 18.0;
  final rowWidth = tiles.length * tile + (tiles.length - 1) * gap;
  for (var i = 0; i < tiles.length; i++) {
    final op = i.isOdd;
    final rect = Rect.fromLTWH(
      (w - rowWidth) / 2 + i * (tile + gap),
      110,
      tile,
      tile,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      Paint()..color = op ? Colors.white.withValues(alpha: 0.12) : Colors.white,
    );
    final p = TextPainter(
      text: TextSpan(
        text: locale.n(tiles[i]),
        style: TextStyle(
          fontFamily: lang.numeralFontFamily ?? 'Roboto',
          fontSize: 64,
          fontWeight: FontWeight.w800,
          color: op ? _gold : _ink,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(canvas, rect.center - Offset(p.width / 2, p.height / 2));
    p.dispose();
  }

  // Title, brag line, stars, puzzle and stats; returns where it ends.
  double middle() {
    const top = 290.0;
    var y = paint(
      t.appTitle,
      top,
      size: 58,
      color: _gold,
      weight: FontWeight.w800,
    );
    y = paint(
      r.brag(lang.code),
      y + 70 * scale,
      size: 74,
      weight: FontWeight.w800,
    );

    y += 60 * scale;
    final star = 120.0 * scale, starGap = 36.0 * scale;
    final starsWidth = 3 * star + 2 * starGap;
    for (var i = 0; draw && i < 3; i++) {
      final center = Offset(
        (w - starsWidth) / 2 + star / 2 + i * (star + starGap),
        y + star / 2,
      );
      canvas.drawPath(
        _starPath(center, star / 2),
        Paint()
          ..color = i < r.stars ? _gold : Colors.white.withValues(alpha: 0.18),
      );
    }
    y += star + 60 * scale;

    y = paint(r.title(t, locale), y, size: 46, weight: FontWeight.w600);
    y = paint(
      r.stats(t, locale),
      y + 18 * scale,
      size: 44,
      weight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.85),
    );
    final streakLine = r.streakText(t, locale);
    if (streakLine != null) {
      y = paint(
        streakLine,
        y + 18 * scale,
        size: 44,
        color: const Color(0xFFFF9A5A),
      );
    }
    return y;
  }

  const footerTop = 1350.0 - 230;
  draw = false;
  final end = middle();
  if (end > footerTop - 40) scale = (footerTop - 40 - 290) / (end - 290);
  draw = true;
  middle();
  scale = 1;

  // Footer: the challenge and where to play.
  final link = FriendHints.siteFor(Uri.base).replaceFirst('https://', '');
  final footer = Paint()..color = Colors.white.withValues(alpha: 0.1);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(60, footerTop, w - 120, 170),
      const Radius.circular(36),
    ),
    footer,
  );
  paint(
    t.shareBeatMe,
    h - 212,
    size: 48,
    color: _gold,
    weight: FontWeight.w800,
  );
  paint(
    link,
    h - 132,
    size: 40,
    weight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.9),
  );

  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(w.toInt(), h.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  } finally {
    picture.dispose();
  }
}

Path _starPath(Offset c, double r) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? r : r * 0.45;
    final a = -math.pi / 2 + i * math.pi / 5;
    final p = c + Offset(math.cos(a) * radius, math.sin(a) * radius);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}
