/// Cafe Bazaar build settings (lib/main_bazaar.dart). Like Tiaro's Bazaar build:
/// Adivery ads (AdMob does not serve ads in Iran) and Bazaar billing.
///
/// Fill in from the panels; until a value is set, that feature stays off
/// (no ads / no "Remove ads" button), so the build is safe to test early.
class BazaarConfig {
  /// Adivery panel (adivery.com) → the app → App ID.
  static const adiveryAppId = '';

  /// Adivery placements (same panel): rewarded video and interstitial.
  static const adiveryRewarded = '';
  static const adiveryInterstitial = '';

  /// Cafe Bazaar developer panel → the app → In-app payments → RSA key.
  /// A public key: fine to keep in the source.
  static const rsaKey = '';
}
