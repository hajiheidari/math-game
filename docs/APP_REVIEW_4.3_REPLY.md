Hello, and thank you for the review. Adadi is my own original work, not a copy or a template, so I am replying instead of resubmitting.

1. What it does
Adadi is a math crossword: every row and every column is an equation (for example 7 x 6 = 42), and the equations cross like the words of a crossword. The player drags number tiles from a bank into the empty cells until every equation is true at once.

Every puzzle comes from my own generator and is checked by my own solver:
- Each puzzle has exactly one solution.
- The tile bank includes near-miss decoys, so trial and error alone does not work.
- Difficulty follows the player's age group (13-15, 16-17, 18+) and level: the number ranges, the operators and how dense the grid is.

There is a daily puzzle at four difficulties with a streak calendar, plus endless levels.

2. Users
Teenagers and adults (the app is 13+, with an age gate) who like number puzzles or want to keep their mental arithmetic sharp. Besides English, it is made for Arabic, Persian and Urdu speakers, with right-to-left text and a choice of Western or local digits.

3. What is different
- A crossword built entirely of crossing equations, freshly generated with one guaranteed answer. Each number depends on two equations at once, which is different from sudoku or arithmetic drills.
- Difficulty that adapts to the player's age group.
- Full Arabic, Persian and Urdu, with a Persian solar calendar for the streak.
- No ads and no purchases. Hints come from friends who open a challenge the player shared, and each friend plays the same puzzle against the sender's time.

4. Testing
I am an individual developer and tested it myself on my iPhone, in the web version and on Android, over many builds. An automated player-journey test also runs the whole app on an Android emulator for every change. That testing led to these fixes:
- a start-up crash on Android
- digits drawn with the emoji font on iPhone
- an invite button that only copied the link on iPhone
- a menu cut off on small phones
- cells too small on hard boards (now narrower operator rows and pinch zoom)
- restart no longer gives 3 stars after seeing the answers

5. Standalone or suite
Standalone. This is my personal developer account; Espadna is my brand name. My only published app is Dorehami: Pantomime & Heads Up, a charades and word-guessing game. I built my other games over the past weeks, one at a time, each with its own code, rules and art, and submitted the finished ones close together. That is why Adadi, Tiaro, Mafia God and Shah Dozd Vazir reached review at the same time. I will space out future submissions. Adadi is the only one about arithmetic and the only one with age-based difficulty.

6. Could it be part of another app?
No. The nearest is Tiaro, a logic puzzle about placing crowns on a coloured grid, with no numbers. Adadi is an arithmetic crossword with number tiles, decoys and age groups. They have different rules, controls, engines and audiences, and players search for math puzzles and logic puzzles separately.

7. Code shared with my other apps
None of significance. Adadi is its own Flutter codebase. Its puzzle engine (with over 80 tests), screens, art and texts were written for it. Its Game Center and iCloud code is its own. Only the open-source font Vazirmatn and my brand name are in common.

8. Third-party code
Only standard frameworks: Flutter, open-source Flutter packages and Apple's GameKit. No template or app-generation service was used. The puzzles, texts and art are my own.

9. Client or third party
No. I am an individual developer, and the idea, content and branding are mine. Nothing was supplied by a client, partner or template provider.

Thank you for taking another look. I am happy to send a short video of the app in use.
