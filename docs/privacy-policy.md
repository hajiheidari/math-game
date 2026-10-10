# Adadi — Privacy Policy

> Source text of the hosted page `docs/privacy/index.html` (English + Persian). Host that page
> at a public URL and put the URL in `app/lib/monetization/ad_config.dart` (`kPrivacyPolicyUrl`)
> and in both store listings. Keep this file and the page in sync; update the date on changes.

_Last updated: October 10, 2026_
Adadi (“the app”) is a math puzzle game for people aged 13 and over, published by Amir HajiHeidari (“we”, “us”). This policy explains what information the app handles and why.

## Summary
- No accounts, no analytics. Your progress and settings stay on your device.
- The App Store, Google Play and web versions show **no ads** and have no purchases.
- Free hints come from friends: when a friend opens a link you shared, our server counts it using random codes, never your name or contacts (see “Hints from friends”).
- The Cafe Bazaar version (Iran) shows ads by Adivery (see below).

## Information stored on your device
The following is saved locally on your device only. We cannot see it, and it is never sent to us.
- **Age group** (13–15, 16–17 or 18+). The app asks your age once to choose suitable puzzles. Only the resulting age group is saved; your age or birth date is never stored or sent anywhere.
- If an age under 13 is entered, the app stores only a flag that blocks play, and nothing else.
- **Game progress:** levels completed, stars, daily puzzles solved, streaks, unfinished puzzles, hints.
- **Settings:** language, digit style, sound and vibration on/off, whether the tutorial was completed.
- A random secret used for “Hints from friends” (below).
Deleting the app, or clearing its data, permanently deletes all of this.

## Hints from friends
Each copy of the app makes a random secret, and from it a short random invite code (for example `k3xq8mzt2a`). The links you share (an invitation or a puzzle result) contain only this code. When a friend opens such a link in the web game, the web game sends our server your code and the friend’s own random code, so that you get a hint. To count each friend only once a day, the server also keeps a one-way (salted) hash of the friend’s IP address; it never stores the IP address itself. When your app collects its hints, it sends the secret, and your IP address is handled the same way. These records are deleted after 2 days; the server only keeps, per invite code, how many hints are waiting to be collected (at most 9).
The codes are random and are not linked to your name, phone number, contacts or device identifiers. We never see whom you send links to: sharing happens through your phone’s own share sheet. The server runs on Cloudflare.

## Cafe Bazaar version
The version of the app from Cafe Bazaar (Iran) shows ads by **Adivery**, which may collect device information such as the advertising ID and IP address to show and measure ads; see Adivery’s privacy policy (<https://adivery.com>). “Remove ads” is bought through **Cafe Bazaar**’s payment system; we do not receive your payment details. The app only remembers on your device that the purchase was made.

## What we do not do
The app has no accounts, no sign-in, no analytics or crash reporting, no chat, and no location access. It does not read your contacts. We do not sell, rent or share personal information, and we do not knowingly collect personal information from anyone.

## Children
The app is not intended for children under 13. It blocks play when an age under 13 is entered and stores nothing about that person except the block. If you believe a child under 13 is using the app, deleting the app removes everything it stored.

## Your rights
We hold no personal data about you: app data is on your device and under your control, and the friend-hint records are random codes deleted after 2 days. For questions, write to us (below).

## Changes to this policy
If the app changes how it handles information, we will update this page and the “Last updated” date above.

## Contact
Questions about this policy: espadna.support@gmail.com
