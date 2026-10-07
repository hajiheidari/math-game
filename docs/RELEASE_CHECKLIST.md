# Release checklist

Step-by-step version in Persian, in the order to do them: `docs/PUBLISH-FA.md`.

Things that need your accounts or a Mac/Android SDK; the code is ready for them.

## Identity
- [x] App name: **Adadi** (عددی). Before publishing, search both stores once more and consider a
      trademark check. Suggested store title: "Adadi: Math Crossword" (fa: «عددی: جدول ریاضی»).
- [x] Application id / bundle id: `com.espadna.adadi` (Espadna brand, like `com.espadna.tiaro`). Permanent
      after the first store upload.
- [x] App icon (`app/branding/`, regenerate with `node tool/make_icons.js`).
- [ ] Store art: screenshots and feature graphic.

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
- [ ] Host `docs/privacy/index.html` (EN + FA, ready-to-host page; source text in
      `docs/privacy-policy.md`), host it, and set `kPrivacyPolicyUrl` in `ad_config.dart`.
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
