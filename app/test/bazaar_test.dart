import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/monetization/ad_service.dart';
import 'package:numcross/monetization/adivery_ad_service.dart';
import 'package:numcross/monetization/bazaar_config.dart';
import 'package:numcross/monetization/bazaar_purchase_service.dart';
import 'package:numcross/store.dart';

void main() {
  test('Bazaar build defaults to Persian; the global one to the device', () {
    expect(StoreTarget.bazaar.defaultLanguage, 'fa');
    expect(StoreTarget.global.defaultLanguage, isNull);
    // Tests run as the global build.
    expect(kStore, StoreTarget.global);
  });

  test(
    'without panel ids the Bazaar services stay off (safe to test early)',
    () async {
      if (BazaarConfig.adiveryAppId.isNotEmpty ||
          BazaarConfig.rsaKey.isNotEmpty) {
        return; // Real ids filled in: covered by the device tests instead.
      }
      final ads = AdiveryAdService();
      await ads.start(AdAudience.adult);
      expect(ads.rewardedReady, isFalse);
      expect(await ads.showRewarded(), isFalse);
      await ads.showInterstitial(); // returns at once
      expect(await ads.privacyOptionsRequired(), isFalse);

      final store = BazaarPurchaseService();
      await store.start();
      expect(store.available, isFalse);
      expect(await store.buyRemoveAds(), isFalse);
    },
  );
}
