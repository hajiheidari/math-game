import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_service.dart';

/// AdMob rewarded ads with Google UMP consent and Apple ATT. Not used by
/// any build yet (the App Store / Play network is still to be chosen).
class AdMobAdService implements AdService {
  bool _started = false;
  bool _canRequestAds = false;
  RewardedAd? _rewarded;

  @override
  Future<void> start(AdAudience audience) async {
    if (_started) return;
    _started = true;
    await _gatherConsent(audience);
    await _requestTrackingIfNeeded();
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (!_canRequestAds) return;
    await MobileAds.instance.updateRequestConfiguration(_config(audience));
    await MobileAds.instance.initialize();
    _loadRewarded();
  }

  @override
  Future<void> updateAudience(AdAudience audience) async {
    if (!_canRequestAds) return;
    await MobileAds.instance.updateRequestConfiguration(_config(audience));
  }

  RequestConfiguration _config(AdAudience a) => RequestConfiguration(
    // Brief: max content rating teen for every band.
    maxAdContentRating: MaxAdContentRating.t,
    ageRestrictedTreatment: a.teen
        ? AgeRestrictedTreatment.teen
        : AgeRestrictedTreatment.unspecified,
  );

  /// Google UMP: shows the GDPR/UK consent form where it is required.
  Future<void> _gatherConsent(AdAudience audience) {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        tagForUnderAgeOfConsent: audience.underAgeOfConsent,
      ),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) {
        if (!done.isCompleted) done.complete();
      }),
      (_) {
        // Offline or misconfigured: fall back to whatever consent is stored.
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  /// iOS App Tracking Transparency prompt, after UMP and after onboarding.
  Future<void> _requestTrackingIfNeeded() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } on Object {
      // ATT unavailable (old iOS): nothing to ask.
    }
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _retry(_loadRewarded),
      ),
    );
  }

  void _retry(void Function() load) => Timer(const Duration(seconds: 60), load);

  @override
  bool get rewardedReady => _rewarded != null;

  @override
  Future<bool> showRewarded() {
    final ad = _rewarded;
    if (ad == null) return Future.value(false);
    _rewarded = null;
    final result = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!result.isCompleted) result.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
        if (!result.isCompleted) result.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earned = true);
    return result.future;
  }

  @override
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) {
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }
}
