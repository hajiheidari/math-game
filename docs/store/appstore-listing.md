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
• Hints when you get stuck
• Share your wins with friends: a picture card and a challenge
• English, Arabic, Persian and Urdu, with Western or local digits
• Plays well on iPhone and iPad, offline
• No sign-up: your progress stays on your device

Adadi is free with ads between levels, never in the middle of a puzzle. A one-time purchase removes ads for good.

**Keywords** (100): `math,puzzle,crossword,numbers,brain,logic,equation,arithmetic,daily,sums,mental math,teens`

**Support URL:** `https://espadna.com/adadi-app/`
**Marketing URL:** `https://espadna.com/adadi-app/`
**Privacy policy URL:** `https://adadi.espadna.com/privacy/`
**Copyright:** `2026 Amir HajiHeidari`
**Contact email (review):** `espadna.support@gmail.com`

**App Review notes:**
No account is needed. On first launch the app asks for an age group (13+); choose "18+".
Ads are shown by Google AdMob. "Remove ads" is a non-consumable in-app purchase, restorable from Settings.

## In-app purchase
- Type: **Non-Consumable**, Product ID: **`remove_ads`**, Reference name: Remove ads
- Display name: `Remove ads`; description: `Removes all ads between levels, forever.`
- Price: $3.99 (same as Tiaro); review screenshot: the Settings screen.

## App Privacy (data collected by Google AdMob)
Following Google's guide for AdMob on the App Store:
- **Identifiers → Device ID**: Third-party advertising, Analytics. Not linked to the user. **Used for tracking.**
- **Usage Data → Product interaction, Advertising data**: Third-party advertising, Analytics. Not linked. Advertising data: used for tracking.
- **Location → Coarse location** (from the IP address): Third-party advertising, Analytics. Not linked.
- **Diagnostics → Crash data, Performance data, Other diagnostic data**: Analytics. Not linked.
- Nothing else: the app has no accounts, no analytics of its own, no contacts, photos or precise location.
