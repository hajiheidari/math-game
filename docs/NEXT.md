# Next update: open points

0.14.0 (2026-10-14) did what Amir asked for after 0.13.0: challenges, coins, rewarded ads only,
free app, bigger cells, digits fix, backup (recovery code, iCloud, Google), certificates and Game
Center (see CHANGELOG). What is left:

## Apple (only after the 0.13.0 review result, Amir 2026-10-13)
1. Create the three Game Center leaderboards in App Store Connect ("Best score", integer, high to
   low): `adadi.best_streak`, `adadi.levels`, `adadi.stars` (docs/store/appstore-listing.md), and
   add them to the 0.14.0 version.
2. Build 0.14.0 with `ios.yml`. New this time: the app is signed with `Runner.entitlements` (Game
   Center + iCloud key-value storage). The workflow signs the archive ad hoc with those
   entitlements so the export keeps them; check in its log that `codesign -d --entitlements` lists
   both, and that the export did not fail on the iCloud capability (if it did: developer.apple.com
   → Identifiers → com.espadna.adadi → enable iCloud, then run again).
3. App Privacy answers change (backup data): docs/store/appstore-listing.md → "App Privacy".

## Rewarded ads in the App Store / Google Play build
Coins from ads exist only in the Cafe Bazaar build (Adivery). For Apple / Google, Amir picks the
network (AdMob code is ready in `lib/monetization/admob_ad_service.dart`; Tiaro dropped AdMob).
Then: `lib/main.dart` passes it to `runAdadi(ads: ...)`, `tool/store_build.sh` / `ios.yml` keep its
package, the ATT text and SKAdNetwork ids go back into Info.plist, the privacy texts change.

## Challenge links that open the app
Challenge links open the web game (works on every phone, nothing to install). To open the app
instead when it is installed: universal links (Associated Domains entitlement + AASA file with the
Team ID) and Android App Links (assetlinks.json with the Play / Bazaar signing SHA-256).
