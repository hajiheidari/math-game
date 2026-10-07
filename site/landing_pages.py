"""Writes the Adadi landing pages (espadna.com/adadi-app/: en, fa/, ar/) into site/adadi-app/.
espadna.com/adadi-app* is a Worker route to the adadi site (see site/README.md), like Tiaro's.
Run after editing: python3 site/landing_pages.py
"""
import html
import pathlib

OUT = pathlib.Path(__file__).resolve().parent / 'adadi-app'
SITE = 'https://espadna.com/adadi-app'
GAME = 'https://adadi.espadna.com'
SUPPORT = 'a.a.hajiheidari@gmail.com'
L = {
 'fa': dict(path='fa/', dir='rtl', locale='fa_IR', label='فارسی', shots='fa', game_lang='fa',
   name='عددی', title='عددی | جدول ریاضی، رایگان',
   desc='عددی: جدول متقاطع ریاضی. عددها را در خانه‌های خالی بگذار تا همه‌ی معادله‌ها درست شوند. رایگان، بدون ثبت‌نام، همین حالا در مرورگر.',
   tag='جدول متقاطع ریاضی؛ هر روز یک پازل تازه',
   play='▶ همین حالا بازی کن', play_sub='رایگان، بدون نصب، در مرورگر',
   stores=[('کافه بازار', 'به‌زودی'), ('Google Play', 'به‌زودی'), ('App Store', 'به‌زودی')],
   shots_title='نگاهی به بازی',
   feats=[('🧮', 'جمع، تفریق، ضرب و تقسیم'), ('📅', 'پازل روزانه با تقویم شمسی'), ('💡', 'راهنما وقتی گیر کنی'), ('🔢', 'ارقام فارسی یا انگلیسی')],
   how='قانون بازی',
   rules=['هر <b>ردیف</b> و هر <b>ستون</b> یک معادله است.',
          'یک عدد از <b>کاشی‌ها</b> بردار و در <b>خانه‌ی خالی</b> بگذار.',
          'معادله‌ها در هم <b>قفل</b> شده‌اند: هر عدد باید در هر دو جهت درست باشد.',
          'هر پازل فقط <b>یک جواب</b> دارد؛ بدون حدس، فقط حساب.'],
   faq_title='سؤال‌های رایج',
   faq=[('رایگان است؟', 'بله. نسخه‌ی وب کاملاً رایگان و بدون تبلیغ است. نسخه‌ی موبایل رایگان است و بین مرحله‌ها تبلیغ دارد، ولی هیچ‌وقت وسط پازل نه؛ با یک خرید هم می‌شود تبلیغ را برداشت.'),
        ('برای چه سنی است؟', 'از ۱۳ سال به بالا، با سه سطح سنی و چهار درجه‌ی سختی در هر کدام.'),
        ('ثبت‌نام لازم دارد؟', 'نه. حساب کاربری ندارد و پیشرفتت فقط روی دستگاه خودت ذخیره می‌شود.'),
        ('چه زبان‌هایی دارد؟', 'فارسی، انگلیسی، عربی و اردو. از تنظیمات بازی می‌شود زبان و نوع ارقام را عوض کرد.')],
   home='اسپادنا', privacy='حریم خصوصی', privacy_url=GAME + '/privacy/#fa', support='پشتیبانی', ldlang='fa'),
 'en': dict(path='', dir='ltr', locale='en_US', label='English', shots='en', game_lang='en',
   name='Adadi', title='Adadi | Math crossword puzzles, free',
   desc='Adadi: the math crossword. Place the numbers in the empty boxes so every equation is true. Free, no sign-up, play now in your browser.',
   tag='The math crossword, with a new puzzle every day',
   play='▶ Play now', play_sub='Free, no install, right in your browser',
   stores=[('Google Play', 'Coming soon'), ('App Store', 'Coming soon')],
   shots_title='A look inside',
   feats=[('🧮', 'Add, subtract, multiply, divide'), ('📅', 'A daily puzzle and streaks'), ('💡', 'Hints when you are stuck'), ('🌍', 'English, Arabic, Persian, Urdu')],
   how='How to play',
   rules=['Every <b>row</b> and every <b>column</b> is an equation.',
          'Take a number from the <b>tiles</b> and put it in an <b>empty box</b>.',
          'The equations <b>cross</b>: each number must work both ways.',
          'Every puzzle has exactly <b>one solution</b>. No guessing, just math.'],
   faq_title='FAQ',
   faq=[('Is it free?', 'Yes. The web version is completely free and ad-free. The mobile app is free with ads between levels, never in the middle of a puzzle, and one purchase removes them.'),
        ('Who is it for?', 'Ages 13 and up, with three age groups and four difficulty levels in each.'),
        ('Do I need an account?', 'No. There is no sign-up; your progress stays on your own device.'),
        ('Which languages?', 'English, Arabic, Persian and Urdu. Switch language and digit style in the game’s Settings.')],
   home='Espadna', privacy='Privacy', privacy_url=GAME + '/privacy/', support='Support', ldlang='en'),
 'ar': dict(path='ar/', dir='rtl', locale='ar_AR', label='العربية', shots='ar', game_lang='ar',
   name='عددي', title='عددي | كلمات متقاطعة رياضية مجانية',
   desc='عددي: الكلمات المتقاطعة بالأرقام. ضع الأرقام في المربعات الفارغة لتصبح كل المعادلات صحيحة. مجانية ودون تسجيل، العب الآن في المتصفح.',
   tag='كلمات متقاطعة بالأرقام، ولغز جديد كل يوم',
   play='▶ العب الآن', play_sub='مجانًا ودون تثبيت، في المتصفح مباشرة',
   stores=[('Google Play', 'قريبًا'), ('App Store', 'قريبًا')],
   shots_title='لمحة عن اللعبة',
   feats=[('🧮', 'جمع وطرح وضرب وقسمة'), ('📅', 'لغز يومي وسلسلة أيام'), ('💡', 'تلميحات عندما تعلق'), ('🔢', 'أرقام عربية أو غربية')],
   how='طريقة اللعب',
   rules=['كل <b>صف</b> وكل <b>عمود</b> معادلة.',
          'خذ رقمًا من <b>البطاقات</b> وضعه في <b>مربع فارغ</b>.',
          'المعادلات <b>متقاطعة</b>: يجب أن يصح كل رقم في الاتجاهين.',
          'لكل لغز <b>حل واحد</b> فقط؛ دون تخمين، حساب فقط.'],
   faq_title='أسئلة شائعة',
   faq=[('هل اللعبة مجانية؟', 'نعم. نسخة الويب مجانية بالكامل ودون إعلانات. تطبيق الجوال مجاني مع إعلانات بين المراحل، لا في منتصف اللغز أبدًا، ويمكن إزالتها بشراء واحد.'),
        ('لمن هي؟', 'من عمر ١٣ عامًا فما فوق، بثلاث فئات عمرية وأربعة مستويات صعوبة لكل منها.'),
        ('هل أحتاج إلى حساب؟', 'لا. لا يوجد تسجيل، ويبقى تقدّمك على جهازك فقط.'),
        ('ما اللغات المتوفرة؟', 'العربية والإنجليزية والفارسية والأردية. يمكنك تغيير اللغة ونوع الأرقام من إعدادات اللعبة.')],
   home='إسبادنا', privacy='الخصوصية', privacy_url=GAME + '/privacy/', support='الدعم', ldlang='ar'),
}
CUR = ' aria-current="page"'
# The app icon's idea in miniature: four operator tiles around an amber 7.
MARK = ('<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="9" y="1" width="6" height="6" rx="1.5" fill="#22486E"/>'
        '<rect x="1" y="9" width="6" height="6" rx="1.5" fill="#22486E"/><rect x="9" y="9" width="6" height="6" rx="1.5" fill="#F2A93B"/>'
        '<rect x="17" y="9" width="6" height="6" rx="1.5" fill="#22486E"/><rect x="9" y="17" width="6" height="6" rx="1.5" fill="#22486E"/></svg>')
