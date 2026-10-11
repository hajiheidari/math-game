// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'عددی';

  @override
  String get ageGateTitle => 'چند سال دارید؟';

  @override
  String get ageGatePickerHint => 'سن خود را انتخاب کنید';

  @override
  String get ageGateContinue => 'ادامه';

  @override
  String ageGateBlocked(String minAge) {
    return 'این برنامه برای افراد $minAge سال به بالا است.';
  }

  @override
  String get menuLevels => 'مرحله‌ها';

  @override
  String get menuDaily => 'معمای روزانه';

  @override
  String get ageGroup => 'گروه سنی';

  @override
  String bandRange(String from, String to) {
    return '$from تا $to سال';
  }

  @override
  String bandAndUp(String from) {
    return '$from سال به بالا';
  }

  @override
  String get difficultyEasy => 'آسان';

  @override
  String get difficultyMedium => 'متوسط';

  @override
  String get difficultyHard => 'سخت';

  @override
  String get difficultyExpert => 'حرفه‌ای';

  @override
  String levelNumber(String number) {
    return 'مرحله $number';
  }

  @override
  String mistakesCounter(String count, String max) {
    return 'اشتباه: $count از $max';
  }

  @override
  String get pause => 'توقف';

  @override
  String get resume => 'ادامه';

  @override
  String get undo => 'برگرداندن';

  @override
  String get restart => 'شروع دوباره';

  @override
  String get sortBank => 'مرتب‌سازی';

  @override
  String get hint => 'راهنمایی';

  @override
  String get tiles => 'کاشی‌ها';

  @override
  String get levelComplete => 'مرحله کامل شد!';

  @override
  String get outOfMistakes => 'فرصت اشتباه تمام شد';

  @override
  String get nextLevel => 'مرحله بعد';

  @override
  String get tryAgain => 'دوباره امتحان کن';

  @override
  String get watchAdForHint => 'برای راهنمایی یک تبلیغ ببینید';

  @override
  String streakDays(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText روز پیاپی',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'تنظیمات';

  @override
  String get language => 'زبان';

  @override
  String get digits => 'ارقام';

  @override
  String get digitsAuto => 'خودکار';

  @override
  String get digitsWestern => 'لاتین';

  @override
  String get digitsNative => 'فارسی';

  @override
  String get sound => 'صدا';

  @override
  String get haptics => 'لرزش';

  @override
  String get privacyPolicy => 'حریم خصوصی';

  @override
  String get contactSupport => 'پشتیبانی';

  @override
  String get removeAds => 'حذف تبلیغات';

  @override
  String get previewTitle => 'پیش‌نمایش طراحی';

  @override
  String get showSolution => 'نمایش پاسخ';

  @override
  String get time => 'زمان';

  @override
  String get mistakesLabel => 'اشتباه‌ها';

  @override
  String get paused => 'متوقف شد';

  @override
  String get play => 'بازی';

  @override
  String get menu => 'منو';

  @override
  String get chooseDifficulty => 'سطح دشواری را انتخاب کنید';

  @override
  String equationsRange(String from, String to) {
    return '$from تا $to معادله';
  }

  @override
  String get continuePlaying => 'ادامه';

  @override
  String levelsCompleted(String count) {
    return 'تمام‌شده: $count';
  }

  @override
  String get dailyComplete => 'معمای امروز حل شد!';

  @override
  String get calendar => 'تقویم';

  @override
  String bestStreak(String count) {
    return 'بهترین رکورد: $count روز';
  }

  @override
  String get noHintsAvailable =>
      'فعلاً راهنمایی در دسترس نیست. کمی بعد دوباره امتحان کنید.';

  @override
  String get watchAd => 'دیدن تبلیغ';

  @override
  String get extraLife => 'با دیدن یک تبلیغ، یک فرصت اشتباه دیگر بگیرید';

  @override
  String get restorePurchases => 'بازیابی خریدها';

  @override
  String get adsRemoved => 'تبلیغات حذف شد. سپاس!';

  @override
  String get privacyChoices => 'انتخاب‌های حریم خصوصی';

  @override
  String get purchaseUnavailable => 'فعلاً امکان خرید وجود ندارد.';

  @override
  String get tutorialTitle => 'راهنمای بازی';

  @override
  String get tutorialStep1 =>
      'یک عدد را از کاشی‌ها به خانهٔ خالی بکشید، یا اول عدد و بعد خانه را بزنید. معادله باید درست باشد.';

  @override
  String get tutorialStep2 =>
      'بعضی خانه‌ها مال دو معادله‌اند: افقی و عمودی. عدد باید هر دو را درست کند.';

  @override
  String get tutorialWrong =>
      'نه کاملاً. در بازی، کاشی اشتباه یک اشتباه حساب می‌شود. یکی دیگر را امتحان کنید.';

  @override
  String get tutorialDone => 'آماده‌اید!';

  @override
  String get tutorialDoneBody =>
      'سطرها از چپ به راست و ستون‌ها از بالا به پایین خوانده می‌شوند. گیر کردید؟ از راهنمایی استفاده کنید.';

  @override
  String get startPlaying => 'شروع بازی';

  @override
  String get skip => 'رد کردن';

  @override
  String get shareResult => 'به دوستانت نشان بده';

  @override
  String get shareBeatMe => 'تو می‌تونی بهتر حلش کنی؟';

  @override
  String get shareNoMistakes => 'بدون اشتباه';

  @override
  String get shareCopied => 'کپی شد! هر جا خواستی بفرست.';

  @override
  String get inviteFriends => 'دعوت از دوستان';

  @override
  String inviteMessage(String link) {
    return 'بیا با هم عددی بازی کنیم: جدول متقاطع با معادله‌های ریاضی 🧮 $link';
  }

  @override
  String get friendHintsTitle => 'راهنمای رایگان از دوستان';

  @override
  String friendHintsBody(String max) {
    return 'لینکت یا نتیجه‌ات را برای دوستانت بفرست. هر دوستی که بازش کند، یک راهنما برایت می‌آورد (تا $max تا در روز).';
  }

  @override
  String friendHintsToday(String count, String max) {
    return 'امروز: $count از $max';
  }

  @override
  String friendHintsReceived(String count) {
    return 'دوستانت برایت راهنما فرستادند: +$count';
  }

  @override
  String get shareForHints => 'هر دوستی که بازش کند، یک راهنما برایت می‌آورد.';

  @override
  String get invite => 'دعوت';
}
