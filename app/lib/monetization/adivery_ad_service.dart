import 'dart:async';

import 'package:adivery/adivery.dart';

import 'ad_service.dart';
import 'bazaar_config.dart';

/// Adivery rewarded ads for the Cafe Bazaar build (no other ad format).
/// No consent form: Adivery serves Iran, where the GDPR/US consent flow does
/// not apply. Off until [BazaarConfig] has the Adivery ids.
class AdiveryAdService implements AdService {
  bool _started = false;
  bool _rewardedLoaded = false;
  Completer<bool>? _rewardedDone;

  static bool get configured =>
      BazaarConfig.adiveryAppId.isNotEmpty &&
      BazaarConfig.adiveryRewarded.isNotEmpty;

  @override
  Future<void> start(AdAudience audience) async {
    if (_started || !configured) return;
    _started = true;
    try {
      AdiveryPlugin.addListener(
        onRewardedLoaded: (_) => _rewardedLoaded = true,
        onRewardedClosed: (_, rewarded) {
          _rewardedLoaded = false;
          _finishRewarded(rewarded);
          AdiveryPlugin.prepareRewardedAd(BazaarConfig.adiveryRewarded);
        },
        onError: (placement, _) {
          // No fill or a failed show: never keep the player waiting.
          if (placement == BazaarConfig.adiveryRewarded) _finishRewarded(false);
        },
      );
      AdiveryPlugin.initialize(BazaarConfig.adiveryAppId);
      AdiveryPlugin.prepareRewardedAd(BazaarConfig.adiveryRewarded);
    } on Object {
      // Ads are optional; the game works without them.
    }
  }

  void _finishRewarded(bool rewarded) {
    final done = _rewardedDone;
    _rewardedDone = null;
    if (done != null && !done.isCompleted) done.complete(rewarded);
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
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}
