/// Which store this build is for, chosen at build time:
///   flutter build apk --dart-define=STORE=bazaar -t lib/main_bazaar.dart
/// (tool/store_build.sh does both and drops the other store's SDKs).
enum StoreTarget {
  /// App Store, Google Play and the web. No ad network yet: coins come from
  /// friends. Nothing to buy in any build (Amir, 2026-10-14).
  global,

  /// Cafe Bazaar: Adivery rewarded ads for coins, Persian first.
  bazaar;

  /// Language when nothing is saved yet; null = the device's.
  String? get defaultLanguage => this == bazaar ? 'fa' : null;

  /// This build has an ad network (rewarded ads for coins).
  bool get hasAds => this == bazaar;
}

const StoreTarget kStore = String.fromEnvironment('STORE') == 'bazaar'
    ? StoreTarget.bazaar
    : StoreTarget.global;
