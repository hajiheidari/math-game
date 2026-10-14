// Entry point of the Cafe Bazaar build (tool/store_build.sh bazaar):
// Adivery rewarded ads (coins), Persian by default. Needs
// --dart-define=STORE=bazaar too, which tool/store_build.sh passes.
import 'app_root.dart';
import 'monetization/adivery_ad_service.dart';

void main() => runAdadi(ads: AdiveryAdService.new);
