import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../i18n/languages.dart';

/// Everything written on a certificate, already translated.
class CertificateTexts {
  final String certificate; // "CERTIFICATE"
  final String ofAchievement; // "OF ACHIEVEMENT"
  final String heading; // "30-Day Streak"
  final String presentedTo; // "PROUDLY PRESENTED TO"
  final String name;
  final String body; // "for solving the Daily Puzzle 30 days in a row."
  final String date;
  final String brand; // "Adadi"
  final String tagline; // "Adadi · Math crossword"
  final String site; // "adadi.espadna.com"
  final String medalYear; // "2026" (in the language's digits)

  const CertificateTexts({
    required this.certificate,
    required this.ofAchievement,
    required this.heading,
    required this.presentedTo,
    required this.name,
    required this.body,
    required this.date,
    required this.brand,
    required this.tagline,
    required this.site,
    required this.medalYear,
  });
}

/// The certificate: a 9:16 story picture (1080 x 1920), deep turquoise with
/// gold, a medal and the game's math signs (the look of Tiaro's, in Adadi's
/// colors).
class CertificatePainter extends CustomPainter {
  final CertificateTexts texts;
  final AppLanguage language;

  CertificatePainter(this.texts, this.language);

  static const size = Size(1080, 1920);

  static const _gold = Color(0xFFE9C46A);
  static const _goldLight = Color(0xFFF8E7B0);
  static const _goldDark = Color(0xFFB8862F);
  static const _white = Color(0xFFF7F3EA);

  @override
  void paint(Canvas canvas, Size box) {
    canvas.save();
    canvas.scale(box.width / size.width);
    _paint(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CertificatePainter old) =>
      old.texts != texts || old.language != language;

  /// The picture to share (PNG, 1080 x 1920).
  Future<Uint8List?> png() async {
    final recorder = ui.PictureRecorder();
    _paint(Canvas(recorder));
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data?.buffer.asUint8List();
    } finally {
      picture.dispose();
    }
  }

