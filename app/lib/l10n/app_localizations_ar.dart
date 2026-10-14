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
  String get privacyChoices => 'خيارات الخصوصية';

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

  @override
  String get shareResult => 'تحدَّ أصدقاءك';

  @override
  String get shareBeatMe => 'هل تستطيع التغلب على وقتي؟';

  @override
  String get shareNoMistakes => 'بلا أخطاء';

  @override
  String get shareCopied => 'تم النسخ! الصقه أينما تريد.';

  @override
  String get inviteFriends => 'ادعُ أصدقاءك';

  @override
  String inviteMessage(String link) {
    return 'العب عددي معي: كلمات متقاطعة من معادلات رياضية 🧮 $link';
  }

  @override
  String friendHintsToday(String count, String max) {
    return 'من الأصدقاء اليوم: $count/$max';
  }

  @override
  String get shareForHints => 'كل صديق يفتحه يمنحك عملة.';

  @override
  String get invite => 'ادعُ';

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'الحجم العادي';

  @override
  String get coinsTitle => 'عملات للتلميحات';

  @override
  String coinsBody(String max) {
    return 'كل تلميح يكلّف عملة واحدة. كل صديق يفتح رابط التحدي أو الدعوة يمنحك عملة (حتى $max في اليوم).';
  }

  @override
  String get watchAdForCoin => 'شاهد إعلانًا: +1 عملة';

  @override
  String friendCoinsReceived(String count) {
    return 'أرسل لك أصدقاؤك عملات: +$count';
  }

  @override
  String get challengeTitle => 'تحدٍّ';

  @override
  String challengeToBeat(String time) {
    return 'الوقت المطلوب تجاوزه: $time';
  }

  @override
  String get challengeWon => 'تفوّقت على صديقك! 🎉';

  @override
  String get challengeLost => 'كان صديقك أسرع هذه المرة. جولة أخرى؟';

  @override
  String get challengeTie => 'تعادل!';

  @override
  String get challengeYou => 'أنت';

  @override
  String get challengeFriend => 'صديقك';

  @override
  String get challengeReceived => 'وصلك تحدٍّ!';

  @override
  String challengeBody(String time) {
    return 'حلّ صديقك هذا اللغز في $time. هل يمكنك التغلب عليه؟';
  }

  @override
  String get challengeStart => 'ابدأ';

  @override
  String get later => 'لاحقًا';

  @override
  String get leaderboards => 'لوحات الصدارة';

  @override
  String get certificates => 'الشهادات';

  @override
  String get certNameLabel => 'اسمك على الشهادات';

  @override
  String get certNameHelp => 'اختياري. يبقى على هاتفك، وفي ما تشاركه فقط.';

  @override
  String get certHowTo => 'واصل الحل لتحصل على المزيد، ثم شاركها في قصتك.';

  @override
  String get certShare => 'شاركها في القصة';

  @override
  String get certShareLine => 'هل تستطيع الحصول على واحدة؟ العب عددي مجانًا:';

  @override
  String get certEarned => 'حصلت على شهادة! 🎉';

  @override
  String get certOpen => 'افتحها';

  @override
  String get certCertificate => 'شهادة تقدير';

  @override
  String get certOfAchievement => 'وإنجاز';

  @override
  String get certPresentedTo => 'تُمنح بكل فخر إلى';

  @override
  String get certNoName => 'لاعب في عددي';

  @override
  String get certTagline => 'عددي · كلمات متقاطعة رياضية';

  @override
  String certStreakTitle(String n) {
    return 'سلسلة $n يومًا';
  }

  @override
  String certStreakBody(String n) {
    return 'لحلّ لغز اليوم $n يومًا متتاليًا.';
  }

  @override
  String certLevelsTitle(String n) {
    return '$n مرحلة';
  }

  @override
  String certLevelsBody(String n) {
    return 'لإكمال $n مرحلة في عددي.';
  }

  @override
  String get certExpertTitle => 'عقل خبير';

  @override
  String certExpertBody(String n) {
    return 'لإكمال $n مراحل في مستوى الخبير.';
  }

  @override
  String get certAllDailyTitle => 'بطل اليوم';

  @override
  String get certAllDailyBody => 'لحلّ ألغاز اليوم الأربعة في يوم واحد.';

  @override
  String get backupTitle => 'النسخ الاحتياطي';

  @override
  String get backupAuto =>
      'يُحفظ تقدّمك أيضًا في iCloud (آيفون وآيباد) أو نسخة Google الاحتياطية (أندرويد).';

  @override
  String get backupCodeLabel => 'رمز الاسترداد الخاص بك';

  @override
  String get backupHelp =>
      'احتفظ بهذا الرمز. على هاتف جديد أو على الويب، أدخله أدناه لاستعادة مراحلك ونجومك وسلسلتك وعملاتك.';

  @override
  String get backupCopy => 'نسخ الرمز';

  @override
  String get backupCopied => 'تم نسخ الرمز.';

  @override
  String get backupGetting => 'جارٍ الحصول على الرمز…';

  @override
  String get backupOffline => 'لا يوجد اتصال. حاول مرة أخرى عند الاتصال.';

  @override
  String get backupRestoreTitle => 'الاستعادة برمز';

  @override
  String get backupRestore => 'استعادة';

  @override
  String get backupBadCode => 'هذا الرمز غير مكتمل. يتكون من 12 حرفًا ورقمًا.';

  @override
  String get backupConfirm =>
      'ستُضاف النسخة الاحتياطية إلى التقدّم على هذا الجهاز (لن يضيع شيء). هل تتابع؟';

  @override
  String get backupYesRestore => 'نعم، استعادة';

  @override
  String get backupDone => 'تم! عاد تقدّمك.';

  @override
  String get backupNotFound => 'لم يُعثر على نسخة احتياطية لهذا الرمز.';
}
