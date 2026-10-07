import 'dart:async';

import 'package:adivery/adivery.dart';

import 'ad_service.dart';
import 'bazaar_config.dart';

/// Adivery ads for the Cafe Bazaar build: same contract as [AdMobAdService].
/// No consent form: Adivery serves Iran, where the GDPR/US consent flow does
/// not apply. Off until [BazaarConfig] has the Adivery ids.
class AdiveryAdService implements AdService {
  bool _started = false;
  bool _rewardedLoaded = false;
  bool _interstitialLoaded = false;
  Completer<bool>? _rewardedDone;
  Completer<void>? _interstitialDone;

  static bool get configured =>
      BazaarConfig.adiveryAppId.isNotEmpty &&
      BazaarConfig.adiveryRewarded.isNotEmpty &&
      BazaarConfig.adiveryInterstitial.isNotEmpty;

  @override
  Future<void> start(AdAudience audience) async {
    if (_started || !configured) return;
    _started = true;
    try {
      AdiveryPlugin.addListener(
        onRewardedLoaded: (_) => _rewardedLoaded = true,
        onInterstitialLoaded: (_) => _interstitialLoaded = true,
        onRewardedClosed: (_, rewarded) {
          _rewardedLoaded = false;
          _finishRewarded(rewarded);
          AdiveryPlugin.prepareRewardedAd(BazaarConfig.adiveryRewarded);
        },
        onInterstitialClosed: (_) {
          _interstitialLoaded = false;
          _finishInterstitial();
          AdiveryPlugin.prepareInterstitialAd(BazaarConfig.adiveryInterstitial);
        },
        onError: (placement, _) {
          // No fill or a failed show: never keep the player waiting.
          if (placement == BazaarConfig.adiveryRewarded) _finishRewarded(false);
          if (placement == BazaarConfig.adiveryInterstitial) {
            _finishInterstitial();
          }
        },
      );
      AdiveryPlugin.initialize(BazaarConfig.adiveryAppId);
      AdiveryPlugin.prepareRewardedAd(BazaarConfig.adiveryRewarded);
      AdiveryPlugin.prepareInterstitialAd(BazaarConfig.adiveryInterstitial);
    } on Object {
      // Ads are optional; the game works without them.
    }
  }

  void _finishRewarded(bool rewarded) {
    final done = _rewardedDone;
    _rewardedDone = null;
    if (done != null && !done.isCompleted) done.complete(rewarded);
  }

  void _finishInterstitial() {
    final done = _interstitialDone;
    _interstitialDone = null;
    if (done != null && !done.isCompleted) done.complete();
  }

  @override
  Future<void> updateAudience(AdAudience audience) async {}

  @override
  bool get rewardedReady => _rewardedLoaded;

  @override
  Future<bool> showRewarded() {
    if (!_rewardedLoaded) return Future.value(false);
    final done = _rewardedDone = Completer<bool>();
    AdiveryPlugin.show(BazaarConfig.adiveryRewarded);
    return done.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () => false,
    );
  }

  @override
  Future<void> showInterstitial() {
    if (!_interstitialLoaded) return Future.value();
    final done = _interstitialDone = Completer<void>();
    AdiveryPlugin.show(BazaarConfig.adiveryInterstitial);
    return done.future.timeout(const Duration(minutes: 3), onTimeout: () {});
  }

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}
