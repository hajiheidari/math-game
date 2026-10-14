# Adadi — Privacy Policy

> Source text of the hosted page `docs/privacy/index.html` (English + Persian). Host that page
> at a public URL and put the URL in `app/lib/monetization/ad_config.dart` (`kPrivacyPolicyUrl`)
> and in both store listings. Keep this file and the page in sync; update the date on changes.

_Last updated: October 14, 2026_
Adadi (“the app”) is a math puzzle game for people aged 13 and over, published by Amir HajiHeidari (“we”, “us”). This policy explains what information the app handles and why.

## Summary
- No accounts, no analytics. The app is free in every version and has no purchases.
- The App Store, Google Play and web versions show **no ads**. The Cafe Bazaar version (Iran) offers optional rewarded videos by Adivery (see below).
- Hints cost coins. Coins come from friends: when a friend opens a challenge or invitation you shared, our server counts it using random codes, never your name or contacts.
- Your progress can be backed up: under a random recovery code on our server, in your iCloud (iPhone, iPad) and in your Google backup (Android).

## Information stored on your device
- **Age group** (13–15, 16–17 or 18+). The app asks your age once to choose suitable puzzles. Only the resulting age group is saved; your age or birth date is never stored or sent anywhere.
- If an age under 13 is entered, the app stores only a flag that blocks play, and nothing else, and makes no backup.
- **Game progress:** levels completed, stars, daily puzzles solved, streaks, unfinished puzzles, coins and certificates.
- **Name on certificates**, only if you type one (any name or nickname you like).
- **Settings:** language, digit style, sound and vibration on/off, whether the tutorial was completed.
- Random codes used for coins from friends and for the backup (below).
Deleting the app, or clearing its data, deletes all of this from the device (copies in a backup remain, see “Backup”).

## Challenges and coins from friends
Each copy of the app makes a random secret, and from it a short random invite code (for example `k3xq8mzt2a`). The links you share contain this code and, for a challenge, which puzzle you solved and your time. When a friend opens such a link in the web game, it sends our server your code and the friend’s own random code, so that you get a coin. To count each friend only once a day, the server also keeps a one-way (salted) hash of the friend’s IP address; it never stores the IP address itself. When your app collects its coins, it sends the secret, and your IP address is handled the same way. These records are deleted after 2 days; the server only keeps, per invite code, how many coins are waiting to be collected (at most 9).
The codes are random and are not linked to your name, phone number, contacts or device identifiers. We never see whom you send links to: sharing happens through your phone’s own share sheet. The server runs on Cloudflare.

## Backup
- **Recovery code:** the app keeps a copy of the game data listed above (progress, settings, the optional certificate name and the random codes; never your age) on our server, under a random 12-character code shown in Settings → Backup. Entering the code on another phone or in the web game brings your progress back. Anyone who has the code can restore that copy, so keep it to yourself. A copy is deleted 400 days after it was last updated, or earlier if you email us the code and ask.
- **iCloud** (iPhone, iPad): a copy of the same data is kept in your own iCloud account (key-value storage), so it comes back after reinstalling and on your other Apple devices. Apple’s privacy policy applies; turning iCloud off for the app stops it.
- **Google backup** (Android): if backup is on in your phone’s settings, Android includes the app’s data in your Google backup. Google’s privacy policy applies.

## Game Center (iPhone, iPad)
If you are signed in to Apple Game Center, the app sends your best daily streak, the number of levels completed and your total stars to Game Center leaderboards. Your Game Center name is managed by Apple and is not stored by us. Apple’s privacy policy applies.

## Cafe Bazaar version
The version of the app from Cafe Bazaar (Iran) offers rewarded videos by **Adivery**: only when you choose to watch one, for a coin. Adivery may collect device information such as the advertising ID and IP address to show and measure ads; see Adivery’s privacy policy (<https://adivery.com>). There are no other ads and nothing to buy.

## What we do not do
The app has no accounts, no sign-in, no analytics or crash reporting, no chat, and no location access. It does not read your contacts. We do not sell, rent or share personal information, and we do not knowingly collect personal information from anyone.

## Children
The app is not intended for children under 13. It blocks play when an age under 13 is entered and stores nothing about that person except the block. If you believe a child under 13 is using the app, deleting the app removes everything it stored on the device; email us a recovery code to delete a backup.

## Your rights
We hold no personal data that identifies you: backups are kept under random codes, and the friend records are random codes deleted after 2 days. You can ask us to delete a backup by sending its recovery code. For questions, write to us (below).

## Changes to this policy
If the app changes how it handles information, we will update this page and the “Last updated” date above.

## Contact
Questions about this policy: espadna.support@gmail.com
