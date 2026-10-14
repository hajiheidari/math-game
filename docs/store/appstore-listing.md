# Adadi on the App Store (iPhone + iPad)

Ready to paste into App Store Connect. Screenshots: `docs/store/appstore/`
(`iphone-1..5.png` 1320×2868 for the 6.9" slot, `ipad-1..5.png` 2064×2752 for the 13" slot;
re-render with `SCREENSHOTS=1 flutter test test/store_screenshots_test.dart`).

## App information
- **Name** (30): `Adadi: Math Crossword`
- **Subtitle** (30): `Daily number puzzles`
- **Bundle ID:** `com.espadna.adadi`  **SKU:** `adadi`
- **Primary language:** English (U.S.)
- **Category:** Games → Puzzle; secondary: Games → Educational
- **Content rights:** no third-party content
- **Age rating:** answer "None" to every question; under "Age Rating Override" choose **13+**
  (the game itself is closed to players under 13). Not "Made for Kids".

## Version page
**Promotional text** (170):
A crossword where every row and column is an equation. Fill in the numbers, make every sum true, and keep your daily streak going.

**Description:**
Adadi is a crossword made of numbers. Every row and every column is an equation: pick tiles from the bank and place them so that all the equations are true at once.

• Addition, subtraction, multiplication and division in one grid
• Every puzzle has exactly one answer: no guessing, just arithmetic and logic
• A new daily puzzle every day, with a streak calendar
• Four difficulties: Easy, Medium, Hard and Expert
• Challenge your friends: they play the very same puzzle against your time
• Coins for hints: every friend who opens your challenge or invite gives you one (up to 3 a day)
• Certificates for your streaks and milestones, made to share as a story
• Game Center leaderboards: best streak, levels and stars
• Your progress is safe: iCloud backup and a recovery code for a new phone
• Big boards zoom in, so every cell is easy to tap
• English, Arabic, Persian and Urdu, with Western or local digits
• Plays well on iPhone and iPad, offline
• No sign-up

Adadi is free, with no ads and no purchases.

**Keywords** (100): `math,puzzle,crossword,numbers,brain,logic,equation,arithmetic,daily,sums,mental math,teens`

**Support URL:** `https://espadna.com/adadi-app/`
**Marketing URL:** `https://espadna.com/adadi-app/`
**Privacy policy URL:** `https://adadi.espadna.com/privacy/`
**Copyright:** `2026 Amir HajiHeidari`
**Contact email (review):** `espadna.support@gmail.com`

**App Review notes:**
No account is needed. On first launch the app asks for an age group (13+); choose "18+".
No ads and no in-app purchases. Hints cost coins: a player starts with none and gets one each time a
friend opens a link they shared (Menu → Invite, or "Challenge your friends" after a win), up to 3 a
day. The friend opens it in the web game (adadi.espadna.com) and plays the same puzzle against the
sender's time; only random codes are sent to our server. Settings → Backup shows a recovery code
(the progress is saved on our server under it, and in the player's iCloud). Game Center is optional.

## App Privacy
No ads, no analytics, no tracking. Data that leaves the device: "coins from friends" (random invite
codes, a salted hash of the IP address kept for 2 days) and the backup (game progress under a random
recovery code; see the privacy policy). From 0.14.0 the answers are:
- **Data Used to Track You:** none. Answer "No" to tracking.
- **Identifiers → User ID** (the random invite code / recovery code): purpose **App Functionality**;
  **not linked** to the user's identity; **not used for tracking**.
- **Usage Data → Product Interaction** (levels, stars, streaks in the backup): **App Functionality**;
  not linked; not used for tracking.
- **User Content → Other User Content** (the optional name on certificates, in the backup):
  **App Functionality**; not linked; not used for tracking.
- Game Center scores go to Apple (Apple's own disclosure; nothing to add here).

## In-app purchase
None: the app is free (Amir, 2026-10-14). If a "remove_ads" product was created in App Store Connect,
leave it unsubmitted.

## Game Center (0.14.0, after the 0.13.0 review)
Leaderboards to create (App Store Connect → the app → Services → Game Center), "Best score",
integer, high to low: `adadi.best_streak` (Best daily streak), `adadi.levels` (Levels completed),
`adadi.stars` (Stars). Then add them to the 0.14.0 version page (Game Center section).