CSS = """
  @font-face { font-family: Vazirmatn; font-weight: 400 900; font-display: swap; src: url(/adadi-app/Vazirmatn-Bold.ttf) format("truetype"); }
  :root { --bg:#F5F8FC; --surface:#FFFFFF; --muted:#E8EEF6; --ink:#16283D; --text2:#5A6878; --navy:#22486E; --amber:#F2A93B; --border:#DCE4EE; }
  @media (prefers-color-scheme: dark) { :root { --bg:#111A24; --surface:#18232F; --muted:#223040; --ink:#EAF1F8; --text2:#9FB0C3; --navy:#8DB8E6; --border:#2B3542; } }
  * { box-sizing: border-box; }
  html { -webkit-text-size-adjust: 100%; background: var(--bg); }
  body { margin: 0; background: var(--bg); color: var(--ink); font: 17px/1.7 __FONT__; }
  main { max-width: 760px; margin: 0 auto; padding: 16px 16px 48px; }
  nav.top { display: flex; justify-content: space-between; align-items: center; gap: 8px; flex-wrap: wrap; }
  nav.top a.home { color: var(--text2); text-decoration: none; font-weight: 700; font-size: 15px; }
  .langs { display: flex; gap: 6px; }
  .langs a { color: var(--text2); text-decoration: none; font-weight: 700; font-size: 14px; border: 1.5px solid var(--border); border-radius: 999px; padding: 2px 12px; }
  .langs a[aria-current] { background: var(--ink); color: var(--bg); border-color: var(--ink); }
  .hero { text-align: center; padding: 28px 0 8px; }
  .hero img { width: 112px; height: 112px; border-radius: 26px; box-shadow: 0 10px 30px rgba(22,40,61,.2); }
  h1 { display: flex; justify-content: center; align-items: center; gap: 10px; margin: 18px 0 0; font: 800 clamp(44px, 12vw, 64px)/1.2 __FONT__; }
  h1 svg { width: .7em; height: .7em; }
  .tag { margin: 6px 0 26px; font-size: 20px; color: var(--text2); font-weight: 600; }
  .play { display: block; max-width: 420px; margin: 0 auto; padding: 16px 24px; border-radius: 18px; background: var(--navy); color: #fff; text-decoration: none; font-size: 24px; font-weight: 800; }
  .play small { display: block; font-size: 14px; font-weight: 600; opacity: .8; }
  .play:hover { opacity: .92; }
  .stores { display: flex; justify-content: center; gap: 10px; flex-wrap: wrap; margin: 14px auto 0; max-width: 420px; }
  .store { flex: 1; min-width: 120px; padding: 10px 14px; border-radius: 14px; background: var(--muted); color: var(--ink); text-decoration: none; font-weight: 700; font-size: 16px; text-align: center; }
  .store small { display: block; color: var(--text2); font-weight: 600; font-size: 12px; }
  h2 { font-size: 24px; margin: 44px 0 14px; }
  .shots { display: flex; gap: 12px; overflow-x: auto; padding: 4px 2px 12px; scroll-snap-type: x mandatory; }
  .shots img { flex: 0 0 auto; width: 200px; height: auto; aspect-ratio: 360/760; border-radius: 18px; border: 1px solid var(--border); scroll-snap-align: start; background: var(--muted); }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin-top: 36px; }
  .feat { background: var(--surface); border: 1px solid var(--border); border-radius: 18px; padding: 16px; text-align: center; }
  .feat b { display: block; font-size: 30px; line-height: 1.4; }
  .feat span { font-weight: 700; font-size: 16px; }
  .card { background: var(--surface); border: 1px solid var(--border); border-radius: 18px; padding: 8px 20px; }
  .rules { display: grid; gap: 4px; padding: 10px 0; margin: 0; list-style: none; }
  .rules li { display: flex; gap: 12px; align-items: baseline; }
  .rules li::before { content: ""; flex: 0 0 12px; height: 12px; border-radius: 3px; background: var(--navy); transform: translateY(1px); }
  .rules li:nth-child(even)::before { background: var(--amber); }
  details { border-bottom: 1px solid var(--border); padding: 12px 0; }
  details:last-child { border-bottom: 0; }
  summary { cursor: pointer; font-weight: 700; }
  details p { margin: 8px 0 0; color: var(--text2); }
  footer { text-align: center; color: var(--text2); font-size: 14px; margin-top: 48px; }
  footer a { color: var(--text2); }
"""


