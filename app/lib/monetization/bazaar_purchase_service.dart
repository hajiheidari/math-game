import 'dart:async';

import 'package:flutter_poolakey/flutter_poolakey.dart';

import 'ad_config.dart';
import 'bazaar_config.dart';
import 'purchase_service.dart';

/// Cafe Bazaar billing (Poolakey) for the Bazaar build: Google Play billing
/// is not allowed there. The same non-consumable product id as the other
/// stores ([kRemoveAdsProductId]); create it in the Bazaar panel. Off (no
/// "Remove ads" button) until [BazaarConfig.rsaKey] is set.
class BazaarPurchaseService implements PurchaseService {
  bool _connected = false;
  String? _price;

  @override
  void Function()? onRemoveAdsOwned;

  @override
  Future<void> start() async {
    if (BazaarConfig.rsaKey.isEmpty) return;
    try {
      await FlutterPoolakey.connect(
        BazaarConfig.rsaKey,
        onSucceed: () {
          _connected = true;
          unawaited(_afterConnect());
        },
        onFailed: () => _connected = false,
        onDisconnected: () => _connected = false,
      );
    } on Object {
      // Bazaar not installed or unreachable: no purchase button.
    }
  }

  Future<void> _afterConnect() async {
    try {
      final details = await FlutterPoolakey.getInAppSkuDetails([
        kRemoveAdsProductId,
      ]);
      _price = details.isEmpty ? null : details.first.price;
    } on Object {
      _price = null;
    }
    await restore();
  }

  @override
  bool get available => _connected && _price != null;

  @override
  String? get removeAdsPrice => _price;

  @override
  Future<bool> buyRemoveAds() async {
    if (!available) return false;
    try {
      final info = await FlutterPoolakey.purchase(kRemoveAdsProductId);
      if (info.purchaseState == PurchaseState.PURCHASED) {
        onRemoveAdsOwned?.call();
      }
      return true;
    } on Object {
      // Cancelled or failed: Poolakey throws.
      return false;
    }
  }

  @override
  Future<void> restore() async {
    if (!_connected) return;
    try {
      final owned = await FlutterPoolakey.getAllPurchasedProducts();
      if (owned.any(
        (p) =>
            p.productId == kRemoveAdsProductId &&
            p.purchaseState == PurchaseState.PURCHASED,
      )) {
        onRemoveAdsOwned?.call();
      }
    } on Object {
      // Offline: the unlock cached by Monetization still applies.
    }
  }
}
