#!/usr/bin/env bash
# Builds the app for one store, without the other store's SDKs:
#   tool/store_build.sh global apk|appbundle|ipa [flutter build args...]
#   tool/store_build.sh bazaar apk [flutter build args...]
# global: App Store / Google Play (AdMob + the stores' billing, lib/main.dart).
# bazaar: Cafe Bazaar (Adivery + Poolakey, Persian first, lib/main_bazaar.dart).
# Google Play and Bazaar both reject apps that ship a rival store's billing
# SDK, so each build drops the other one's packages from pubspec.yaml for the
# duration of the build (restored afterwards).
set -euo pipefail
store="$1"; kind="$2"; shift 2
cd "$(dirname "$0")/../app"
case "$store" in
  global) drop='adivery|flutter_poolakey'; target=lib/main.dart ;;
  bazaar) drop='google_mobile_ads|in_app_purchase|app_tracking_transparency'; target=lib/main_bazaar.dart ;;
  *) echo "store must be global or bazaar" >&2; exit 2 ;;
esac
cp pubspec.yaml /tmp/adadi-pubspec.yaml.bak
cp pubspec.lock /tmp/adadi-pubspec.lock.bak
restore() {
  cp /tmp/adadi-pubspec.yaml.bak pubspec.yaml
  cp /tmp/adadi-pubspec.lock.bak pubspec.lock
  flutter pub get >/dev/null 2>&1 || true
}
trap restore EXIT
grep -vE "^  ($drop):" /tmp/adadi-pubspec.yaml.bak > pubspec.yaml
flutter pub get
flutter build "$kind" --release -t "$target" --dart-define=STORE="$store" "$@"
# Free Gradle's memory before the next build (CI runs several in a row).
if [ "$kind" != ios ] && [ "$kind" != ipa ]; then
  (cd android && ./gradlew --stop >/dev/null 2>&1) || true
fi
