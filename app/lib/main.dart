// Entry point of the App Store / Google Play / web build. No ads for now
// (Amir, 2026-10-10): tool/store_build.sh leaves the ad and billing SDKs out.
// AdMob + store billing are still in lib/monetization/ (admob_ad_service.dart,
// store_purchase_service.dart) for when ads come back. The Cafe Bazaar build
// starts from lib/main_bazaar.dart.
import 'app_root.dart';

void main() => runAdadi();
