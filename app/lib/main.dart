// Entry point of the App Store / Google Play / web build: AdMob ads and the
// stores' own billing. The Cafe Bazaar build starts from lib/main_bazaar.dart.
import 'app_root.dart';
import 'monetization/admob_ad_service.dart';
import 'monetization/store_purchase_service.dart';

void main() =>
    runAdadi(ads: AdMobAdService.new, purchases: StorePurchaseService.new);
