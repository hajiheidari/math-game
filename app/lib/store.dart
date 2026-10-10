/// Which store this build is for, chosen at build time:
///   flutter build apk --dart-define=STORE=bazaar -t lib/main_bazaar.dart
/// (tool/store_build.sh does both and drops the other store's SDKs).
enum StoreTarget {
  /// App Store, Google Play and the web. No ads for now (Amir, 2026-10-10):
  /// no ad SDK, no "Remove ads" purchase. Hints come from friends only.
  global,

  /// Cafe Bazaar: Adivery ads, Bazaar billing (Poolakey), Persian first.
  bazaar;

  /// Language when nothing is saved yet; null = the device's.
  String? get defaultLanguage => this == bazaar ? 'fa' : null;

  /// Ads and the "Remove ads" purchase (Settings) exist in this build.
  bool get hasAds => this == bazaar;
}

const StoreTarget kStore = String.fromEnvironment('STORE') == 'bazaar'
    ? StoreTarget.bazaar
    : StoreTarget.global;