  void _paint(Canvas canvas) {
    final w = size.width, h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(w * 0.3, h),
          const [Color(0xFF128377), Color(0xFF0B504A), Color(0xFF062B29)],
          const [0, 0.55, 1],
        ),
    );

    // Faint math signs, the game's own pattern.
    const signs = ['+', '−', '×', '÷', '='];
    for (var y = 0; y < 9; y++) {
      for (var x = 0; x < 5; x++) {
        final p = TextPainter(
          text: TextSpan(
            text: signs[(x * 2 + y) % signs.length],
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 90,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.035),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        p.paint(
          canvas,
          Offset(70 + x * 220.0 + (y.isOdd ? 110 : 0), 560 + y * 150.0),
        );
        p.dispose();
      }
    }

    // Gold corners over darker bands: top left and bottom right.
    void corner(bool top) {
      Path tri(double a) => top
          ? (Path()
              ..moveTo(0, 0)
              ..lineTo(a, 0)
              ..lineTo(0, a)
              ..close())
          : (Path()
              ..moveTo(w, h)
              ..lineTo(w - a, h)
              ..lineTo(w, h - a)
              ..close());
      canvas.drawPath(tri(560), Paint()..color = const Color(0xFF07332F));
      canvas.drawPath(
        tri(470),
        Paint()..color = const Color(0xFF0D615A).withValues(alpha: 0.9),
      );
      canvas.drawPath(
        tri(380),
        Paint()
          ..shader = ui.Gradient.linear(
            top ? Offset.zero : Offset(w, h),
            top ? const Offset(380, 380) : Offset(w - 380, h - 380),
            const [_goldLight, _gold, _goldDark],
            const [0, 0.45, 1],
          ),
      );
    }

    corner(true);
    corner(false);

    // Gold dots, bottom left.
    final dot = Paint()..color = _gold.withValues(alpha: 0.55);
    for (var y = 0; y < 5; y++) {
      for (var x = 0; x < 5; x++) {
        canvas.drawCircle(Offset(110 + x * 30.0, h - 330 + y * 30.0), 4, dot);
      }
    }

    // Frame.
    canvas.drawRect(
      const Rect.fromLTWH(46, 46, 1080 - 92, 1920 - 92),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _gold.withValues(alpha: 0.7),
    );
    canvas.drawRect(
      const Rect.fromLTWH(62, 62, 1080 - 124, 1920 - 124),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _gold.withValues(alpha: 0.35),
    );

    _medal(canvas, const Offset(800, 330));

    // An equation tile on the top-left gold, the game's sign.
    _tile(canvas, const Offset(120, 112), '7+5');

    // The middle block is measured first and shrunk when a tall script
    // (Urdu Nastaliq) would run into the signature.
    const top = 640.0, bottom = 1920 - 400.0;
    _scale = 1;
    _draw = false;
    final end = _middle(canvas);
    if (end > bottom) _scale = (bottom - top) / (end - top);
    _draw = true;
    _middle(canvas);
    _scale = 1;

    // Signature and footer.
    const sigY = 1920 - 360.0;
    final sig = _text(
      canvas,
      texts.brand,
      sigY,
      size: 64,
      weight: FontWeight.w900,
      color: _goldLight,
      x: 760,
      maxWidth: 360,
    );
    canvas.drawLine(
      Offset(620, sig + 8),
      Offset(900, sig + 8),
      Paint()
        ..color = _gold.withValues(alpha: 0.8)
        ..strokeWidth = 2,
    );
    _text(
      canvas,
      texts.tagline,
      sig + 22,
      size: 28,
      weight: FontWeight.w600,
      color: _white.withValues(alpha: 0.8),
      x: 760,
      maxWidth: 420,
    );
    _text(
      canvas,
      texts.site,
      1920 - 140,
      size: 32,
      weight: FontWeight.w600,
      color: _white.withValues(alpha: 0.85),
      family: 'Roboto',
      dir: TextDirection.ltr,
    );
  }

  double _scale = 1;
  bool _draw = true;

  /// Title, heading, name, line and date; returns where it ends.
  double _middle(Canvas canvas) {
    const w = 1080.0;
    final latin = language.code == 'en';
    var y = 640.0;
    y = _text(
      canvas,
      texts.certificate,
      y,
      size: 96,
      weight: FontWeight.w900,
      spacing: latin ? 10 : 0,
      color: _white,
    );
    y = _text(
      canvas,
      texts.ofAchievement,
      y + 6 * _scale,
      size: 40,
      weight: FontWeight.w700,
      spacing: latin ? 8 : 0,
      color: _gold,
    );
    y = _text(
      canvas,
      texts.heading,
      y + 60 * _scale,
      size: 70,
      weight: FontWeight.w800,
      color: _gold,
    );
    y = _text(
      canvas,
      texts.presentedTo,
      y + 70 * _scale,
      size: 32,
      weight: FontWeight.w600,
      spacing: latin ? 5 : 0,
      color: _white.withValues(alpha: 0.75),
    );
    y = _text(
      canvas,
      texts.name,
      y + 26 * _scale,
      size: 92,
      weight: FontWeight.w800,
      color: _white,
      maxLines: 2,
    );
    y += 30 * _scale;
    if (_draw) {
      canvas.drawLine(
        Offset(w / 2 - 230, y),
        Offset(w / 2 + 230, y),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(w / 2 - 230, y),
            Offset(w / 2 + 230, y),
            [_gold.withValues(alpha: 0), _gold, _gold.withValues(alpha: 0)],
            const [0, 0.5, 1],
          )
          ..strokeWidth = 4,
      );
    }
    y = _text(
      canvas,
      texts.body,
      y + 40 * _scale,
      size: 42,
      weight: FontWeight.w500,
      color: _white.withValues(alpha: 0.9),
      maxLines: 4,
      maxWidth: 820,
    );
    return _text(
      canvas,
      texts.date,
      y + 30 * _scale,
      size: 36,
      weight: FontWeight.w700,
      color: _gold,
    );
  }

  /// Centered text (around [x], default the middle); returns where it ends.
  double _text(
    Canvas canvas,
    String text,
    double top, {
    required double size,
    required FontWeight weight,
    required Color color,
    double spacing = 0,
    int maxLines = 2,
    double maxWidth = 900,
    double? x,
    String? family,
    TextDirection? dir,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: family ?? language.fontFamily ?? 'Roboto',
          fontSize: size * _scale,
          fontWeight: weight,
          color: color,
          letterSpacing: spacing,
          height: language.lineHeight ?? 1.25,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection:
          dir ??
          (language.code == 'en' ? TextDirection.ltr : TextDirection.rtl),
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    final cx = x ?? CertificatePainter.size.width / 2;
    if (_draw) p.paint(canvas, Offset(cx - p.width / 2, top));
    final end = top + p.height;
    p.dispose();
    return end;
  }

  void _tile(Canvas canvas, Offset at, String text) {
    final rect = at & const Size(150, 96);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()..color = const Color(0xFF0B504A),
    );
    final p = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 50,
          fontWeight: FontWeight.w800,
          color: _goldLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(canvas, rect.center - Offset(p.width / 2, p.height / 2));
    p.dispose();
  }

  void _medal(Canvas canvas, Offset c) {
    // Ribbons.
    for (final side in [-1.0, 1.0]) {
      final path = Path()
        ..moveTo(c.dx + side * 30, c.dy + 40)
        ..lineTo(c.dx + side * 110, c.dy + 250)
        ..lineTo(c.dx + side * 70, c.dy + 225)
        ..lineTo(c.dx + side * 45, c.dy + 270)
        ..lineTo(c.dx + side * -20, c.dy + 60)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFF14B8A6));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = _gold,
      );
    }
    // Laurel: two arcs of leaves.
    final leaf = Paint()..color = _gold.withValues(alpha: 0.9);
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < 9; i++) {
        final a = math.pi / 2 + side * (0.35 + i * 0.27);
        final p = c + Offset(math.cos(a) * 165, math.sin(a) * 165);
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(a + side * math.pi / 2);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 22, height: 44),
          leaf,
        );
        canvas.restore();
      }
    }
    canvas.drawCircle(
      c,
      140,
      Paint()
        ..shader = ui.Gradient.radial(
          c - const Offset(40, 40),
          200,
          const [_goldLight, _gold, _goldDark],
          const [0, 0.5, 1],
        ),
    );
    canvas.drawCircle(
      c,
      116,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = _goldDark,
    );
    canvas.drawCircle(c, 104, Paint()..color = const Color(0xFF0E6F66));
    void line(String text, double dy, double size, Color color) {
      final p = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: language.fontFamily ?? 'Roboto',
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: language.code == 'en' ? 3 : 0,
            height: 1.1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 190);
      p.paint(canvas, c + Offset(-p.width / 2, dy - p.height / 2));
      p.dispose();
    }

    line(texts.brand.toUpperCase(), -48, 34, _goldLight);
    line(texts.medalYear, 4, 52, _white);
    // Three small stars under the year (drawn: not every font has ★).
    for (var i = -1; i <= 1; i++) {
      final path = Path();
      final center = c + Offset(i * 30.0, 56);
      for (var k = 0; k < 10; k++) {
        final r = k.isEven ? 12.0 : 5.0;
        final a = -math.pi / 2 + k * math.pi / 5;
        final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), Paint()..color = _gold);
    }
  }
}
