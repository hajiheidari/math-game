# Next update: open questions

Things Amir asked to look at for the version after 0.13.0 (the first App Store release).

## Compete with friends, or play alone? (Amir, 2026-10-11)

Tiaro has a "challenge a friend" mode: the shared link opens the same puzzle for the friend, who
plays it against the sender's time (both times on the win card; Tiaro: `src/app/c/[code].tsx`,
`encodeChallenge` / `decodeChallenge`, `?vs=<seconds>`). Adadi today is solo: the share card only
says "Can you beat me?" and links to the game, and friends who open it earn the sender a hint.

Before the next update, compare the two and decide whether Adadi should get a challenge mode:
- what the friend sees: the exact same puzzle (seeded: `numcross/v1` + band/difficulty/level or the
  daily date are enough to rebuild it) and the sender's time to beat;
- whether it fits with "hints from friends" (a challenge link would still carry the invite code);
- data from both apps once they are live (shares, link opens, installs) if available.
