// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'NumCross';

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
  String get watchAdForHint => 'اشارے کے لیے اشتہار دیکھیں';

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
  String get digitsAuto => 'خودکار';

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
  String get removeAds => 'اشتہارات ہٹائیں';

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
  String get noHintsAvailable =>
      'ابھی کوئی اشارہ دستیاب نہیں۔ تھوڑی دیر بعد دوبارہ کوشش کریں۔';

  @override
  String get watchAd => 'اشتہار دیکھیں';

  @override
  String get extraLife => 'ایک اور موقع کے لیے اشتہار دیکھیں';

  @override
  String get restorePurchases => 'خریداری بحال کریں';

  @override
  String get adsRemoved => 'اشتہارات ہٹا دیے گئے۔ شکریہ!';

  @override
  String get privacyChoices => 'رازداری کے انتخاب';

  @override
  String get purchaseUnavailable => 'خریداری ابھی دستیاب نہیں۔';

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
}
