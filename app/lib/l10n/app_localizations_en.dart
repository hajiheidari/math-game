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
  String get watchAdForHint => 'Watch an ad for a hint';

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
  String get digitsAuto => 'Automatic';

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
  String get removeAds => 'Remove ads';

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
  String get noHintsAvailable =>
      'No hints available right now. Try again in a moment.';

  @override
  String get watchAd => 'Watch ad';

  @override
  String get extraLife => 'Watch an ad for one more mistake';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get adsRemoved => 'Ads removed. Thank you!';

  @override
  String get privacyChoices => 'Privacy choices';

  @override
  String get purchaseUnavailable => 'Purchases aren\'t available right now.';

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
  String get shareResult => 'Show your friends';

  @override
  String get shareBeatMe => 'Can you beat me?';

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
  String get friendHintsTitle => 'Free hints from friends';

  @override
  String friendHintsBody(String max) {
    return 'Share your link or your result. Every friend who opens it gives you a hint (up to $max a day).';
  }

  @override
  String friendHintsToday(String count, String max) {
    return 'Today: $count/$max';
  }

  @override
  String friendHintsReceived(String count) {
    return 'Your friends sent you hints: +$count';
  }

  @override
  String get shareForHints => 'Every friend who opens it gives you a hint.';

  @override
  String get invite => 'Invite';
}
