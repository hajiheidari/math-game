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
• Stuck? Free hints from friends: every friend who opens your invite or your result gives you one (up to 3 a day)
• Share your wins with friends: a picture card and a challenge
• English, Arabic, Persian and Urdu, with Western or local digits
• Plays well on iPhone and iPad, offline
• No sign-up: your progress stays on your device

Adadi is free, with no ads and no purchases.

**Keywords** (100): `math,puzzle,crossword,numbers,brain,logic,equation,arithmetic,daily,sums,mental math,teens`

**Support URL:** `https://espadna.com/adadi-app/`
**Marketing URL:** `https://espadna.com/adadi-app/`
**Privacy policy URL:** `https://adadi.espadna.com/privacy/`
**Copyright:** `2026 Amir HajiHeidari`
**Contact email (review):** `espadna.support@gmail.com`

**App Review notes:**
No account is needed. On first launch the app asks for an age group (13+); choose "18+".
No ads and no in-app purchases. Hints: a player starts with none and gets one each time a friend
opens a link they shared (Menu → Invite friends, or "Show your friends" after a win), up to 3 a day.
The friend opens it in the web game (adadi.espadna.com); only random codes are sent to our server.

## App Privacy
No ads, no analytics, no tracking. The only data that leaves the device is for "hints from friends"
(random invite codes, and a salted hash of the IP address kept for 2 days; see the privacy policy):
- **Data Used to Track You:** none. Answer "No" to tracking.
- **Identifiers → User ID** (the random invite code): purpose **App Functionality**; **not linked**
  to the user's identity; **not used for tracking**.
- Nothing else is collected.

## In-app purchase
None for now. If a "remove_ads" product was already created in App Store Connect, leave it unsubmitted
(do not attach it to this version).
