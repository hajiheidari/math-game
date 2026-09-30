/// Who the ads are for. Derived from the age band only (never the age).
class AdAudience {
  /// 13–17: teen ad treatment.
  final bool teen;

  /// Under the GDPR age of digital consent (up to 16 in some EU countries):
  /// no consent form, non-personalized ads only.
  final bool underAgeOfConsent;

  const AdAudience({required this.teen, required this.underAgeOfConsent});

  static const adult = AdAudience(teen: false, underAgeOfConsent: false);
}

/// Everything the app needs from an ad network.
abstract class AdService {
  /// Consent (UMP), then ATT on iOS, then the SDK. Call once, after
  /// onboarding (not on the first frame).
  Future<void> start(AdAudience audience);

  /// Band changed in Settings.
  Future<void> updateAudience(AdAudience audience);

  bool get rewardedReady;

  /// Shows a rewarded ad; true if the reward was earned.
  Future<bool> showRewarded();

  /// Shows an interstitial if one is loaded; completes when it is closed.
  Future<void> showInterstitial();

  /// Whether the "Privacy choices" entry must be offered (UMP).
  Future<bool> privacyOptionsRequired();

  Future<void> showPrivacyOptions();
}

/// Used on web/desktop and in tests: no ads at all.
class NoAdService implements AdService {
  @override
  Future<void> start(AdAudience audience) async {}

  @override
  Future<void> updateAudience(AdAudience audience) async {}

  @override
  bool get rewardedReady => false;

  @override
  Future<bool> showRewarded() async => false;

  @override
  Future<void> showInterstitial() async {}

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}
