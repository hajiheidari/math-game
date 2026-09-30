/// The one-time "Remove ads" purchase.
abstract class PurchaseService {
  /// Called with true whenever the store confirms the purchase (buy or
  /// restore). Set by [Monetization].
  void Function()? onRemoveAdsOwned;

  Future<void> start();

  /// Store is reachable and the product exists.
  bool get available;

  /// Localized price from the store, e.g. "$2.99".
  String? get removeAdsPrice;

  /// Starts the store purchase flow; the result arrives via
  /// [onRemoveAdsOwned]. False if it could not be started.
  Future<bool> buyRemoveAds();

  /// Required by Apple: re-delivers past purchases via [onRemoveAdsOwned].
  Future<void> restore();
}

/// Web/desktop and tests: no store.
class NoPurchaseService implements PurchaseService {
  @override
  void Function()? onRemoveAdsOwned;

  @override
  Future<void> start() async {}

  @override
  bool get available => false;

  @override
  String? get removeAdsPrice => null;

  @override
  Future<bool> buyRemoveAds() async => false;

  @override
  Future<void> restore() async {}
}
