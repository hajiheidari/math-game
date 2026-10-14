// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Adadi';

  @override
  String get ageGateTitle => 'How old are you?';

  @override
  String get ageGatePickerHint => 'Select your age';

  @override
  String get ageGateContinue => 'Continue';

  @override
  String ageGateBlocked(String minAge) {
    return 'This app is for ages $minAge and up.';
  }

  @override
  String get menuLevels => 'Levels';

  @override
  String get menuDaily => 'Daily Puzzle';

  @override
  String get ageGroup => 'Age group';

  @override
  String bandRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String bandAndUp(String from) {
    return '$from+';
  }

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String levelNumber(String number) {
    return 'Level $number';
  }

  @override
  String mistakesCounter(String count, String max) {
    return 'Mistakes: $count/$max';
  }

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get undo => 'Undo';

  @override
  String get restart => 'Restart';

  @override
  String get sortBank => 'Sort';

  @override
  String get hint => 'Hint';

  @override
  String get tiles => 'Tiles';

  @override
  String get levelComplete => 'Level complete!';

  @override
  String get outOfMistakes => 'Out of mistakes';

  @override
  String get nextLevel => 'Next level';

  @override
  String get tryAgain => 'Try again';

  @override
  String streakDays(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText-day streak',
      one: '$countText-day streak',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get digits => 'Digits';

  @override
  String get digitsWestern => 'Western';

  @override
  String get digitsNative => 'Local';

  @override
  String get sound => 'Sound';

  @override
  String get haptics => 'Vibration';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get previewTitle => 'Design preview';

  @override
  String get showSolution => 'Show solution';

  @override
  String get time => 'Time';

  @override
  String get mistakesLabel => 'Mistakes';

  @override
  String get paused => 'Paused';

  @override
  String get play => 'Play';

  @override
  String get menu => 'Menu';

  @override
  String get chooseDifficulty => 'Choose a difficulty';

  @override
  String equationsRange(String from, String to) {
    return '$from–$to equations';
  }

  @override
  String get continuePlaying => 'Continue';

  @override
  String levelsCompleted(String count) {
    return 'Completed: $count';
  }

  @override
  String get dailyComplete => 'Daily puzzle solved!';

  @override
  String get calendar => 'Calendar';

  @override
  String bestStreak(String count) {
    return 'Best streak: $count';
  }

  @override
  String get privacyChoices => 'Privacy choices';

  @override
  String get tutorialTitle => 'How to play';

  @override
  String get tutorialStep1 =>
      'Drag a number from the tiles into the empty box, or tap the number and then the box. The equation must be true.';

  @override
  String get tutorialStep2 =>
      'Some boxes belong to two equations: across and down. The number has to make both true.';

  @override
  String get tutorialWrong =>
      'Not quite. In the game, wrong tiles count as mistakes. Try another one.';

  @override
  String get tutorialDone => 'You\'re ready!';

  @override
  String get tutorialDoneBody =>
      'Rows read left to right, columns top to bottom. Stuck? Use a hint.';

  @override
  String get startPlaying => 'Start playing';

  @override
  String get skip => 'Skip';

  @override
  String get shareResult => 'Challenge your friends';

  @override
  String get shareBeatMe => 'Can you beat my time?';

  @override
  String get shareNoMistakes => 'No mistakes';

  @override
  String get shareCopied => 'Copied! Paste it anywhere.';

  @override
  String get inviteFriends => 'Invite friends';

  @override
  String inviteMessage(String link) {
    return 'Play Adadi with me: a crossword made of math equations 🧮 $link';
  }

  @override
  String friendHintsToday(String count, String max) {
    return 'From friends today: $count/$max';
  }

  @override
  String get shareForHints => 'Every friend who opens it gives you a coin.';

  @override
  String get invite => 'Invite';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get coinsTitle => 'Coins for hints';

  @override
  String coinsBody(String max) {
    return 'Each hint costs one coin. Every friend who opens your challenge or invite link gives you a coin (up to $max a day).';
  }

  @override
  String get watchAdForCoin => 'Watch an ad: +1 coin';

  @override
  String friendCoinsReceived(String count) {
    return 'Your friends sent you coins: +$count';
  }

  @override
  String get challengeTitle => 'Challenge';

  @override
  String challengeToBeat(String time) {
    return 'Time to beat: $time';
  }

  @override
  String get challengeWon => 'You beat your friend! 🎉';

  @override
  String get challengeLost => 'Your friend was faster this time. Rematch?';

  @override
  String get challengeTie => 'It\'s a tie!';

  @override
  String get challengeYou => 'You';

  @override
  String get challengeFriend => 'Friend';

  @override
  String get challengeReceived => 'You got a challenge!';

  @override
  String challengeBody(String time) {
    return 'A friend solved this puzzle in $time. Can you beat it?';
  }

  @override
  String get challengeStart => 'Start';

  @override
  String get later => 'Later';

  @override
  String get leaderboards => 'Leaderboards';

  @override
  String get certificates => 'Certificates';

  @override
  String get certNameLabel => 'Your name on certificates';

  @override
  String get certNameHelp =>
      'Optional. Stays on your phone, only in what you share.';

  @override
  String get certHowTo =>
      'Keep solving to earn the next ones, then share them as a story.';

  @override
  String get certShare => 'Share as a story';

  @override
  String get certShareLine => 'Can you get one too? Play Adadi free:';

  @override
  String get certEarned => 'You earned a certificate! 🎉';

  @override
  String get certOpen => 'Open it';

  @override
  String get certCertificate => 'CERTIFICATE';

  @override
  String get certOfAchievement => 'OF ACHIEVEMENT';

  @override
  String get certPresentedTo => 'PROUDLY PRESENTED TO';

  @override
  String get certNoName => 'An Adadi player';

  @override
  String get certTagline => 'Adadi · Math crossword';

  @override
  String certStreakTitle(String n) {
    return '$n-Day Streak';
  }

  @override
  String certStreakBody(String n) {
    return 'for solving the Daily Puzzle $n days in a row.';
  }

  @override
  String certLevelsTitle(String n) {
    return '$n Levels';
  }

  @override
  String certLevelsBody(String n) {
    return 'for completing $n levels of Adadi.';
  }

  @override
  String get certExpertTitle => 'Expert Mind';

  @override
  String certExpertBody(String n) {
    return 'for completing $n Expert levels.';
  }

  @override
  String get certAllDailyTitle => 'Daily Champion';

  @override
  String get certAllDailyBody =>
      'for solving all four Daily Puzzles in one day.';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupAuto =>
      'Your progress is also kept in your iCloud (iPhone, iPad) or Google backup (Android).';

  @override
  String get backupCodeLabel => 'Your recovery code';

  @override
  String get backupHelp =>
      'Keep this code. On a new phone or the web, enter it below to get your levels, stars, streak and coins back.';

  @override
  String get backupCopy => 'Copy code';

  @override
  String get backupCopied => 'Code copied.';

  @override
  String get backupGetting => 'Getting your code…';

  @override
  String get backupOffline => 'No connection. Try again when you are online.';

  @override
  String get backupRestoreTitle => 'Restore from a code';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupBadCode =>
      'That code is not complete. It has 12 letters and digits.';

  @override
  String get backupConfirm =>
      'The backup is added to the progress on this device (nothing here is lost). Continue?';

  @override
  String get backupYesRestore => 'Yes, restore';

  @override
  String get backupDone => 'Done! Your progress is back.';

  @override
  String get backupNotFound => 'No backup was found for this code.';
}
