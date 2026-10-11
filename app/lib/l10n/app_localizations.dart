import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Adadi'**
  String get appTitle;

  /// No description provided for @ageGateTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get ageGateTitle;

  /// No description provided for @ageGatePickerHint.
  ///
  /// In en, this message translates to:
  /// **'Select your age'**
  String get ageGatePickerHint;

  /// No description provided for @ageGateContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get ageGateContinue;

  /// No description provided for @ageGateBlocked.
  ///
  /// In en, this message translates to:
  /// **'This app is for ages {minAge} and up.'**
  String ageGateBlocked(String minAge);

  /// No description provided for @menuLevels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get menuLevels;

  /// No description provided for @menuDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Puzzle'**
  String get menuDaily;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get ageGroup;

  /// No description provided for @bandRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to}'**
  String bandRange(String from, String to);

  /// No description provided for @bandAndUp.
  ///
  /// In en, this message translates to:
  /// **'{from}+'**
  String bandAndUp(String from);

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyExpert;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelNumber(String number);

  /// No description provided for @mistakesCounter.
  ///
  /// In en, this message translates to:
  /// **'Mistakes: {count}/{max}'**
  String mistakesCounter(String count, String max);

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @sortBank.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBank;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @tiles.
  ///
  /// In en, this message translates to:
  /// **'Tiles'**
  String get tiles;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level complete!'**
  String get levelComplete;

  /// No description provided for @outOfMistakes.
  ///
  /// In en, this message translates to:
  /// **'Out of mistakes'**
  String get outOfMistakes;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get nextLevel;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @watchAdForHint.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for a hint'**
  String get watchAdForHint;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{countText}-day streak} other{{countText}-day streak}}'**
  String streakDays(int count, String countText);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @digits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// No description provided for @digitsAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get digitsAuto;

  /// No description provided for @digitsWestern.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get digitsWestern;

  /// No description provided for @digitsNative.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get digitsNative;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get haptics;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get removeAds;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Design preview'**
  String get previewTitle;

  /// No description provided for @showSolution.
  ///
  /// In en, this message translates to:
  /// **'Show solution'**
  String get showSolution;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @mistakesLabel.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakesLabel;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @chooseDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Choose a difficulty'**
  String get chooseDifficulty;

  /// No description provided for @equationsRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} equations'**
  String equationsRange(String from, String to);

  /// No description provided for @continuePlaying.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuePlaying;

  /// No description provided for @levelsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed: {count}'**
  String levelsCompleted(String count);

  /// No description provided for @dailyComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily puzzle solved!'**
  String get dailyComplete;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak: {count}'**
  String bestStreak(String count);

  /// No description provided for @noHintsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No hints available right now. Try again in a moment.'**
  String get noHintsAvailable;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get watchAd;

  /// No description provided for @extraLife.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for one more mistake'**
  String get extraLife;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @adsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Ads removed. Thank you!'**
  String get adsRemoved;

  /// No description provided for @privacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get privacyChoices;

  /// No description provided for @purchaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases aren\'t available right now.'**
  String get purchaseUnavailable;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get tutorialTitle;

  /// No description provided for @tutorialStep1.
  ///
  /// In en, this message translates to:
  /// **'Drag a number from the tiles into the empty box, or tap the number and then the box. The equation must be true.'**
  String get tutorialStep1;

  /// No description provided for @tutorialStep2.
  ///
  /// In en, this message translates to:
  /// **'Some boxes belong to two equations: across and down. The number has to make both true.'**
  String get tutorialStep2;

  /// No description provided for @tutorialWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. In the game, wrong tiles count as mistakes. Try another one.'**
  String get tutorialWrong;

  /// No description provided for @tutorialDone.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready!'**
  String get tutorialDone;

  /// No description provided for @tutorialDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Rows read left to right, columns top to bottom. Stuck? Use a hint.'**
  String get tutorialDoneBody;

  /// No description provided for @startPlaying.
  ///
  /// In en, this message translates to:
  /// **'Start playing'**
  String get startPlaying;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Button on the win dialog that opens the share sheet (result card + text).
  ///
  /// In en, this message translates to:
  /// **'Show your friends'**
  String get shareResult;

  /// No description provided for @shareBeatMe.
  ///
  /// In en, this message translates to:
  /// **'Can you beat me?'**
  String get shareBeatMe;

  /// No description provided for @shareNoMistakes.
  ///
  /// In en, this message translates to:
  /// **'No mistakes'**
  String get shareNoMistakes;

  /// No description provided for @shareCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied! Paste it anywhere.'**
  String get shareCopied;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriends;

  /// No description provided for @inviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Play Adadi with me: a crossword made of math equations 🧮 {link}'**
  String inviteMessage(String link);

  /// No description provided for @friendHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Free hints from friends'**
  String get friendHintsTitle;

  /// No description provided for @friendHintsBody.
  ///
  /// In en, this message translates to:
  /// **'Share your link or your result. Every friend who opens it gives you a hint (up to {max} a day).'**
  String friendHintsBody(String max);

  /// No description provided for @friendHintsToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {count}/{max}'**
  String friendHintsToday(String count, String max);

  /// No description provided for @friendHintsReceived.
  ///
  /// In en, this message translates to:
  /// **'Your friends sent you hints: +{count}'**
  String friendHintsReceived(String count);

  /// No description provided for @shareForHints.
  ///
  /// In en, this message translates to:
  /// **'Every friend who opens it gives you a hint.'**
  String get shareForHints;

  /// Short share button on the menu's hints card.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
