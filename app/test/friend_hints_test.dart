import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:numcross/monetization/monetization.dart';
import 'package:numcross/rewards/friend_hints.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late Monetization money;
  final requests = <http.Request>[];
  var day = DateTime(2026, 10, 10, 9);
  var pending = 0;

  FriendHints hints() => FriendHints(
    prefs,
    money,
    now: () => day,
    client: MockClient((req) async {
      requests.add(req);
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      if (req.url.path == '/api/claim') {
        final n = pending < (body['max'] as int) ? pending : body['max'] as int;
        pending -= n;
        return http.Response(jsonEncode({'granted': n}), 200);
      }
      return http.Response(jsonEncode({'counted': true}), 200);
    }),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    money = Monetization(prefs);
    requests.clear();
    day = DateTime(2026, 10, 10, 9);
    pending = 0;
  });

  test('invite code: stable, 10 characters, derived from the secret', () {
    final h = hints();
    expect(FriendHints.validCode(h.code), isTrue);
    expect(hints().code, h.code, reason: 'saved, not regenerated');
    // Same derivation as site/worker.js (codeFor).
    expect(FriendHints.codeFor('test-secret-0123456789'), 'yp6gtamart');
    expect(
      h.link(Uri.parse('https://adadi.espadna.com/')),
      'https://adadi.espadna.com/?r=${h.code}',
    );
  });

  test('claim: hints arrive, at most 3 a day, the rest waits', () async {
    final h = hints();
    pending = 5;
    expect(await h.claim(), 3);
    expect(money.coins, 3);
    expect(h.earnedToday, 3);
    expect(h.leftToday, 0);
    expect(await h.claim(force: true), 0, reason: 'daily limit');
    expect(pending, 2, reason: 'kept on the server');

    day = DateTime(2026, 10, 11, 9);
    expect(h.leftToday, 3);
    expect(await h.claim(force: true), 2);
    expect(money.coins, 5);
  });

  test('claim sends the secret, never the public code', () async {
    final h = hints();
    await h.claim();
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(FriendHints.codeFor(body['s'] as String), h.code);
    expect(body['max'], 3);
  });

  test('offline: no hints, no crash', () async {
    final h = FriendHints(
      prefs,
      money,
      client: MockClient((_) async => throw Exception('offline')),
    );
    expect(await h.claim(), 0);
    expect(money.coins, 0);
  });

  test(
    'web visit from a friend link: reported once a day, never our own',
    () async {
      final h = hints();
      await h.reportVisit(Uri.parse('https://adadi.espadna.com/?r=${h.code}'));
      expect(requests, isEmpty, reason: 'own link');
      await h.reportVisit(Uri.parse('https://adadi.espadna.com/?r=bad'));
      expect(requests, isEmpty, reason: 'not a code');

      final friend = Uri.parse('https://adadi.espadna.com/?r=abcdefghjk');
      await h.reportVisit(friend);
      await h.reportVisit(friend);
      expect(requests.length, 1);
      final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
      expect(body, {'r': 'abcdefghjk', 'd': h.code});
    },
  );
}
