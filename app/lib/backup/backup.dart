import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../rewards/friend_hints.dart';
import 'cloud_save.dart';
import 'save_data.dart';

enum RestoreResult { done, badCode, notFound, offline }

/// Never lose a player's progress, without any sign-up (Amir, 2026-10-12):
/// - a recovery code (Settings → Backup): the save is kept on our server
///   (site/worker.js) under a secret 12-character code; entering it on
///   another phone or the web brings everything back;
/// - iPhone / iPad: a copy in iCloud ([CloudSave]), restored by itself after
///   a reinstall or on the player's other Apple device;
/// - Android: Google's Auto Backup of the app data (no code here).
/// Saves that meet are merged, best of each ([merge]).
///
/// Stored keys: `backup/key` (the recovery code), `backup/device` (random id
/// of this install), `backup/at` (last upload, ms since epoch).
class Backup extends ChangeNotifier {
  static const api = FriendHints.api;

  /// The server copy is refreshed at most this often, except when forced
  /// (a daily puzzle won, Settings opened).
  static const every = Duration(hours: 3);

  static const _alphabet = 'abcdefghijkmnpqrstuvwxyz23456789';

  final SharedPreferences _p;
  final http.Client _http;
  final CloudSave cloud;
  final DateTime Function() now;

  /// Called after another save was merged in (stores re-read their data).
  final VoidCallback onRestored;

  Backup(
    this._p, {
    http.Client? client,
    this.cloud = const CloudSave(),
    this.now = DateTime.now,
    required this.onRestored,
  }) : _http = client ?? http.Client();

  /// The recovery code, once the first backup was made.
  String? get key => _p.getString('backup/key');

  String get _device {
    final saved = _p.getString('backup/device');
    if (saved != null) return saved;
    final id = _random(10);
    _p.setString('backup/device', id);
    return id;
  }

  static String _random(int n) {
    final r = Random.secure();
    return String.fromCharCodes([
      for (var i = 0; i < n; i++) _alphabet.codeUnitAt(r.nextInt(32)),
    ]);
  }

  /// "ABCD-EFGH-JKMN".
  static String format(String key) => [
    for (var i = 0; i < key.length; i += 4)
      key.substring(i, min(i + 4, key.length)),
  ].join('-').toUpperCase();

  /// The code as typed (any case, dashes, spaces, Persian or Arabic digits);
  /// null unless it is 12 valid characters.
  static String? parse(String input) {
    final latin = StringBuffer();
    for (final c in input.toLowerCase().runes) {
      if (c >= 0x06F0 && c <= 0x06F9) {
        latin.writeCharCode(0x30 + c - 0x06F0);
      } else if (c >= 0x0660 && c <= 0x0669) {
        latin.writeCharCode(0x30 + c - 0x0660);
      } else if (_alphabet.contains(String.fromCharCode(c))) {
        latin.writeCharCode(c);
      } else if (RegExp(r'[a-z0-9]').hasMatch(String.fromCharCode(c))) {
        return null; // a letter that is never in a code (l, o, 0, 1)
      }
    }
    final key = latin.toString();
    return key.length == 12 ? key : null;
  }

  Future<Map<String, Object?>?> _post(String path, Object body) async {
    final res = await _http
        .post(
          Uri.parse('$api/$path'),
          // text/plain: no CORS preflight from the web game.
          headers: {'Content-Type': 'text/plain'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 404) return const {};
    if (res.statusCode != 200) throw http.ClientException('${res.statusCode}');
    return jsonDecode(res.body) as Map<String, Object?>;
  }

  // --- iCloud ------------------------------------------------------------------

  /// At launch (iPhone / iPad): a save in iCloud written by another install
  /// (this one before a reinstall, or the player's other device) is merged
  /// in. True if something was merged.
  Future<bool> restoreFromCloud() async {
    final saved = SaveData.decode(await cloud.read());
    if (saved == null || saved.device == _device) return false;
    final mine = SaveData.read(_p);
    // A fresh install takes the saved identity (invite code) too.
    await merge(mine, saved, adoptIdentity: !mine.hasProgress).writeTo(_p);
    if (key == null && saved.key != null) {
      await _p.setString('backup/key', saved.key!);
    }
    onRestored();
    notifyListeners();
    unawaited(_writeCloud());
    return true;
  }

  Future<void> _writeCloud() =>
      cloud.write(SaveData.read(_p).encode(device: _device, key: key));

  // --- Server ------------------------------------------------------------------

  Future<void>? _syncing;

  /// Uploads the save (and refreshes the iCloud copy). An empty install
  /// uploads nothing unless [force]d, so it never replaces a real backup.
  /// Quiet when offline.
  Future<void> sync({bool force = false}) {
    unawaited(_writeCloud());
    final last = _p.getInt('backup/at');
    if (!force &&
        last != null &&
        now().millisecondsSinceEpoch - last < every.inMilliseconds) {
      return Future.value();
    }
    return _syncing ??= _sync(force).whenComplete(() => _syncing = null);
  }

  Future<void> _sync(bool force) async {
    if (!force && !SaveData.read(_p).hasProgress) return;
    try {
      var k = key;
      if (k != null) {
        // Another device saved under this code since: merge it first.
        final res = await _post('backup/load', {'k': k});
        final theirs = SaveData.decode(res?['d'] as String?);
        if (theirs != null && theirs.device != _device) {
          await merge(SaveData.read(_p), theirs).writeTo(_p);
          onRestored();
        }
      } else {
        k = _random(12);
      }
      final save = SaveData.read(_p).encode(device: _device);
      await _post('backup/save', {'k': k, 'd': save});
      await _p.setString('backup/key', k);
      await _p.setInt('backup/at', now().millisecondsSinceEpoch);
      notifyListeners();
      unawaited(_writeCloud());
    } on Object catch (e) {
      debugPrint('backup: $e');
    }
  }

  /// Settings → "Restore from a code": merges that backup into this device
  /// (nothing here is lost) and keeps saving under that code from now on.
  Future<RestoreResult> restore(String input) async {
    final k = parse(input);
    if (k == null) return RestoreResult.badCode;
    try {
      final res = await _post('backup/load', {'k': k});
      final theirs = SaveData.decode(res?['d'] as String?);
      if (theirs == null) return RestoreResult.notFound;
      await merge(SaveData.read(_p), theirs, adoptIdentity: true).writeTo(_p);
      await _p.setString('backup/key', k);
      await _p.remove('backup/at');
      onRestored();
      notifyListeners();
      await sync(force: true);
      return RestoreResult.done;
    } on Object catch (e) {
      debugPrint('restore: $e');
      return RestoreResult.offline;
    }
  }
}
