# Changelog

## 0.8.4 — Battery: stop per-frame redraws after sounds
- audioplayers' default position updater schedules a callback every frame while a player is
  "playing"; low-latency players (our sound effects) never report completion, so after the first
  sound the app redrew at 60 fps for the rest of the session. Found by the emulator journey test
  ("animation still running" at teardown). The updater is now disabled (position is unused).
- The emulator journey test now passes all steps: 23 screenshots from age gate to Urdu game.

## 0.8.3 — Small-phone layout fixes (found by the emulator journey test)
- Age screen: the age picker sized itself to the widest number, so the "Select your age" hint
  overflowed on 320 dp phones (en 26 px, fa 120 px, ur 88 px). Now fills the width.
- Daily win dialog: the streak line ("1-day streak") overflowed by 30 px on 320 dp phones; it
  now wraps.
- New `test/small_screen_test.dart`: age gate, tutorial, menu, level select, game, calendar,
  settings and the daily win dialog at 320 x 640 in en/fa/ar/ur, failing on any overflow.
- Journey test scrolls to off-screen targets (small emulator screen).

## 0.8.2 — Fix: release build crashed at launch
- Every release APK crashed before showing anything: R8 stripped WorkManager's Room database
  class (`WorkDatabase_Impl`, loaded by reflection; WorkManager comes with Google Mobile Ads).
  Found by running the APK on an Android 14 emulator in CI, where the new crash screen showed
  the stack trace. Fixed with keep rules in `app/android/app/proguard-rules.pro`.
- CI: `.github/workflows/emulator.yml` installs and launches the release APK on an Android 14
  (Google APIs) emulator on every push, uploads screenshots + logcat, and fails if the app
  crashes or exits.
- CI: full player-journey test on the emulator (`app/integration_test/app_flow_test.dart`):
  age gate, interactive tutorial, menu with real AdMob test ads starting, level 1 solved, level 2
  finished with a hint, daily puzzle, calendar, settings, then menu + game in fa/ar/ur. One
  screenshot per screen (artifact `smoke/flow/`). Locally without a device:
  copy it into `test/` and run with `--dart-define=ON_HOST=true`.

## 0.8.1 — On-screen error reports
- The 0.8.0 test APK installed on a Galaxy S23 Ultra (Android 14) but did not run. To find out
  why without a cable/logcat, errors are now shown on screen with Copy/Share:
  - Dart: `CrashGuard` (lib/app/crash_guard.dart) catches startup, framework and async errors
    and shows the report over the app (Continue dismisses non-fatal ones).
  - Native: `AdadiApplication` catches uncaught Android exceptions, also those before Flutter
    starts, and opens `CrashActivity` in a separate `:crash` process with the stack trace.
- 1 new test.

## 0.8.0 — Name and icon: Adadi
- The app is now **Adadi** (عددی / عددي, "numeric" in Persian, Arabic and Urdu). The working
  title NumCross was dropped because another math-crossword app already uses it on Google Play.
  In-app title per language; Android launcher label localized (`res/values-*/strings.xml`);
  iOS display name, web title and manifest updated.
- Bundle id / application id: `com.adadi.game` (Android namespace and MainActivity package moved).
- App icon: five tiles in a cross (+, ×, −, = around an amber 7). Source in `app/branding/*.svg`
  (glyphs drawn as shapes, no font); `node tool/make_icons.js` renders the iOS set, Android legacy
  + adaptive icons and web icons. The 1024 iOS icon has no alpha channel.
- Privacy page filled with the name. Internal code names (`numcross` package, `numcross/v1` seed
  namespace) are unchanged so daily puzzles stay the same.

## 0.7.2 — Urdu layout check
- Visual browser check of Urdu (Noto Nastaliq): stacked text overlapped (the levels heading ran
  into its subtitle), because Material's line heights are too short for Nastaliq. Urdu now gets
  a 1.9 line height on every theme text style (`AppLanguage.lineHeight`).
- Board numbers, operators and tiles in Urdu use Vazirmatn (`AppLanguage.numeralFont`):
  Nastaliq's digits sat low in the cells. Other languages are unchanged.
- 1 new test.

## 0.7.1 — Bundled fonts
- Vazirmatn (Persian, Arabic) and Noto Nastaliq Urdu (Urdu), from the official google/fonts
  repo, SIL OFL 1.1; theme font follows the language. OFL texts are bundled and shown on the
  licenses page.

## 0.7.0 — Step 7: polish
- Interactive tutorial (2 mini puzzles: single equation incl. a wrong-tile explanation, then a
  crossing) before the first game; skippable; replay from Settings → How to play. Ads/consent
  start only after it.
- Animations: placed tile pops in, wrong cell shakes, result stars pop in one by one. All skipped
  when the OS asks for reduced motion.
- Sounds (tap, correct, wrong, win) synthesized by `app/tool/make_sounds.js` (no third-party
  audio, 44 KB total) via `audioplayers`; vibration via haptics. Both switchable in Settings.
