// Renders the app icon from branding/*.svg into every platform size:
// iOS AppIcon set, Android legacy + adaptive launcher icons, web icons.
//   node tool/make_icons.js
// Needs Playwright with a Chromium (`npm i playwright`), and ImageMagick's
// `convert` to drop the alpha channel the App Store rejects.
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { chromium } = require('playwright');

const app = path.join(__dirname, '..');
const svg = (name) =>
  'data:image/svg+xml;base64,' +
  fs.readFileSync(path.join(app, 'branding', name)).toString('base64');

// [svg, output path, size px, corner radius as a fraction of size]
const jobs = [];
const ios = path.join(app, 'ios/Runner/Assets.xcassets/AppIcon.appiconset');
for (const img of JSON.parse(fs.readFileSync(path.join(ios, 'Contents.json'))).images) {
  const px = Math.round(parseFloat(img.size) * parseInt(img.scale));
  jobs.push(['icon.svg', path.join(ios, img.filename), px, 0, 'opaque']);
}
const res = path.join(app, 'android/app/src/main/res');
const densities = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
for (const [d, k] of Object.entries(densities)) {
  // Legacy (pre-Android 8) icon: 48dp, rounded square.
  jobs.push(['icon.svg', `${res}/mipmap-${d}/ic_launcher.png`, 48 * k, 0.18]);
  // Adaptive icon layers: 108dp, the launcher applies the mask.
  jobs.push(['icon_foreground.svg', `${res}/mipmap-${d}/ic_launcher_foreground.png`, 108 * k, 0]);
  jobs.push(['icon_background.svg', `${res}/mipmap-${d}/ic_launcher_background.png`, 108 * k, 0]);
}
const web = path.join(app, 'web');
jobs.push(['icon.svg', `${web}/favicon.png`, 32, 0.18]);
jobs.push(['icon.svg', `${web}/icons/Icon-192.png`, 192, 0.18]);
jobs.push(['icon.svg', `${web}/icons/Icon-512.png`, 512, 0.18]);
jobs.push(['icon.svg', `${web}/icons/Icon-maskable-192.png`, 192, 0]);
jobs.push(['icon.svg', `${web}/icons/Icon-maskable-512.png`, 512, 0]);

(async () => {
  const browser = await chromium.launch(
    process.env.CHROMIUM ? { executablePath: process.env.CHROMIUM } : {},
  );
  const page = await browser.newPage();
  for (const [src, out, px, radius, opaque] of jobs) {
    await page.setViewportSize({ width: px, height: px });
    await page.setContent(
      `<body style="margin:0;background:transparent">` +
        `<img src="${svg(src)}" width="${px}" height="${px}" ` +
        `style="display:block;border-radius:${radius * px}px"></body>`,
    );
    await page.waitForFunction(() => document.images[0].complete);
    await page.screenshot({ path: out, omitBackground: !opaque });
    if (opaque) execFileSync('convert', [out, '-alpha', 'off', out]);
  }
  await browser.close();

  const anydpi = `${res}/mipmap-anydpi-v26`;
  fs.mkdirSync(anydpi, { recursive: true });
  fs.writeFileSync(
    `${anydpi}/ic_launcher.xml`,
    `<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
`,
  );
  console.log(`wrote ${jobs.length} icons + adaptive icon xml`);
})();
