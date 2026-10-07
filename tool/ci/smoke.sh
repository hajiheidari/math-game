#!/usr/bin/env bash
# Installs the APK on the running emulator, launches it, and collects
# screenshots + logcat into ./smoke/. Used by .github/workflows/emulator.yml.
set -u
APK="$1"
PKG=com.espadna.adadi
OUT=${SMOKE_OUT:-smoke}
mkdir -p "$OUT"

adb wait-for-device
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

adb install -r "$APK" | tee "$OUT/install.txt"
adb logcat -c
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null

for t in 5 15 30; do
  sleep $((t - ${prev:-0})); prev=$t
  adb exec-out screencap -p > "$OUT/shot-${t}s.png"
  if adb shell pidof "$PKG" >/dev/null; then
    echo "t=${t}s: app process running" | tee -a "$OUT/status.txt"
  else
    echo "t=${t}s: APP PROCESS NOT RUNNING" | tee -a "$OUT/status.txt"
  fi
  adb shell dumpsys activity activities | grep -E "mResumedActivity|topResumedActivity" | head -2 | tee -a "$OUT/status.txt"
done

adb logcat -d -v time > "$OUT/logcat.txt"
echo "===== crashes / errors ====="
grep -nE "FATAL EXCEPTION|AndroidRuntime|E/flutter|F/libc|DEBUG   :|Adadi|com.espadna.adadi" "$OUT/logcat.txt" | head -300

# Fail the job unless the app is still up and not on the crash screen.
if tail -2 "$OUT/status.txt" | grep -qE "NOT RUNNING|CrashActivity"; then
  echo "SMOKE TEST FAILED: app crashed or exited"
  exit 1
fi
echo "SMOKE TEST PASSED"
exit 0
