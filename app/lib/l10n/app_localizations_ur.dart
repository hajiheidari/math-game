// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'عددی';

  @override
  String get ageGateTitle => 'آپ کی عمر کتنی ہے؟';

  @override
  String get ageGatePickerHint => 'اپنی عمر منتخب کریں';

  @override
  String get ageGateContinue => 'جاری رکھیں';

  @override
  String ageGateBlocked(String minAge) {
    return 'یہ ایپ $minAge سال اور اس سے زیادہ عمر کے افراد کے لیے ہے۔';
  }

  @override
  String get menuLevels => 'مراحل';

  @override
  String get menuDaily => 'روزانہ پہیلی';

  @override
  String get ageGroup => 'عمر کا گروپ';

  @override
  String bandRange(String from, String to) {
    return '$from تا $to سال';
  }

  @override
  String bandAndUp(String from) {
    return '$from سال اور زیادہ';
  }

  @override
  String get difficultyEasy => 'آسان';

  @override
  String get difficultyMedium => 'درمیانہ';

  @override
  String get difficultyHard => 'مشکل';

  @override
  String get difficultyExpert => 'ماہر';

  @override
  String levelNumber(String number) {
    return 'مرحلہ $number';
  }

  @override
  String mistakesCounter(String count, String max) {
    return 'غلطیاں: $max میں سے $count';
  }

  @override
  String get pause => 'وقفہ';

  @override
  String get resume => 'جاری رکھیں';

  @override
  String get undo => 'واپس کریں';

  @override
  String get restart => 'دوبارہ شروع کریں';

  @override
  String get sortBank => 'ترتیب دیں';

  @override
  String get hint => 'اشارہ';

  @override
  String get tiles => 'ٹائلیں';

  @override
  String get levelComplete => 'مرحلہ مکمل!';

  @override
  String get outOfMistakes => 'غلطیوں کی حد ختم';

  @override
  String get nextLevel => 'اگلا مرحلہ';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String streakDays(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText دن کا تسلسل',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'ترتیبات';

  @override
  String get language => 'زبان';

  @override
  String get digits => 'ہندسے';

  @override
  String get digitsWestern => 'انگریزی';

  @override
  String get digitsNative => 'اردو';

  @override
  String get sound => 'آواز';

  @override
  String get haptics => 'ارتعاش';

  @override
  String get privacyPolicy => 'رازداری کی پالیسی';

  @override
  String get contactSupport => 'سپورٹ سے رابطہ';

  @override
  String get previewTitle => 'ڈیزائن کا پیش منظر';

  @override
  String get showSolution => 'حل دکھائیں';

  @override
  String get time => 'وقت';

  @override
  String get mistakesLabel => 'غلطیاں';

  @override
  String get paused => 'رکا ہوا';

  @override
  String get play => 'کھیلیں';

  @override
  String get menu => 'مینو';

  @override
  String get chooseDifficulty => 'مشکل کی سطح منتخب کریں';

  @override
  String equationsRange(String from, String to) {
    return '$from تا $to مساواتیں';
  }

  @override
  String get continuePlaying => 'جاری رکھیں';

  @override
  String levelsCompleted(String count) {
    return 'مکمل: $count';
  }

  @override
  String get dailyComplete => 'آج کی پہیلی حل ہو گئی!';

  @override
  String get calendar => 'کیلنڈر';

  @override
  String bestStreak(String count) {
    return 'بہترین تسلسل: $count';
  }

  @override
  String get privacyChoices => 'رازداری کے انتخاب';

  @override
  String get tutorialTitle => 'کھیلنے کا طریقہ';

  @override
  String get tutorialStep1 =>
      'ٹائلوں میں سے کوئی عدد خالی خانے میں کھینچیں، یا پہلے عدد اور پھر خانے پر ٹیپ کریں۔ مساوات درست ہونی چاہیے۔';

  @override
  String get tutorialStep2 =>
      'کچھ خانے دو مساواتوں کا حصہ ہیں: افقی اور عمودی۔ عدد کو دونوں کو درست کرنا ہوگا۔';

  @override
  String get tutorialWrong =>
      'بالکل نہیں۔ کھیل میں غلط ٹائل ایک غلطی شمار ہوتی ہے۔ کوئی اور آزمائیں۔';

  @override
  String get tutorialDone => 'آپ تیار ہیں!';

  @override
  String get tutorialDoneBody =>
      'قطاریں بائیں سے دائیں اور کالم اوپر سے نیچے پڑھے جاتے ہیں۔ پھنس گئے؟ اشارہ استعمال کریں۔';

  @override
  String get startPlaying => 'کھیلنا شروع کریں';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get shareResult => 'دوستوں کو چیلنج کریں';

  @override
  String get shareBeatMe => 'کیا آپ میرا وقت ہرا سکتے ہیں؟';

  @override
  String get shareNoMistakes => 'کوئی غلطی نہیں';

  @override
  String get shareCopied => 'کاپی ہو گیا! جہاں چاہیں بھیجیں۔';

  @override
  String get inviteFriends => 'دوستوں کو دعوت دیں';

  @override
  String inviteMessage(String link) {
    return 'میرے ساتھ عددی کھیلیں: ریاضی کی مساواتوں سے بنی کراس ورڈ 🧮 $link';
  }

  @override
  String friendHintsToday(String count, String max) {
    return 'آج دوستوں سے: $count/$max';
  }

  @override
  String get shareForHints => 'جو دوست اسے کھولے گا، آپ کو ایک سکہ ملے گا۔';

  @override
  String get invite => 'دعوت دیں';

  @override
  String get zoomIn => 'بڑا کریں';

  @override
  String get zoomOut => 'عام سائز';

  @override
  String get coinsTitle => 'اشاروں کے لیے سکے';

  @override
  String coinsBody(String max) {
    return 'ہر اشارہ ایک سکے کا ہے۔ جو دوست آپ کا چیلنج یا دعوت کا لنک کھولے، آپ کو ایک سکہ ملے گا (دن میں $max تک)۔';
  }

  @override
  String get watchAdForCoin => 'اشتہار دیکھیں: +1 سکہ';

  @override
  String friendCoinsReceived(String count) {
    return 'آپ کے دوستوں نے سکے بھیجے: +$count';
  }

  @override
  String get challengeTitle => 'چیلنج';

  @override
  String challengeToBeat(String time) {
    return 'ہرانے کا وقت: $time';
  }

  @override
  String get challengeWon => 'آپ دوست سے آگے نکل گئے! 🎉';

  @override
  String get challengeLost => 'اس بار دوست تیز تھا۔ دوبارہ؟';

  @override
  String get challengeTie => 'برابر!';

  @override
  String get challengeYou => 'آپ';

  @override
  String get challengeFriend => 'دوست';

  @override
  String get challengeReceived => 'آپ کو چیلنج ملا ہے!';

  @override
  String challengeBody(String time) {
    return 'دوست نے یہ پہیلی $time میں حل کی۔ کیا آپ اس سے تیز حل کر سکتے ہیں؟';
  }

  @override
  String get challengeStart => 'شروع';

  @override
  String get later => 'بعد میں';

  @override
  String get leaderboards => 'لیڈر بورڈ';

  @override
  String get certificates => 'سرٹیفکیٹ';

  @override
  String get certNameLabel => 'سرٹیفکیٹ پر آپ کا نام';

  @override
  String get certNameHelp =>
      'اختیاری۔ صرف آپ کے فون پر اور آپ کی شیئر کی ہوئی چیزوں میں۔';

  @override
  String get certHowTo =>
      'حل کرتے رہیں، اگلے سرٹیفکیٹ حاصل کریں اور اسٹوری میں شیئر کریں۔';

  @override
  String get certShare => 'اسٹوری میں شیئر کریں';

  @override
  String get certShareLine => 'کیا آپ بھی حاصل کر سکتے ہیں؟ عددی مفت کھیلیں:';

  @override
  String get certEarned => 'آپ نے سرٹیفکیٹ حاصل کیا! 🎉';

  @override
  String get certOpen => 'کھولیں';

  @override
  String get certCertificate => 'اعزازی سند';

  @override
  String get certOfAchievement => 'کامیابی کا اعتراف';

  @override
  String get certPresentedTo => 'فخر کے ساتھ پیش ہے';

  @override
  String get certNoName => 'عددی کا ایک کھلاڑی';

  @override
  String get certTagline => 'عددی · ریاضی کراس ورڈ';

  @override
  String certStreakTitle(String n) {
    return '$n دن مسلسل';
  }

  @override
  String certStreakBody(String n) {
    return 'روزانہ پہیلی $n دن مسلسل حل کرنے پر۔';
  }

  @override
  String certLevelsTitle(String n) {
    return '$n لیول';
  }

  @override
  String certLevelsBody(String n) {
    return 'عددی کے $n لیول مکمل کرنے پر۔';
  }

  @override
  String get certExpertTitle => 'ماہر ذہن';

  @override
  String certExpertBody(String n) {
    return '$n ماہر لیول مکمل کرنے پر۔';
  }

  @override
  String get certAllDailyTitle => 'آج کا چیمپئن';

  @override
  String get certAllDailyBody => 'ایک دن میں چاروں روزانہ پہیلیاں حل کرنے پر۔';

  @override
  String get backupTitle => 'بیک اپ';

  @override
  String get backupAuto =>
      'آپ کی پیش رفت iCloud (آئی فون، آئی پیڈ) یا گوگل بیک اپ (اینڈرائیڈ) میں بھی محفوظ رہتی ہے۔';

  @override
  String get backupCodeLabel => 'آپ کا ریکوری کوڈ';

  @override
  String get backupHelp =>
      'یہ کوڈ سنبھال کر رکھیں۔ نئے فون یا ویب پر اسے نیچے درج کریں تاکہ آپ کے لیول، ستارے، سلسلہ اور سکے واپس آ جائیں۔';

  @override
  String get backupCopy => 'کوڈ کاپی کریں';

  @override
  String get backupCopied => 'کوڈ کاپی ہو گیا۔';

  @override
  String get backupGetting => 'کوڈ حاصل کیا جا رہا ہے…';

  @override
  String get backupOffline => 'کنکشن نہیں ہے۔ آن لائن ہو کر دوبارہ کوشش کریں۔';

  @override
  String get backupRestoreTitle => 'کوڈ سے بحال کریں';

  @override
  String get backupRestore => 'بحال کریں';

  @override
  String get backupBadCode => 'یہ کوڈ مکمل نہیں۔ اس میں 12 حروف اور ہندسے ہیں۔';

  @override
  String get backupConfirm =>
      'بیک اپ اس فون کی پیش رفت میں شامل ہو جائے گا (یہاں سے کچھ نہیں مٹے گا)۔ جاری رکھیں؟';

  @override
  String get backupYesRestore => 'ہاں، بحال کریں';

  @override
  String get backupDone => 'ہو گیا! آپ کی پیش رفت واپس آ گئی۔';

  @override
  String get backupNotFound => 'اس کوڈ کا کوئی بیک اپ نہیں ملا۔';
}
