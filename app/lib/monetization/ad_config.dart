import 'package:flutter/foundation.dart';

import '../store.dart';

/// AdMob ids. These are Google's public TEST ids — replace them with the
/// real app/unit ids from the AdMob console before release (see
/// docs/RELEASE_CHECKLIST.md). The app ids also live in AndroidManifest.xml
/// and ios/Runner/Info.plist.
class AdConfig {
  static String get rewardedUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  static String get interstitialUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  /// Brief: never an interstitial during the first 3 completed levels...
  static const int freeLevels = 3;

  /// ...and at most one every 3 completed levels after that.
  static const int levelsBetweenInterstitials = 3;

  /// Coins a new player starts with, and what wins earn.
  static const int startingCoins = 3;
  static const int coinsPerLevel = 1;
  static const int coinsPerDaily = 2;
}

/// Store product id of the one-time "Remove ads" purchase. Create it as a
/// non-consumable in App Store Connect and Google Play Console.
const String kRemoveAdsProductId = 'remove_ads';

/// Privacy policy shown from Settings: docs/privacy/index.html, published by
/// site/build.sh (Iranian mirror: adadi.espadna.ir/privacy/).
/// The Cafe Bazaar build opens the Persian section.
const String kPrivacyPolicyUrl = kStore == StoreTarget.bazaar
    ? 'https://adadi.espadna.com/privacy/#fa'
    : 'https://adadi.espadna.com/privacy/';

/// Whether an interstitial is due after a level win (pure rule, tested).
bool interstitialDue({
  required int levelsWon,
  required int levelsSinceLast,
  required bool adsRemoved,
}) =>
    !adsRemoved &&
    levelsWon > AdConfig.freeLevels &&
    levelsSinceLast >= AdConfig.levelsBetweenInterstitials;
