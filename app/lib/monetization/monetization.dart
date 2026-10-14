import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_config.dart';
import 'ad_service.dart';

/// Coins (Amir, 2026-10-14): one coin buys one hint. Coins come from
/// friends opening the player's links (lib/rewards/friend_hints.dart) and,
/// where the build has an ad network, from rewarded ads the player chooses
/// to watch. The app is free: no other ads, nothing to buy.
///
/// Stored keys: `coins`, `coins/ads` ("yyyy-mm-dd:n", rewarded ads today).
/// No analytics, nothing about age.
class Monetization extends ChangeNotifier {
  final SharedPreferences _p;
  final AdService ads;
  final DateTime Function() now;
  bool _started = false;

  Monetization(this._p, {AdService? ads, this.now = DateTime.now})
    : ads = ads ?? NoAdService();

  static AdAudience audienceFor(BandConfig band) {
    final maxAge = band.maxAge;
    return AdAudience(
      teen: maxAge != null && maxAge < 18,
      underAgeOfConsent: maxAge != null && maxAge < 16,
    );
  }

  /// Starts consent + ads. Idempotent. Call after onboarding.
  Future<void> start(BandConfig band) async {
    if (_started) return;
    _started = true;
    await ads.start(audienceFor(band));
    notifyListeners();
  }

  Future<void> bandChanged(BandConfig band) =>
      ads.updateAudience(audienceFor(band));

  // --- Coins -----------------------------------------------------------------

  int get coins => _p.getInt('coins') ?? AdConfig.startingCoins;

  Future<void> addCoins(int n) async {
    await _p.setInt('coins', coins + n);
    notifyListeners();
  }

  /// Spends one coin; false if there are none.
  Future<bool> spendCoin() async {
    if (coins <= 0) return false;
    await _p.setInt('coins', coins - 1);
    notifyListeners();
    return true;
  }

  /// After a backup was merged into storage.
  void reload() => notifyListeners();

  // --- Rewarded ads ----------------------------------------------------------

  String get _today {
    final n = now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  /// Rewarded ads watched today.
  int get adsToday {
    final parts = (_p.getString('coins/ads') ?? '').split(':');
    return parts.length == 2 && parts[0] == _today
        ? int.tryParse(parts[1]) ?? 0
        : 0;
  }

  /// "Watch an ad for a coin" can be offered now.
  bool get canWatchAd =>
      ads.rewardedReady && adsToday < AdConfig.rewardedAdsPerDay;

  /// Shows a rewarded ad; adds [AdConfig.coinsPerAd] when it was watched.
  Future<bool> watchAdForCoin() async {
    if (!canWatchAd) return false;
    final earned = await ads.showRewarded();
    if (!earned) return false;
    await _p.setString('coins/ads', '$_today:${adsToday + 1}');
    await addCoins(AdConfig.coinsPerAd);
    return true;
  }
}
