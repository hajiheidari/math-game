/// Cafe Bazaar build settings (lib/main_bazaar.dart). Like Tiaro's Bazaar build:
/// Adivery ads (AdMob does not serve ads in Iran) and Bazaar billing.
///
/// Fill in from the panels; until a value is set, that feature stays off
/// (no ads / no "Remove ads" button), so the build is safe to test early.
class BazaarConfig {
  /// Adivery panel (adivery.com) → the app → App ID. Amir's panel, 2026-10-07.
  static const adiveryAppId = 'c34fbfa0-89bf-4d40-9d3a-5edd2dd40577';

  /// Adivery placements (same panel): rewarded video and interstitial.
  static const adiveryRewarded = '60cf16da-07fa-4059-a4eb-1bcbd5d3da81';
  static const adiveryInterstitial = 'c9de05cc-8f9b-4b0c-9cf2-4216b10e27e9';

  /// Cafe Bazaar developer panel → the app → In-app payments → RSA key.
  /// A public key: fine to keep in the source.
  static const rsaKey = '';
}
