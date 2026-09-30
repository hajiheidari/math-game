# NumCross — technical design

Math crossword for ages 13+ (iOS + Android, Flutter). Brief: `math-crossword-claude-code-prompt.md` v1.1.

## Repository layout

```
packages/numcross_engine/   Pure Dart: config, generator, solver, tests. No Flutter.
                            Reusable by a future kids' app (supply your own band table).
app/                        Flutter app (UI, localization, later: ads, IAP, storage).
docs/                       This file, changelog.
```

## Engine (`packages/numcross_engine`)

| File | Role |
|---|---|
| `lib/src/bands.dart` | **The tuning file.** All bands x difficulties and every knob. |
| `lib/src/config.dart` | Config types: `NumberRules`, `LayoutRules`, `DifficultyConfig`, `BandConfig`. |
| `lib/src/equation.dart` | Operators, exact arithmetic, `solveMissing`. |
| `lib/src/layout_builder.dart` | Grows a crossword of 5-cell equations `A op B = C`. |
| `lib/src/filler.dart` | Picks operators + numbers (randomised backtracking). |
| `lib/src/solver.dart` | Counts solutions for a given bank (stops at 2). |
| `lib/src/generator.dart` | Orchestration: layout → fill → carve blanks → decoys → verify. |
| `lib/src/rng.dart`, `seed.dart` | Platform-independent PRNG (Mulberry32) and seeds (FNV-1a). |
| `lib/src/scoring.dart` | Stars and mistake limit. |

### Generation pipeline

1. **Layout.** Start with one equation, then repeatedly add an equation that crosses an existing
   number cell (A, B or C). Like a word crossword: equations never touch side-by-side or run into
   each other. `crossingBias` favours placements that cross 2+ equations at once (loops, dense grids);
   a compactness factor keeps grids phone-sized (`maxRows` x `maxCols`).
2. **Fill.** Equations are filled breadth-first. Each equation picks its operator in weighted-random
   order and falls back to the others if none fits the numbers already fixed by crossings. That
   fallback is what makes dense 18+ grids fillable (fill failures went from ~100% to ~20% of tries).
3. **Carve.** Number cells are blanked one by one in random order; a blank is kept only if the
   solver still finds exactly one solution with the bank of removed values.
4. **Decoys.** Near-miss values (±1, ±2, ±10, reversed digits, x2) are added one at a time and kept
   only if the puzzle stays unique.
5. **Verify.** Final solver run must return exactly 1 solution equal to the stored one.

The solver checks plain arithmetic, not band rules: players only see numbers, so any arithmetically
valid second arrangement counts as ambiguity.

### Rules applied in every band
- Whole, non-negative numbers only; division always exact.
- No zeros (`minValue >= 1`) and no x1 / ÷1 by default. (The brief says 0–144 for 13–15; zero
  is excluded on purpose because `0 × ? = 0` has no unique answer.)
- 13–15: every x/÷ is inside the 12x12 times table, all numbers <= 144.

### Determinism
- `levelSeed(band, difficulty, level)` and `dailySeed(date, band, difficulty)` hash a string that
  includes `generatorNamespace` (`numcross/v1`). **Changing generator logic changes every level;**
  bump the namespace when you do that on purpose.
- Mulberry32 is implemented with 16-bit partial products, so VM and web give identical output;
  golden values are checked against the JavaScript reference in tests.

### Performance (Dart JIT, desktop, 30 levels per config)
Worst case under 120 ms; average 1–17 ms. Target was < 300 ms on-device, so no pre-generated packs
are needed. Re-check on a mid-range Android device during step 2.
Run `dart run bin/bench.dart` to measure; `dart run bin/preview.dart 18+ expert 7` to print a puzzle.

## App flow and storage (`app/lib/app`, `app/lib/screens`)

- `main.dart` picks the home screen from `AppController.gate`: age gate → blocked, or menu.
- `AppPrefs` (shared_preferences) is the only storage. Keys: `band`, `language`, `digits`;
  `blocked` alone after an under-13 answer. The age is never written anywhere.
- Changing the band in Settings is limited to configured bands, all of which are 13+.

## Game screen (`app/lib/game`)

- `game_controller.dart` — all rules, no widgets: placing, mistakes, win/lose, undo, hint, sort,
  pause, clock. Unit tested.
- `game_screen.dart` — UI only. A 1 s `Timer` feeds `tick()`; app lifecycle changes auto-pause.
- `board_view.dart` — `BoardGrid` (layout, always LTR) + `CellFace` (cell look per `CellTone`).
- A tile is checked against the stored unique solution by **value**, so identical tiles are
  interchangeable. Correct tiles lock; wrong ones count a mistake and go back to the bank.
- Undo reverts the player's last correct placement (mistakes are not refunded, hints can't be
  undone). Hints don't cost stars; they will cost a coin or a rewarded ad (step 6).

## Localization (`app/lib/i18n`, `app/lib/l10n`)

- Flutter `gen-l10n` with ARB files: `app_en.arb` (template), `app_fa.arb`, `app_ar.arb`, `app_ur.arb`.
- **Adding a language:** copy `app_en.arb` → `app_<code>.arb`, translate, add one `AppLanguage`
  entry in `lib/i18n/languages.dart`. Tests fail if an ARB file has missing/extra keys or isn't
  registered.
- RTL comes from Flutter automatically for fa/ar/ur (whole UI mirrors).
- **The puzzle grid is always LTR** (`BoardView` wraps itself in `Directionality.ltr`). Equations are
  written left-to-right in Persian/Arabic/Urdu school math too, and mirroring would turn
  `12 − 5 = 7` into `7 = 5 − 12`. Vertical equations read top to bottom in every language.
- **Digits:** numbers are ints everywhere; only display changes. Setting = Automatic / Western /
  Local. Automatic uses the language default: en → 0-9, fa → ۰-۹, ar → ٠-٩, ur → 0-9 (Western
  digits are the norm in Urdu apps; ۰-۹ available as Local).
- Numbers are never passed into ARB strings as ints (intl would format them its own way); callers
  pass pre-formatted text (`LocaleController.n(value)`). Plurals take the int for selection plus a
  `countText` for display.
- Mixed text like "13–15" or "18+" is not safe in RTL (bidi reorders it), so such labels are
  localized strings (`bandRange`, `bandAndUp`).
- Fonts: system fonts for now. Step 7: bundle Vazirmatn (fa/ar) and Noto Nastaliq Urdu (ur).

## Build environment notes
Google storage is geo-blocked on this machine; Flutter uses the official China mirror:
```
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
PUB_HOSTED_URL=https://pub.flutter-io.cn
```
Flutter SDK: `E:\flutter` (stable 3.47.5).