def page(k):
    c = L[k]
    e = html.escape
    font = ('Vazirmatn, Tahoma, "Segoe UI", sans-serif' if c['dir'] == 'rtl'
            else '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif')
    css = CSS.replace('__FONT__', font)
    url = f"{SITE}/{c['path']}"
    alts = ''.join(f'\n<link rel="alternate" hreflang="{x}" href="{SITE}/{L[x]["path"]}">' for x in L)
    langs = ''.join(f'<a href="/adadi-app/{L[x]["path"]}" hreflang="{x}" lang="{x}"{CUR if x == k else ""}>{L[x]["label"]}</a>' for x in L)
    stores = ''.join(f'<span class="store">{e(n)}<small>{e(s)}</small></span>' for n, s in c['stores'])
    shots = ''.join(f'<img src="/adadi-app/{c["shots"]}-{i}.webp" alt="" width="360" height="760" loading="lazy">' for i in range(1, 4))
    feats = ''.join(f'<div class="feat"><b>{i}</b><span>{e(t)}</span></div>' for i, t in c['feats'])
    rules = ''.join(f'<li><span>{r}</span></li>' for r in c['rules'])
    faq = ''.join(f'<details><summary>{e(q)}</summary><p>{e(a)}</p></details>' for q, a in c['faq'])
    home = '/' + c['path']
    game = f"{GAME}/?lang={c['game_lang']}"
    return f"""<!DOCTYPE html>
<html lang="{k}" dir="{c['dir']}">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>{e(c['title'])}</title>
<meta name="description" content="{e(c['desc'])}">
<meta name="theme-color" content="#22486E">
<link rel="canonical" href="{url}">{alts}
<link rel="icon" type="image/png" href="/adadi-app/favicon.png">
<link rel="apple-touch-icon" href="/adadi-app/icon.png">
<meta property="og:type" content="website">
<meta property="og:locale" content="{c['locale']}">
<meta property="og:site_name" content="{e(c['name'])}">
<meta property="og:title" content="{e(c['title'])}">
<meta property="og:description" content="{e(c['desc'])}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{SITE}/og.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="{SITE}/og.png">
<script type="application/ld+json">{{"@context":"https://schema.org","@type":"VideoGame","name":"{e(c['name'])}","description":"{e(c['desc'])}","inLanguage":"{c['ldlang']}","genre":["Puzzle","Math"],"gamePlatform":["Web browser","Android","iOS"],"url":"{url}","image":"{SITE}/og.png","publisher":{{"@type":"Organization","name":"Espadna","url":"https://espadna.com/"}},"offers":{{"@type":"Offer","price":"0","priceCurrency":"USD"}}}}</script>
<style>{css}</style>
</head>
<body>
<main>
  <nav class="top"><a class="home" href="{home}">{e(c['home'])}</a><div class="langs">{langs}</div></nav>
  <section class="hero">
    <img src="/adadi-app/icon.png" alt="" width="112" height="112">
    <h1>{MARK}{e(c['name'])}</h1>
    <p class="tag">{e(c['tag'])}</p>
    <a class="play" href="{game}">{e(c['play'])}<small>{e(c['play_sub'])}</small></a>
    <div class="stores">{stores}</div>
  </section>
  <section class="grid">{feats}</section>
  <h2>{e(c['shots_title'])}</h2>
  <div class="shots">{shots}</div>
  <h2>{e(c['how'])}</h2>
  <div class="card"><ul class="rules">{rules}</ul></div>
  <h2>{e(c['faq_title'])}</h2>
  <div class="card">{faq}</div>
  <footer>
    <a href="{home}">{e(c['home'])}</a> · <a href="{c['privacy_url']}">{e(c['privacy'])}</a> · <a href="mailto:{SUPPORT}">{e(c['support'])}</a>
  </footer>
</main>
</body>
</html>
"""


for k in L:
    p = OUT / L[k]['path'] / 'index.html'
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(page(k), encoding='utf-8')
print('ok')
