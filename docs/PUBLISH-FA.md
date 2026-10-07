# انتشار عددی، قدم‌به‌قدم (کارهایی که با حساب‌های امیر انجام می‌شود)

همه‌ی کد و فایل‌ها آماده است. هر قدم را که انجام دادید خبر بدهید تا قدم بعدی را از طرف خودم کامل کنم.
ترتیب مهم است: اول سایت، بعد کافه بازار، بعد اپ استور.

---

## قدم ۱: سایت (adadi.espadna.com و espadna.com/adadi-app)

نسخه‌ی وب، صفحه‌ی معرفی و حریم خصوصی با هر تغییر کد خودکار روی Cloudflare منتشر می‌شوند (مثل تیارو)؛
فقط دو «کلید» Cloudflare باید در مخزن math-game ثبت شود:

1. GitHub ← مخزن **math-game** ← Settings ← Secrets and variables ← Actions ← **New repository secret**:
   - `CLOUDFLARE_ACCOUNT_ID`: همان مقداری که در مخزن espadna-site گذاشته‌اید
     (در Cloudflare: Workers & Pages، ستون راست، «Account ID»).
   - `CLOUDFLARE_API_TOKEN`: همان توکن espadna-site. اگر مقدارش را ندارید، یک توکن تازه بسازید:
     Cloudflare ← My Profile ← API Tokens ← Create Token ← قالب **Edit Cloudflare Workers** ←
     Account: حساب خودتان، Zone: `espadna.com` ← Create.
2. به من خبر بدهید. من انتشار را دوباره اجرا می‌کنم و بعد از بالا آمدن سایت، کارت عددی را
   (که آماده در شاخه‌ی `adadi` مخزن espadna-site است) به صفحه‌ی اصلی espadna.com اضافه می‌کنم.

**نسخه‌ی ایرانی (espadna.ir)**، مثل تیارو:

