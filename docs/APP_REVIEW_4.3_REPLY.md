# Reply to App Review: Guidelines 4.3 and 4.2.6 (Adadi)

Paste the English text below into App Store Connect → Adadi → App Review
(Resolution Center) → Reply. Do **not** resubmit; Apple asks for a reply
when the app is not spam. Answer 5 lists Shah Dozd Vazir, Tiaro and Mafia God;
add or remove apps to match what is on this developer account. Keep the
paragraph about submitting several apps together the same in every reply.

---

Hello, and thank you for the review. I believe Adadi is not a duplicate, not an opportunistic variant and not built from a template, so I am replying instead of resubmitting. My answers:

**1. What the app does and the problem it solves**

Adadi is a math crossword: a grid where every row and every column is an equation (for example 7 × 6 = 42), crossing each other like the words of a crossword. The player drags number tiles from a bank into the empty cells until every equation is true at once. It turns mental arithmetic, which most people stop practising after school, into a short daily puzzle that rewards reasoning instead of speed alone.

Every puzzle is made by my own generator and checked by my own solver:

- Each puzzle has exactly one solution, and the tile bank includes near-miss decoys (±1, swapped digits, doubled values), so it cannot be solved by trial and error alone.
- Difficulty is set per age group (13–15, 16–17, 18+) and level: number ranges, which operators appear, and how dense the grid is. For the youngest group, multiplication stays within the 12 × 12 table.

There is a new daily puzzle at four difficulties with a streak calendar, and endless levels. Hints are earned, never bought. There are certificates for streaks and milestones, Game Center leaderboards, and a backup (iCloud plus a recovery code).

**2. Intended users**

Teenagers and adults (the app is 13+ and has an age gate) who like number puzzles or want to keep their mental arithmetic sharp: students practising times tables and order of operations, parents, and adults who play a daily puzzle on the way to work. Besides English, it is made for speakers of Arabic, Persian and Urdu, with right-to-left text and a choice of Western or local digits.

**3. The need it addresses**

- **The puzzle itself.** A crossword built entirely of crossing equations, generated fresh and guaranteed to have one answer, is different from a sudoku, a KenKen or a plain arithmetic drill: the crossings make every number depend on two equations at once.
- **Age-appropriate difficulty.** The rules change with the player's age group, not only with "easy/hard".
- **Languages and digits.** Full Arabic, Persian and Urdu (right to left, local digits, a Persian solar calendar for the daily streak) as well as English. Math puzzle apps are rarely localised for these players.
- **Fair and free.** No ads and no purchases. Hints come from friends who open a challenge the player shared; each friend gets the very same puzzle to beat the sender's time.

**4. Beta testing and feedback applied**

I am an individual developer working alone, so I did the testing myself: I installed each TestFlight build on my iPhone, and Android test builds on my Android phone, and played daily puzzles and levels in every language. An automated "player journey" test also runs the whole app on an Android emulator for every change. Problems I found and fixed before the build under review:

- An early Android build installed but did not open on my phone; I traced and fixed the start-up crash.
- On iPhone, digits were drawn with the emoji font ("1 0 0 %"), so I removed that font fallback.
- "Invite" only copied the link on iPhone instead of opening the share sheet, so I fixed sharing.
- Small phones cut off parts of the menu (found by the emulator test), so the menu now fits on one screen.
- Hard and expert boards had cells too small to tap, so I narrowed the operator rows and added pinch zoom.
- The digit setting appeared in English, where it did nothing, so it is now shown only for languages with their own digits.
- Restarting a puzzle could be used to get 3 stars after seeing the answers, so restart now keeps the clock, mistakes and hints.
- I tried several colour themes and chose the calm turquoise one now in the app.
- I removed all ads and purchases from the App Store version, so it is completely free.

**5. Standalone or part of a suite**

Adadi is a standalone game. This is my personal developer account; Espadna is the name I publish my games under. I built my apps separately, one at a time, each with its own code, rules and art. Once my developer account was ready, I submitted the ones that were finished within a short time, which is why several reached review together. I will space out future submissions. My other apps on the App Store:

- Tiaro: a daily logic puzzle about placing crowns on a coloured grid. There are no numbers and no arithmetic.
- Shah Dozd Vazir: a hidden-role party game for 4 to 6 people around one phone.
- Mafia God: a narrator tool for the in-person Mafia party game.

Adadi is the only one about arithmetic, and the only one with an age gate and age-based difficulty.

**6. Could it be an in-app purchase or an addition to another app?**

No. The nearest app is Tiaro, but it is a different puzzle with different rules, controls, audience and engine. Tiaro is a logic grid with no numbers, for adults who like daily logic puzzles. Adadi is an arithmetic crossword with drag-and-drop number tiles, decoys and age groups from 13 up. Players search for "math puzzle" and "logic puzzle" separately, and a teenager practising times tables would not look for a crown puzzle.

**7. Code, frameworks or assets shared with my other apps**

None of significance. Adadi is its own Flutter codebase. Its puzzle engine (layout builder, filler, unique-solution solver, decoys, seeded daily puzzles; over 80 engine tests) and all its screens, art and texts were written for Adadi. Its Game Center and iCloud code is in its own AppDelegate. The only things in common with my other apps are the open-source font Vazirmatn and my brand name.

**8. Codebase, SDK or content shared with a third party**

No, beyond standard frameworks: Flutter and standard open-source Flutter packages (storage, sharing, sound), plus Apple's GameKit. No template, white-label product or app-generation service was used. The puzzles come from my own generator; the texts and art are my own.

**9. Created for a client or third party?**

No. I am an individual developer and this is my own account; Espadna is just my brand name, not a company or a client. The idea, the content and the branding are mine. Nothing was supplied by a client, partner or template provider.

Thank you for taking another look. I am happy to provide a short video of the app in use if that helps.

---
