#!/usr/bin/env bash
# Builds adadi.espadna.com into dist-site/ (deployed by .github/workflows/site.yml):
#   /             the web game (Flutter web: no ads, no purchases; ?lang=en|fa|ar|ur)
#   /privacy/     privacy policy (docs/privacy/index.html, English + Persian)
#   /adadi-app/   landing pages (en, fa/, ar/), also served at espadna.com/adadi-app
#   files.json    manifests for the Iranian mirror (site/manifest.py)
# CanvasKit is bundled (--no-web-resources-cdn) so the game also runs where
# Google's CDN is unreachable, e.g. from the espadna.ir mirror.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf dist-site
(cd app && flutter build web --release --no-web-resources-cdn -o ../dist-site)
cp -r site/adadi-app dist-site/adadi-app
mkdir -p dist-site/privacy
cp docs/privacy/index.html dist-site/privacy/index.html
# Debug symbols are never loaded by browsers; ~10 MB less for every mirror sync.
find dist-site -name '*.symbols' -delete
python3 site/manifest.py dist-site
