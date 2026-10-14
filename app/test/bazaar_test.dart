import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/monetization/adivery_ad_service.dart';
import 'package:numcross/store.dart';

void main() {
  test('Bazaar build defaults to Persian; the global one to the device', () {
    expect(StoreTarget.bazaar.defaultLanguage, 'fa');
    expect(StoreTarget.global.defaultLanguage, isNull);
    // Tests run as the global build.
    expect(kStore, StoreTarget.global);
  });

  test('Adivery ids are filled in (Amir\'s panel)', () {
    expect(AdiveryAdService.configured, isTrue);
  });

  test('ads that never loaded resolve at once, never block the game', () async {
    final ads = AdiveryAdService(); // not started: nothing loaded
    expect(ads.rewardedReady, isFalse);
    expect(await ads.showRewarded(), isFalse);
    expect(await ads.privacyOptionsRequired(), isFalse);
  });
}
