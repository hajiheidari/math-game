import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/progress_store.dart';

/// Milestones that earn a certificate to share as a story (Amir, 2026-10-14,
/// like Tiaro). Each is earned once.
enum CertKind {
  streak7(7),
  streak30(30),
  streak100(100),
  levels25(25),
  levels100(100),
  levels250(250),
  expert10(10),
  allDaily(4);

  /// The number in the milestone (days, levels).
  final int goal;
  const CertKind(this.goal);
}

class Cert {
  final CertKind kind;

  /// When it was earned (local date).
  final DateTime date;
  const Cert(this.kind, this.date);

  Map<String, Object?> toJson() => {
    'k': kind.name,
    'd': ProgressStore.dateKey(date),
  };

  static Cert? fromJson(Map<String, Object?> j) {
    final kind = CertKind.values.asNameMap()[j['k']];
    final date = DateTime.tryParse('${j['d']}');
    return kind == null || date == null ? null : Cert(kind, date);
  }
}

/// Where the player stands on each milestone, read from their progress.
class Milestones {
  final int bestStreak;

  /// Levels completed in every band and difficulty.
  final int levels;
  final int expertLevels;

  /// Most daily puzzles solved on one day (out of the 4 difficulties).
  final int mostDailiesInADay;

  const Milestones({
    required this.bestStreak,
    required this.levels,
    required this.expertLevels,
    required this.mostDailiesInADay,
  });

  factory Milestones.of(ProgressStore p) {
    var levels = 0, expert = 0;
    for (final band in kBands) {
      for (final d in Difficulty.values) {
        final n = p.of(band.id, d).completed;
        levels += n;
        if (d == Difficulty.expert) expert += n;
      }
    }
    return Milestones(
      bestStreak: p.bestStreak(),
      levels: levels,
      expertLevels: expert,
      mostDailiesInADay: p.mostDailiesInADay(),
    );
  }

  int progress(CertKind k) => switch (k) {
    CertKind.streak7 || CertKind.streak30 || CertKind.streak100 => bestStreak,
    CertKind.levels25 || CertKind.levels100 || CertKind.levels250 => levels,
    CertKind.expert10 => expertLevels,
    CertKind.allDaily => mostDailiesInADay,
  };

  bool reached(CertKind k) => progress(k) >= k.goal;
}

/// The player's certificates. Stored keys: `certs` (JSON list), `certs/new`
/// (earned but not opened yet), `certs/name` (the name printed on them).
class Certificates extends ChangeNotifier {
  final SharedPreferences _p;
  final ProgressStore progress;
  final DateTime Function() now;

  Certificates(this._p, this.progress, {this.now = DateTime.now});

  List<Cert> get earned {
    try {
      return [
        for (final e in jsonDecode(_p.getString('certs') ?? '[]') as List)
          ?Cert.fromJson(e as Map<String, Object?>),
      ];
    } on Object {
      return [];
    }
  }

  Cert? of(CertKind k) => earned.where((c) => c.kind == k).firstOrNull;

  int get unseen => _p.getInt('certs/new') ?? 0;

  Future<void> markSeen() async {
    if (unseen == 0) return;
    await _p.setInt('certs/new', 0);
    notifyListeners();
  }

  /// Name on the certificates (optional, never leaves the device except in
  /// the backup and the pictures the player shares).
  String get name => _p.getString('certs/name') ?? '';

  Future<void> setName(String value) async {
    final clean = value.replaceAll(RegExp(r'[\x00-\x1F]'), '').trim();
    await _p.setString(
      'certs/name',
      clean.length > 24 ? clean.substring(0, 24) : clean,
    );
    notifyListeners();
  }

  /// Checks the milestones; returns the certificates earned just now.
  Future<List<Cert>> check() async {
    final m = Milestones.of(progress);
    final have = {for (final c in earned) c.kind};
    final n = now();
    final fresh = [
      for (final k in CertKind.values)
        if (!have.contains(k) && m.reached(k))
          Cert(k, DateTime(n.year, n.month, n.day)),
    ];
    if (fresh.isEmpty) return fresh;
    await _p.setString(
      'certs',
      jsonEncode([
        for (final c in [...earned, ...fresh]) c.toJson(),
      ]),
    );
    await _p.setInt('certs/new', unseen + fresh.length);
    notifyListeners();
    return fresh;
  }

  /// After a backup was merged in.
  void reload() => notifyListeners();
}
