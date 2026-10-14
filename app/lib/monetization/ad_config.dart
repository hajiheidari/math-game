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

  /// Hints a new player starts with. Wins earn none: coins come from
  /// friends and rewarded ads (Amir, 2026-10-14).
  static const int startingCoins = 0;

  /// Coins for one rewarded ad, and how many ads pay in a day.
  static const int coinsPerAd = 1;
  static const int rewardedAdsPerDay = 5;
}

/// Privacy policy shown from Settings: docs/privacy/index.html, published by
/// site/build.sh (Iranian mirror: adadi.espadna.ir/privacy/).
/// Support address shared by every Espadna app (Settings → Contact support,
/// store listings, privacy policy).
const String kSupportEmail = 'espadna.support@gmail.com';

/// The Cafe Bazaar build opens the Persian section.
const String kPrivacyPolicyUrl = kStore == StoreTarget.bazaar
    ? 'https://adadi.espadna.com/privacy/#fa'
    : 'https://adadi.espadna.com/privacy/';