3. در پنل DirectAdmin هاست ایران، زیردامنه‌ی **`adadi`** را بسازید و برایش SSL (Let's Encrypt) بگیرید.
4. در File Manager، فایل `espadna-sync/config.php` را باز کنید و این دو مورد را در بخش `'sites'`،
   بعد از مورد `tiaro-app`، اضافه کنید (همان متنی که در `mirror-ir/config.sample.php` مخزن espadna-site هست):

   ```php
           [
               'name' => 'adadi',              // adadi.espadna.ir (the web game)
               'source' => "$git/adadi",
               'target' => $sub('adadi'),
               'spa' => true,
           ],
           [
               'name' => 'adadi-app',          // Adadi's landing pages (its own Worker on .com)
               'source' => "$git/adadi-app",
               'target' => "$root/adadi-app",
           ],
   ```
5. چند دقیقه بعد `https://espadna.ir/mirror-status.json` را ببینید؛ `adadi` باید `updated` یا `up to date` باشد.
   بعد `https://adadi.espadna.ir` بازی را با اینترنت داخلی هم باز می‌کند.

---

## قدم ۲: کلید امضای برنامه (یک بار، برای همیشه)

بازار و گوگل‌پلی هر نسخه را با یک کلید امضا می‌شناسند. **اگر این کلید گم شود، دیگر نمی‌شود برنامه را
به‌روز کرد.** کلید را خودتان بسازید (پیش من نمی‌ماند) و از فایل و رمزش نسخه‌ی پشتیبان بگیرید.

1. روی کامپیوتری که جاوا دارد (یا Android Studio نصب است) در ترمینال:
   ```
   keytool -genkeypair -v -keystore adadi-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias adadi
   ```
   یک رمز بگذارید و سؤال‌ها (نام، شهر، کشور) را جواب بدهید.
2. فایل را به متن base64 تبدیل کنید:
   - مک: `base64 -i adadi-release.jks | pbcopy` (در حافظه کپی می‌شود)
   - لینوکس: `base64 -w0 adadi-release.jks`
   - ویندوز (PowerShell): `[Convert]::ToBase64String([IO.File]::ReadAllBytes("adadi-release.jks")) | Set-Clipboard`
3. در GitHub (همان صفحه‌ی Secrets مخزن math-game) چهار secret بسازید:
   - `ADADI_KEYSTORE_BASE64`: متن مرحله‌ی ۲
   - `ADADI_KEYSTORE_PASSWORD`: رمز
   - `ADADI_KEY_ALIAS`: `adadi`
   - `ADADI_KEY_PASSWORD`: همان رمز (keytool برای هر دو یکی می‌گذارد)

از این به بعد فایل‌های صفحه‌ی **Releases ← test-build** با کلید شما امضا می‌شوند.

---

## قدم ۳: کافه بازار

نسخه‌ی بازار جداست: تبلیغ **ادیوری** (AdMob در ایران تبلیغ نشان نمی‌دهد)، پرداخت **بازار**، زبان پیش‌فرض
فارسی؛ کتابخانه‌های گوگل در آن نیست. فایلش هر بار ساخته می‌شود: `adadi-<نسخه>-bazaar.apk`.

1. **حساب توسعه‌دهنده:** اگر برای تیارو ساخته‌اید همان کافی است؛ وگرنه در https://pishkhan.cafebazaar.ir ثبت‌نام
   (هویت، کارت ملی، شماره‌ی شبا برای دریافت پول).
2. **ادیوری:** در پنل ادیوری (همان حساب تیارو) یک اپ تازه برای `com.espadna.adadi` بسازید و دو جایگاه تبلیغ:
   **Rewarded** (ویدیوی جایزه‌دار) و **Interstitial** (تمام‌صفحه). سه شناسه را برایم بفرستید:
   App ID، شناسه‌ی Rewarded، شناسه‌ی Interstitial.
3. **برنامه در پیشخان بازار:** «برنامه‌ی جدید» با نام بسته‌ی **`com.espadna.adadi`**.
4. **پرداخت درون‌برنامه‌ای** (در صفحه‌ی همان برنامه):
   - محصول تازه: شناسه **`remove_ads`**، نوع غیرمصرفی، نام «حذف تبلیغات»، قیمت ۹۹٬۰۰۰ تومان.
   - **کلید RSA** برنامه را کپی کنید و برایم بفرستید (کلید عمومی است، فرستادنش بی‌خطر است).
5. من شناسه‌ها و کلید را در کد می‌گذارم؛ بعد از چند دقیقه فایل امضاشده‌ی
   `adadi-<نسخه>-bazaar.apk` در Releases آماده است و روی گوشی مجازی هم تست شده.
6. **آپلود و صفحه‌ی برنامه:** فایل بازار را آپلود کنید. متن‌ها، توضیحات، کلمه‌های کلیدی، رده‌ی سنی و
   لینک‌ها در `docs/store/bazaar-listing-fa.md` آماده است؛ آیکون و اسکرین‌شات‌ها در `docs/store/bazaar/`.
7. ارسال برای بررسی. اگر بازار ایرادی گرفت، متن پیامشان را برایم بفرستید.

---

## قدم ۴: اپ استور (آیفون)

**پیش‌نیاز مهم:** ثبت‌نام در Apple Developer Program (سالی ۹۹ دلار) از ایران ممکن نیست؛ اپل حساب ساکنان
کشورهای تحریم‌شده را نمی‌پذیرد. حساب باید به نام شخص یا شرکتی در کشوری باشد که اپل در آن فعال است (برای شرکت،
شماره‌ی D-U-N-S هم لازم است). این همان تصمیمی است که برای تیارو هم هنوز باز است؛ هر راهی برای تیارو انتخاب شد،
برای عددی هم همان کار می‌کند.

بعد از داشتن حساب:

1. **Certificates, Identifiers & Profiles** ← Identifiers ← App ID تازه: `com.espadna.adadi`.
2. **App Store Connect** ← My Apps ← «+» ← New App: نام «Adadi: Math Crossword»، زبان اصلی English،
   Bundle ID همان بالا، SKU مثلاً `adadi`.
3. **محصول درون‌برنامه‌ای:** In-App Purchases ← Non-Consumable، Product ID **`remove_ads`**، قیمت
   (برای تیارو ۳٫۹۹ دلار بود).
4. **AdMob:** در پنل AdMob یک اپ iOS برای Adadi بسازید با دو واحد تبلیغ (Rewarded و Interstitial) و
   شناسه‌ها را برایم بفرستید (برای اندروید/گوگل‌پلی هم همین کار با یک اپ Android).
5. **کلید API اپ استور** (برای اینکه GitHub خودش بسازد و بفرستد، بدون مک): App Store Connect ← Users and Access ←
   Integrations ← App Store Connect API ← کلید تازه با نقش App Manager. سه چیز را به‌صورت secret در مخزن
   math-game بگذارید و خبر بدهید: `ASC_KEY_ID`، `ASC_ISSUER_ID`، `ASC_KEY_P8` (متن فایل .p8).
   من ساخت امضاشده و ارسال به **TestFlight** را روی GitHub راه می‌اندازم.
6. در App Store Connect: پرسش‌نامه‌ی **App Privacy** (Identifiers و Usage Data برای تبلیغات)، رده‌ی سنی
   **۱۲+/۱۳+**، لینک حریم خصوصی `https://adadi.espadna.com/privacy/`، اسکرین‌شات‌ها (آماده می‌کنم) و ارسال برای بررسی.

---

## بعدها: گوگل‌پلی

فایلش (`adadi-<نسخه>-play.aab`) هر بار ساخته می‌شود. حساب Google Play Console هم مثل اپل از ایران
محدودیت دارد؛ با همان حسابی که برای تیارو تصمیم گرفته شد قابل انجام است.
