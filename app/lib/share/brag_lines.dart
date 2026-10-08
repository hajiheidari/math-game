/// Short fun lines for a won puzzle, aimed at teens and young adults (Amir,
/// 2026-10-08): [you] cheer the player on the result dialog and invite them
/// to share; [me] are the same idea in the first person, at the top of what
/// they share. Kept here and not in the .arb files because those have no
/// lists. Index i of [you] and [me] match, so the dialog and the shared post
/// tell the same joke.
class BragLines {
  final List<String> you;
  final List<String> me;

  /// No mistakes at all: used instead of [you] / [me].
  final List<String> youFlawless;
  final List<String> meFlawless;

  const BragLines({
    required this.you,
    required this.me,
    required this.youFlawless,
    required this.meFlawless,
  });
}

const _en = BragLines(
  you: [
    "You're today's smartest player 😎",
    'Your math brain is on fire 🔥',
    'Who needs a calculator? Not you 😏',
    'Those equations never stood a chance 🧠',
    'Number genius of the day: you 👑',
  ],
  me: [
    "Today's smartest player? Me, obviously 😎",
    'My math brain is on fire today 🔥',
    'Calculator? Never needed one 😏',
    'Those equations never stood a chance 🧠',
    'Number genius of the day: me 👑',
  ],
  youFlawless: [
    'Not a single mistake. Flawless ✨',
    'Zero mistakes, 100% genius 💯',
  ],
  meFlawless: [
    'Not a single mistake. Flawless ✨',
    'Zero mistakes, 100% genius 💯',
  ],
);

const _fa = BragLines(
  you: [
    'امروز باهوش‌ترین بازیکن تو بودی 😎',
    'مغز ریاضیت امروز آتیش بود 🔥',
    'ماشین‌حساب؟ تو لازم نداری 😏',
    'معادله‌ها جلوی تو کم آوردن 🧠',
    'نابغه‌ی عددهای امروز تویی 👑',
  ],
  me: [
    'باهوش‌ترین بازیکن امروز؟ معلومه، خودم 😎',
    'مغز ریاضیم امروز آتیش بود 🔥',
    'ماشین‌حساب؟ لازم ندارم 😏',
    'معادله‌ها جلوی من کم آوردن 🧠',
    'نابغه‌ی عددهای امروز منم 👑',
  ],
  youFlawless: [
    'حتی یک اشتباه هم نکردی. بی‌نقص ✨',
    'صفر اشتباه، صد درصد نبوغ 💯',
  ],
  meFlawless: [
    'حتی یک اشتباه هم نکردم. بی‌نقص ✨',
    'صفر اشتباه، صد درصد نبوغ 💯',
  ],
);

const _ar = BragLines(
  you: [
    'أنت أذكى لاعب اليوم 😎',
    'عقلك الرياضي مشتعل اليوم 🔥',
    'آلة حاسبة؟ لست بحاجة إليها 😏',
    'المعادلات لم تصمد أمامك 🧠',
    'عبقري الأرقام لهذا اليوم: أنت 👑',
  ],
  me: [
    'أذكى لاعب اليوم؟ أنا طبعًا 😎',
    'عقلي الرياضي مشتعل اليوم 🔥',
    'آلة حاسبة؟ لا أحتاجها 😏',
    'المعادلات لم تصمد أمامي 🧠',
    'عبقري الأرقام لهذا اليوم: أنا 👑',
  ],
  youFlawless: ['ولا خطأ واحد. أداء مثالي ✨', 'صفر أخطاء، عبقرية ١٠٠٪ 💯'],
  meFlawless: ['ولا خطأ واحد. أداء مثالي ✨', 'صفر أخطاء، عبقرية ١٠٠٪ 💯'],
);

const _ur = BragLines(
  you: [
    'آج کے سب سے ذہین کھلاڑی آپ ہیں 😎',
    'آج آپ کا ریاضی والا دماغ آگ بنا ہوا ہے 🔥',
    'کیلکولیٹر؟ آپ کو ضرورت ہی نہیں 😏',
    'مساواتیں آپ کے سامنے ٹک نہ سکیں 🧠',
    'آج کے نمبر جینئس آپ ہیں 👑',
  ],
  me: [
    'آج کا سب سے ذہین کھلاڑی؟ ظاہر ہے، میں 😎',
    'آج میرا ریاضی والا دماغ آگ بنا ہوا ہے 🔥',
    'کیلکولیٹر؟ مجھے ضرورت ہی نہیں 😏',
    'مساواتیں میرے سامنے ٹک نہ سکیں 🧠',
    'آج کا نمبر جینئس: میں 👑',
  ],
  youFlawless: ['ایک بھی غلطی نہیں۔ بے مثال ✨', 'صفر غلطیاں، سو فیصد ذہانت 💯'],
  meFlawless: ['ایک بھی غلطی نہیں۔ بے مثال ✨', 'صفر غلطیاں، سو فیصد ذہانت 💯'],
);

const Map<String, BragLines> kBragLines = {
  'en': _en,
  'fa': _fa,
  'ar': _ar,
  'ur': _ur,
};

BragLines bragLinesFor(String languageCode) => kBragLines[languageCode] ?? _en;
