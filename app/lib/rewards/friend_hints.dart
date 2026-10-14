import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../monetization/monetization.dart';
import '../store.dart';

/// Hints come only from friends (Amir, 2026-10-10): every link the player
/// shares (an invite or a result) carries their invite code, and when a friend
/// opens it the server (site/worker.js) credits the player with one hint, at
/// most [dailyMax] a day.
///
/// The phone cannot see who a message went to, so repeats are caught where
/// the friend opens the link: one friend (device, and IP address) counts at
/// most once a day per player, however many times the link was sent to them.
///
/// Stored keys: `ref/secret` (random, never shared; the public invite code is
/// derived from it so nobody else can collect the player's hints),
/// `ref/earned` ("yyyy-mm-dd:n", hints received today), `ref/visited`
/// ("yyyy-mm-dd:code", web: the last friend link reported).
class FriendHints extends ChangeNotifier {
  static const dailyMax = 3;
  static const api = 'https://adadi.espadna.com/api';

  final SharedPreferences _p;
  final Monetization money;
  final http.Client _http;
  final DateTime Function() now;

  FriendHints(
    this._p,
    this.money, {
    http.Client? client,
    this.now = DateTime.now,
  }) : _http = client ?? http.Client();

  // --- Invite code -----------------------------------------------------------

  String get _secret {
    final saved = _p.getString('ref/secret');
    if (saved != null) return saved;
    final r = Random.secure();
    final s = base64Url.encode([for (var i = 0; i < 24; i++) r.nextInt(256)]);
    _p.setString('ref/secret', s);
    return s;
  }

  /// Public invite code: 10 characters of sha256(secret) (the server
  /// computes the same, see site/worker.js).
  String get code => codeFor(_secret);

  static String codeFor(String secret) {
    const alphabet = 'abcdefghijkmnpqrstuvwxyz23456789';
    final bytes = sha256.convert(utf8.encode(secret)).bytes;
    return String.fromCharCodes([
      for (var i = 0; i < 10; i++) alphabet.codeUnitAt(bytes[i] % 32),
    ]);
  }

  static bool validCode(String? c) =>
      c != null && RegExp(r'^[a-z2-9]{10}$').hasMatch(c);

  /// Where a friend plays: the web game, Iranian copy for the Bazaar build
  /// and the .ir site (it opens in Persian there).
  static String siteFor(Uri page) =>
      kStore == StoreTarget.bazaar || (kIsWeb && page.host.endsWith('.ir'))
      ? 'https://adadi.espadna.ir'
      : 'https://adadi.espadna.com';

  /// The player's link: the web game with their invite code.
  String link(Uri page) => '${siteFor(page)}/?r=$code';

  // --- Daily count -------------------------------------------------------------

  String get _today {
    final n = now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  /// Hints received from friends today.
  int get earnedToday {
    final raw = _p.getString('ref/earned') ?? '';
    final parts = raw.split(':');
    return parts.length == 2 && parts[0] == _today
        ? int.tryParse(parts[1]) ?? 0
        : 0;
  }

  int get leftToday => max(0, dailyMax - earnedToday);

  /// After a backup was merged into storage (the invite code may change).
  void reload() => notifyListeners();

  // --- Server ------------------------------------------------------------------

  DateTime? _lastClaim;
  Future<int>? _claiming;

  /// Collects hints friends have earned the player since the last call
  /// (up to today's limit; the rest waits on the server for later days).
  /// Returns how many were added. Quiet when offline.
  Future<int> claim({bool force = false}) {
    if (leftToday == 0) return Future.value(0);
    final last = _lastClaim;
    if (!force &&
        last != null &&
        now().difference(last) < const Duration(seconds: 20)) {
      return Future.value(0);
    }
    return _claiming ??= _claim().whenComplete(() => _claiming = null);
  }

  Future<int> _claim() async {
    _lastClaim = now();
    try {
      final res = await _http
          .post(
            Uri.parse('$api/claim'),
            // text/plain: no CORS preflight from the web game.
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode({'s': _secret, 'max': leftToday}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return 0;
      final granted = (jsonDecode(res.body)['granted'] as num?)?.toInt() ?? 0;
      final n = granted.clamp(0, leftToday);
      if (n == 0) return 0;
      await _p.setString('ref/earned', '$_today:${earnedToday + n}');
      await money.addCoins(n);
      notifyListeners();
      return n;
    } catch (e) {
      debugPrint('friend hints: $e');
      return 0;
    }
  }

  /// Web: this visit came from a friend's link (`?r=code`): tell the server,
  /// so the friend gets a hint. Our own code identifies this device.
  Future<void> reportVisit(Uri page) async {
    final from = page.queryParameters['r'];
    if (!validCode(from) || from == code) return;
    final mark = '$_today:$from';
    if (_p.getString('ref/visited') == mark) return;
    try {
      final res = await _http
          .post(
            Uri.parse('$api/visit'),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode({'r': from, 'd': code}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) await _p.setString('ref/visited', mark);
    } catch (e) {
      debugPrint('friend visit: $e');
    }
  }
}
