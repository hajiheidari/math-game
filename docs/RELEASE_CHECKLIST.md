# Release checklist

Things that need your accounts or a Mac/Android SDK; the code is ready for them.

## Identity
- [ ] Final app name (NumCross is a placeholder; check it is free in both stores and as a trademark).
- [ ] Application id / bundle id (currently `com.numcross.numcross`): `app/android/app/build.gradle.kts`
      (`applicationId`) and the Xcode project.
- [ ] App icon and store art (teen/adult look, no mascots).

## AdMob (replace Google TEST ids)
- [ ] Android app id → `app/android/app/src/main/AndroidManifest.xml` (`APPLICATION_ID`).
- [ ] iOS app id → `app/ios/Runner/Info.plist` (`GADApplicationIdentifier`).
- [ ] Rewarded + interstitial unit ids (Android and iOS) → `app/lib/monetization/ad_config.dart`.
- [ ] AdMob console: set **max ad content rating = T (Teen)** for the app, and create the
      GDPR/US-states messages under Privacy & messaging (UMP).
- [ ] iOS: add Google's full `SKAdNetworkItems` list to Info.plist.
- [ ] iOS: translate `NSUserTrackingUsageDescription` (InfoPlist.strings for fa/ar/ur, in Xcode).

## Purchases
- [ ] Create non-consumable product `remove_ads` in App Store Connect and Google Play Console.
- [ ] Test buy + restore with sandbox/test accounts.

## Privacy & store forms
- [ ] Host `docs/privacy-policy.md` (after review) and set `kPrivacyPolicyUrl` in `ad_config.dart`.
- [ ] Apple: age rating 13+ (answer the questionnaire accordingly); App Privacy: identifiers +
      usage data for third-party advertising (AdMob), no data linked to identity.
- [ ] Google Play: target audience 13–15, 16–17, 18+ (no under-13); do **not** join
      "Designed for Families"; no Kids category; Data safety form matching the policy;
      Ads declaration = yes.

## Build & test
- [ ] Install Android Studio + SDK, then `flutter build appbundle`.
- [ ] On a Mac: `pod install`, `flutter build ipa`.
- [ ] Test on a mid-range Android phone and an older iPhone: consent form (use a VPN/EEA
      test device), ATT prompt, rewarded hint, extra life, interstitial pacing, remove ads.
- [ ] Bump `version:` in `app/pubspec.yaml`.
