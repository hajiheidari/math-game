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
  String get privacyChoices => 'انتخاب‌های حریم خصوصی';

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
  String get shareResult => 'دوستانت را به چالش بکش';

  @override
  String get shareBeatMe => 'تو می‌تونی سریع‌تر حلش کنی؟';

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
  String friendHintsToday(String count, String max) {
    return 'از دوستان، امروز: $count از $max';
  }

  @override
  String get shareForHints => 'هر دوستی که بازش کند، یک سکه برایت می‌آورد.';

  @override
  String get invite => 'دعوت';

  @override
  String get zoomIn => 'بزرگ‌نمایی';

  @override
  String get zoomOut => 'اندازهٔ عادی';

  @override
  String get coinsTitle => 'سکه برای راهنما';

  @override
  String coinsBody(String max) {
    return 'هر راهنما یک سکه است. هر دوستی که لینک چالش یا دعوتت را باز کند، یک سکه برایت می‌آورد (تا $max تا در روز).';
  }

  @override
  String get watchAdForCoin => 'دیدن تبلیغ: ۱ سکه';

  @override
  String friendCoinsReceived(String count) {
    return 'دوستانت برایت سکه فرستادند: $count+';
  }

  @override
  String get challengeTitle => 'چالش';

  @override
  String challengeToBeat(String time) {
    return 'زمان رقیب: $time';
  }

  @override
  String get challengeWon => 'از دوستت جلو زدی! 🎉';

  @override
  String get challengeLost => 'این بار دوستت سریع‌تر بود. دوباره؟';

  @override
  String get challengeTie => 'مساوی شدید!';

  @override
  String get challengeYou => 'تو';

  @override
  String get challengeFriend => 'دوستت';

  @override
  String get challengeReceived => 'یک چالش برایت آمده!';

  @override
  String challengeBody(String time) {
    return 'دوستت این جدول را در $time حل کرده. می‌تونی سریع‌تر حلش کنی؟';
  }

  @override
  String get challengeStart => 'شروع';

  @override
  String get later => 'بعداً';

  @override
  String get leaderboards => 'جدول رتبه‌ها';

  @override
  String get certificates => 'گواهی‌نامه‌ها';

  @override
  String get certNameLabel => 'نامت روی گواهی‌نامه';

  @override
  String get certNameHelp =>
      'اختیاری. فقط روی گوشی خودت می‌ماند و در چیزی که خودت می‌فرستی.';

  @override
  String get certHowTo =>
      'ادامه بده تا بقیه را هم بگیری و در استوری به اشتراک بگذاری.';

  @override
  String get certShare => 'اشتراک در استوری';

  @override
  String get certShareLine => 'تو هم می‌تونی بگیری؟ عددی را رایگان بازی کن:';

  @override
  String get certEarned => 'گواهی‌نامه گرفتی! 🎉';

  @override
  String get certOpen => 'ببینمش';

  @override
  String get certCertificate => 'لوح افتخار';

  @override
  String get certOfAchievement => 'گواهی موفقیت';

  @override
  String get certPresentedTo => 'با افتخار تقدیم به';

  @override
  String get certNoName => 'یک بازیکن عددی';

  @override
  String get certTagline => 'عددی · جدول ریاضی';

  @override
  String certStreakTitle(String n) {
    return '$n روز پشت سر هم';
  }

  @override
  String certStreakBody(String n) {
    return 'برای حل جدول روزانه، $n روز پشت سر هم.';
  }

  @override
  String certLevelsTitle(String n) {
    return '$n مرحله';
  }

  @override
  String certLevelsBody(String n) {
    return 'برای تمام کردن $n مرحله از عددی.';
  }

  @override
  String get certExpertTitle => 'ذهن حرفه‌ای';

  @override
  String certExpertBody(String n) {
    return 'برای تمام کردن $n مرحلهٔ حرفه‌ای.';
  }

  @override
  String get certAllDailyTitle => 'قهرمان روز';

  @override
  String get certAllDailyBody => 'برای حل هر چهار جدول روزانه در یک روز.';

  @override
  String get backupTitle => 'پشتیبان';

  @override
  String get backupAuto =>
      'پیشرفتت در iCloud (آیفون و آیپد) یا پشتیبان گوگل (اندروید) هم نگه داشته می‌شود.';

  @override
  String get backupCodeLabel => 'کد بازیابی تو';

  @override
  String get backupHelp =>
      'این کد را نگه دار. روی گوشی جدید یا وب، آن را پایین وارد کن تا مرحله‌ها، ستاره‌ها، روزهای پشت سر هم و سکه‌هایت برگردند.';

  @override
  String get backupCopy => 'کپی کد';

  @override
  String get backupCopied => 'کد کپی شد.';

  @override
  String get backupGetting => 'در حال گرفتن کد…';

  @override
  String get backupOffline =>
      'اینترنت وصل نیست. وقتی آنلاین شدی دوباره امتحان کن.';

  @override
  String get backupRestoreTitle => 'بازیابی با کد';

  @override
  String get backupRestore => 'بازیابی';

  @override
  String get backupBadCode => 'این کد کامل نیست. کد ۱۲ حرف و عدد دارد.';

  @override
  String get backupConfirm =>
      'پشتیبان به پیشرفت این گوشی اضافه می‌شود (چیزی از این گوشی پاک نمی‌شود). ادامه بدهیم؟';

  @override
  String get backupYesRestore => 'بله، بازیابی کن';

  @override
  String get backupDone => 'انجام شد! پیشرفتت برگشت.';

  @override
  String get backupNotFound => 'برای این کد پشتیبانی پیدا نشد.';
}