- Game board/tile bank moved to `game/game_widgets.dart` (shared by game and tutorial).
- 5 new tests (tutorial flow + skip in fa/ar/ur, sound/vibration settings).

## 0.6.0 — Step 6: ads with consent, IAP
- AdMob (`google_mobile_ads`) behind an `AdService` interface; web/desktop/tests run ad-free.
- Start order, after onboarding and not on the first frame (menu + 1 s): Google UMP consent →
  iOS ATT prompt → SDK init. Max ad content rating **T** for every band; 13–17 get teen
  treatment, 13–15 are tagged under the age of consent. "Privacy choices" in Settings when UMP
  requires it.
- Hints: coins first (start with 3; +1 per level, +2 per daily), then a rewarded ad.
- Lost level: one extra life per level via a rewarded ad.
- Interstitial only when pressing "Next level": never during the first 3 won levels, then at
  most once every 3 (shown after levels 4, 7, 10...). Never in daily puzzles.
- "Remove ads" non-consumable (`in_app_purchase`, product `remove_ads`) + Restore purchases;
  removes interstitials, rewarded ads stay optional. Cached locally.
- Privacy policy link in Settings (URL placeholder), draft policy in `docs/privacy-policy.md`,
  `docs/RELEASE_CHECKLIST.md` for everything needing store/AdMob accounts.
- No analytics at all. All ids are Google TEST ids.
- 10 new tests (pacing 4/7/10, remove ads, coins, audience, start timing, rewarded hint,
  no-ad message, extra life once).

## 0.5.0 — Step 5: Daily Puzzle + streak
- Daily card on the menu: today's date, streak, one button per difficulty (seed = date + band +
  difficulty); solved ones are disabled until tomorrow. Unfinished dailies resume (per-day slot).
- Streak = consecutive days with at least one solved daily, kept alive until today ends; best
  streak; stored globally (`daily` = {date: bitmask of difficulties}) so a band change keeps it.
- Calendar screen: month grid of solved days, today ringed, month navigation.
- Persian uses the Solar Hijri (Jalali) calendar for dates and the calendar (week starts
  Saturday); other languages use Gregorian with localized month names.
- Saved games are now per slot (`game/level/...`, `game/daily/...`).
- 10 new tests (Jalali conversion incl. 30-year round trip, streak logic, daily flow, fa/ar/ur).

## 0.4.0 — Step 4: Levels mode + local progress
- Progress per band x difficulty: next level and best stars per level (`progress/<band>/<diff>`,
  a digit string like "3321"). Levels unlock in order; replays only improve stars.
- Unfinished level is saved (tiles, hints, mistakes, time) on every move, on background and on
  leaving; reopening the level resumes it. Lost/won levels clear it. Snapshots that don't fit the
  puzzle (generator change) are ignored.
- Level select screen: "Continue · Level N" + grid of completed levels with stars (replay).
- Menu cards show next level and total stars.
- 7 new tests (store, snapshot round trip, full win → next level → resume after relaunch).

## 0.3.0 — Step 3: age gate, bands and difficulties from config
- First-launch age gate: neutral dropdown (5–99), nothing preselected, Continue disabled until
  chosen, language switch available. Under 13 → "This app is for ages 13 and up", stored as a
  single `blocked` flag (all other data wiped); survives relaunch, no way back.
- 13+ stores only the band id (`band`), never the age.
- Menu: the player's band with Easy/Medium/Hard/Expert cards (equation range, operators) → game.
- Settings: language, digits, age group (13+ bands only). Design preview kept as a debug-only entry.
- Language/digits persist; first run follows the device language when supported.
- Added `shared_preferences`. 8 new tests (controller + age gate/menu/settings widget flows).

## 0.2.0 — Step 2: game screen
- Playable level: drag & drop tiles onto blanks, or tap tile then cell (or cell then tile).
- Instant check: correct tile stays; wrong tile = mistake, red flash, tile returns to the bank.
  Mistake limit from config loses the level.
- Timer (shown only where the config says so; always counted for stars), pause (hides the board;
  auto-pause when the app goes to background), undo, restart, sort bank, hint (fills the selected
  cell or the first open one; free for now, ads/coins in step 6).
- Result dialog: stars, time, mistakes; Next level / Try again / Menu.
- `GameController` holds all rules without widgets; 11 controller tests + 7 widget tests
  (solve in all 4 languages, drag & drop, pause, lose + retry).

## 0.1.0 — Step 1: generator, solver, tests (+ localization foundation)
- `numcross_engine` package: bands/difficulty config (13–15, 16–17, 18+ x Easy/Medium/Hard/Expert),
  layout builder, filler, unique-solution solver, generator with decoys, seeded Levels and Daily
  puzzles, stars.
- 86 engine tests: equation validity, band rules (no negatives, exact division, 12x12 tables),
  uniqueness, deterministic seeding with golden values, <300 ms generation.
- Flutter app shell with English, Persian, Arabic, Urdu (RTL), digit setting (Western/local),
  LTR board inside RTL UI, design-preview screen. 8 app tests (ARB key parity, digits, RTL rendering).
