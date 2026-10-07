// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'عددي';

  @override
  String get ageGateTitle => 'كم عمرك؟';

  @override
  String get ageGatePickerHint => 'اختر عمرك';

  @override
  String get ageGateContinue => 'متابعة';

  @override
  String ageGateBlocked(String minAge) {
    return 'هذا التطبيق مخصص لمن تبلغ أعمارهم $minAge عامًا فأكثر.';
  }

  @override
  String get menuLevels => 'المراحل';

  @override
  String get menuDaily => 'لغز اليوم';

  @override
  String get ageGroup => 'الفئة العمرية';

  @override
  String bandRange(String from, String to) {
    return '$from إلى $to عامًا';
  }

  @override
  String bandAndUp(String from) {
    return '$from عامًا فأكثر';
  }

  @override
  String get difficultyEasy => 'سهل';

  @override
  String get difficultyMedium => 'متوسط';

  @override
  String get difficultyHard => 'صعب';

  @override
  String get difficultyExpert => 'خبير';

  @override
  String levelNumber(String number) {
    return 'المرحلة $number';
  }

  @override
  String mistakesCounter(String count, String max) {
    return 'الأخطاء: $count من $max';
  }

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'استئناف';

  @override
  String get undo => 'تراجع';

  @override
  String get restart => 'إعادة البدء';

  @override
  String get sortBank => 'ترتيب';

  @override
  String get hint => 'تلميح';

  @override
  String get tiles => 'البطاقات';

  @override
  String get levelComplete => 'اكتملت المرحلة!';

  @override
  String get outOfMistakes => 'نفدت المحاولات';

  @override
  String get nextLevel => 'المرحلة التالية';

  @override
  String get tryAgain => 'حاول مجددًا';

  @override
  String get watchAdForHint => 'شاهد إعلانًا للحصول على تلميح';

  @override
  String streakDays(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سلسلة $countText يوم',
      many: 'سلسلة $countText يومًا',
      few: 'سلسلة $countText أيام',
      two: 'سلسلة يومين',
      one: 'سلسلة يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get digits => 'الأرقام';

  @override
  String get digitsAuto => 'تلقائي';

  @override
  String get digitsWestern => 'غربية';

  @override
  String get digitsNative => 'عربية';

  @override
  String get sound => 'الصوت';

  @override
  String get haptics => 'الاهتزاز';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get contactSupport => 'التواصل مع الدعم';

  @override
  String get removeAds => 'إزالة الإعلانات';

  @override
  String get previewTitle => 'معاينة التصميم';

  @override
  String get showSolution => 'إظهار الحل';

  @override
  String get time => 'الوقت';

  @override
  String get mistakesLabel => 'الأخطاء';

  @override
  String get paused => 'متوقف مؤقتًا';

  @override
  String get play => 'العب';

  @override
  String get menu => 'القائمة';

  @override
  String get chooseDifficulty => 'اختر مستوى الصعوبة';

  @override
  String equationsRange(String from, String to) {
    return 'من $from إلى $to معادلات';
  }

  @override
  String get continuePlaying => 'متابعة';

  @override
  String levelsCompleted(String count) {
    return 'المكتملة: $count';
  }

  @override
  String get dailyComplete => 'تم حل لغز اليوم!';

  @override
  String get calendar => 'التقويم';

  @override
  String bestStreak(String count) {
    return 'أفضل سلسلة: $count';
  }

  @override
  String get noHintsAvailable =>
      'لا تتوفر تلميحات الآن. حاول مرة أخرى بعد قليل.';

  @override
  String get watchAd => 'مشاهدة الإعلان';

  @override
  String get extraLife => 'شاهد إعلانًا للحصول على محاولة إضافية';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get adsRemoved => 'تمت إزالة الإعلانات. شكرًا لك!';

  @override
  String get privacyChoices => 'خيارات الخصوصية';

  @override
  String get purchaseUnavailable => 'الشراء غير متاح حاليًا.';

  @override
  String get tutorialTitle => 'طريقة اللعب';

  @override
  String get tutorialStep1 =>
      'اسحب رقمًا من البطاقات إلى المربع الفارغ، أو انقر على الرقم ثم على المربع. يجب أن تكون المعادلة صحيحة.';

  @override
  String get tutorialStep2 =>
      'بعض المربعات تنتمي إلى معادلتين: أفقية ورأسية. يجب أن يجعل الرقم كلتيهما صحيحتين.';

  @override
  String get tutorialWrong =>
      'ليس تمامًا. في اللعبة تُحسب البطاقة الخاطئة خطأً. جرّب رقمًا آخر.';

  @override
  String get tutorialDone => 'أنت جاهز!';

  @override
  String get tutorialDoneBody =>
      'تُقرأ الصفوف من اليسار إلى اليمين والأعمدة من الأعلى إلى الأسفل. هل علقت؟ استخدم تلميحًا.';

  @override
  String get startPlaying => 'ابدأ اللعب';

  @override
  String get skip => 'تخطٍّ';
}
