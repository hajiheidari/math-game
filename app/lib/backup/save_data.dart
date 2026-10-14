import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The player's save: every stored key that belongs to the game, as plain
/// JSON values (String, int, bool, double, `List<String>`). Used by the
/// recovery-code backup (server) and the iCloud copy.
///
/// Left out: the backup's own bookkeeping, the under-13 block, and per-device
/// bits (`ref/visited`).
class SaveData {
  final Map<String, Object> values;

  /// The install that wrote this save (its own copy needs no merging).
  final String? device;

  /// The recovery code it is kept under on the server (iCloud copy only).
  final String? key;

  const SaveData(this.values, {this.device, this.key});

  static const _skipPrefixes = ['backup/'];
  static const _skipKeys = {'blocked', 'ref/visited'};

  static bool keeps(String key) =>
      !_skipKeys.contains(key) && !_skipPrefixes.any(key.startsWith);

  factory SaveData.read(SharedPreferences p) => SaveData({
    for (final k in p.getKeys())
      if (keeps(k))
        if (p.get(k) case final Object v) k: v,
  });

  /// Whether there is anything worth keeping (levels, dailies, coins...).
  bool get hasProgress => values.keys.any(
    (k) =>
        k.startsWith('progress/') ||
        k == 'daily' ||
        k == 'certs' ||
        (k == 'coins' && (values[k] as num) > 0),
  );

  String encode({String? device, String? key}) =>
      jsonEncode({'v': 1, 'device': ?device, 'key': ?key, 'data': values});

  /// Null when [text] is not a save.
  static SaveData? decode(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final json = jsonDecode(text) as Map<String, Object?>;
      final data = json['data'] as Map<String, Object?>;
      return SaveData(
        {
          for (final MapEntry(:key, :value) in data.entries)
            if (keeps(key) && value != null)
              key: value is List ? value.map((e) => '$e').toList() : value,
        },
        device: json['device'] as String?,
        key: json['key'] as String?,
      );
    } on Object {
      return null;
    }
  }

  /// Writes every value into [p] (the merge result: see [merge]).
  Future<void> writeTo(SharedPreferences p) async {
    for (final MapEntry(:key, :value) in values.entries) {
      if (p.get(key) == value) continue;
      switch (value) {
        case final String v:
          await p.setString(key, v);
        case final bool v:
          await p.setBool(key, v);
        case final int v:
          await p.setInt(key, v);
        case final double v:
          await p.setDouble(key, v);
        case final List<String> v:
          await p.setStringList(key, v);
      }
    }
  }
}

/// Two saves of the same player meet (another phone, a reinstall, a
/// recovery code): keep the best of each, never lose anything (Amir,
/// 2026-10-12). More levels and stars, every solved daily, the larger coin
/// count, every certificate. Unfinished games and settings: this device's,
/// else the other's. The invite code: [other]'s when [adoptIdentity] (a
/// recovery code was entered), so friends' coins keep reaching the player.
SaveData merge(SaveData mine, SaveData other, {bool adoptIdentity = false}) {
  final out = Map<String, Object>.of(other.values)..addAll(mine.values);
  for (final key in {...mine.values.keys, ...other.values.keys}) {
    final a = mine.values[key], b = other.values[key];
    if (a == null || b == null) continue;
    if (key.startsWith('progress/')) {
      out[key] = _bestStars('$a', '$b');
    } else if (key == 'daily') {
      out[key] = _unionDaily('$a', '$b');
    } else if (key == 'certs') {
      out[key] = _unionCerts('$a', '$b');
    } else if (key == 'coins' && a is num && b is num) {
      out[key] = a > b ? a : b;
    } else if (key == 'ref/secret' || key == 'ref/earned') {
      if (adoptIdentity) out[key] = b;
    }
  }
  return SaveData(out);
}

/// Best stars per level ("3321" + "23" = "3321"; longer list wins levels).
String _bestStars(String a, String b) {
  final long = a.length >= b.length ? a : b, short = long == a ? b : a;
  return String.fromCharCodes([
    for (var i = 0; i < long.length; i++)
      i < short.length && short.codeUnitAt(i) > long.codeUnitAt(i)
          ? short.codeUnitAt(i)
          : long.codeUnitAt(i),
  ]);
}

String _unionDaily(String a, String b) {
  Map<String, int> read(String s) {
    try {
      return (jsonDecode(s) as Map<String, Object?>).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      );
    } on Object {
      return {};
    }
  }

  final out = read(a);
  for (final MapEntry(:key, :value) in read(b).entries) {
    out[key] = (out[key] ?? 0) | value;
  }
  return jsonEncode(
    Map.fromEntries(
      out.entries.toList()..sort((x, y) => x.key.compareTo(y.key)),
    ),
  );
}

String _unionCerts(String a, String b) {
  List<Map<String, Object?>> read(String s) {
    try {
      return [for (final e in jsonDecode(s) as List) e as Map<String, Object?>];
    } on Object {
      return [];
    }
  }

  final seen = <String>{};
  return jsonEncode([
    for (final c in [...read(a), ...read(b)])
      if (seen.add('${c['k']}')) c,
  ]);
}
