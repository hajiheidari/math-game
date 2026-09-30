import 'package:flutter/foundation.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_config.dart';
import 'ad_service.dart';
import 'purchase_service.dart';

/// Coins, ad pacing and the "Remove ads" unlock. Local only.
///
/// Stored keys: `coins`, `adsRemoved`, `stats/levelsWon`,
/// `stats/sinceInterstitial`. No analytics, nothing about age.
class Monetization extends ChangeNotifier {
  final SharedPreferences _p;
  final AdService ads;
  final PurchaseService purchases;
  bool _started = false;

  Monetization(this._p, {AdService? ads, PurchaseService? purchases})
    : ads = ads ?? NoAdService(),
      purchases = purchases ?? NoPurchaseService() {
    this.purchases.onRemoveAdsOwned = _markAdsRemoved;
  }

  static AdAudience audienceFor(BandConfig band) {
    final maxAge = band.maxAge;
    return AdAudience(
      teen: maxAge != null && maxAge < 18,
      underAgeOfConsent: maxAge != null && maxAge < 16,
    );
  }

  /// Starts consent + ads + store. Idempotent. Call after onboarding.
  Future<void> start(BandConfig band) async {
    if (_started) return;
    _started = true;
    await purchases.start();
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

  // --- Remove ads ------------------------------------------------------------

  bool get adsRemoved => _p.getBool('adsRemoved') ?? false;

  void _markAdsRemoved() {
    if (adsRemoved) return;
    _p.setBool('adsRemoved', true);
    notifyListeners();
  }

  // --- Interstitial pacing ---------------------------------------------------

  int get levelsWon => _p.getInt('stats/levelsWon') ?? 0;
  int get _sinceInterstitial => _p.getInt('stats/sinceInterstitial') ?? 0;

  /// Call after every won level (Levels mode).
  Future<void> onLevelWon() async {
    await _p.setInt('stats/levelsWon', levelsWon + 1);
    await _p.setInt('stats/sinceInterstitial', _sinceInterstitial + 1);
  }

  bool get interstitialIsDue => interstitialDue(
    levelsWon: levelsWon,
    levelsSinceLast: _sinceInterstitial,
    adsRemoved: adsRemoved,
  );

  /// Shows an interstitial between levels if the pacing rule allows it.
  Future<void> maybeShowInterstitial() async {
    if (!interstitialIsDue) return;
    await _p.setInt('stats/sinceInterstitial', 0);
    await ads.showInterstitial();
  }
}
