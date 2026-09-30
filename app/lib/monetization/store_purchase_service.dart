import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'ad_config.dart';
import 'purchase_service.dart';

/// App Store / Google Play billing via `in_app_purchase`.
///
/// No server-side receipt validation (there is no backend); the unlock is
/// cached locally by [Monetization] and can be restored from the store.
class StorePurchaseService implements PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;

  @override
  void Function()? onRemoveAdsOwned;

  @override
  Future<void> start() async {
    _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
    _available = await _iap.isAvailable();
    if (!_available) return;
    final response = await _iap.queryProductDetails({kRemoveAdsProductId});
    _product = response.productDetails.isEmpty
        ? null
        : response.productDetails.first;
  }

  @override
  bool get available => _available && _product != null;

  @override
  String? get removeAdsPrice => _product?.price;

  @override
  Future<bool> buyRemoveAds() async {
    final product = _product;
    if (!_available || product == null) return false;
    return _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<void> restore() async {
    if (_available) await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID == kRemoveAdsProductId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        onRemoveAdsOwned?.call();
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }
}
