# Next update: open questions

Things Amir asked to look at for the version after 0.13.0 (the first App Store release).

## Must: never lose a player's progress (Amir, 2026-10-12)

Adadi 0.13.0 keeps everything only in the app's local storage (shared_preferences): deleting the
app or changing phones loses levels, stars, streak and hints. The next update adds, without any
sign-up:
1. **iPhone / iPad: iCloud.** Mirror the save into iCloud key-value storage
   (`NSUbiquitousKeyValueStore`, up to 1 MB; ours is a few KB): restored automatically after a
   reinstall and synced to the player's other Apple devices. Needs the iCloud (key-value)
   capability on the App ID and the entitlement in `ios/Runner/Runner.entitlements`.
2. **Android: Google backup.** Android Auto Backup restores app data on reinstall / a new phone
   when the player's Google backup is on. Make it explicit (`allowBackup`, `dataExtractionRules`
   for Android 12+ device-to-device transfer) and check the shared_preferences file is included.
   Not reliable for Cafe Bazaar players in Iran (Google services), hence 3.
3. **Every platform: recovery code**, as in Tiaro (Settings → Backup; Tiaro:
   `src/services/invites.ts`, `keychain.native.ts`, `app/settings.tsx`): the progress snapshot is
   saved on our server (site/worker.js, the Durable Object already used for friend hints) under a
   secret code shown as XXXX-XXXX-XXXX; entering it on another phone or the web brings everything
   back. On iPhone the key also goes into the keychain, which survives a reinstall.
Merging rule when two saves meet: keep the best of each (more levels, more stars, longer streak,
every solved daily), never overwrite with less.

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
