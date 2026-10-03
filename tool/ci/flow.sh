#!/usr/bin/env bash
# Runs the full player-journey test (integration_test/app_flow_test.dart) on
# the running emulator; screenshots go to smoke/flow/, logcat to smoke/.
set -u
OUT="$PWD/smoke"
mkdir -p "$OUT/flow"
adb logcat -c
cd app
SCREENSHOT_DIR="$OUT/flow" flutter drive \
  -d emulator-5554 \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart 2>&1 | tee "$OUT/flow.txt"
status=${PIPESTATUS[0]}
adb logcat -d -v time > "$OUT/flow-logcat.txt"
grep -nE "FATAL EXCEPTION|AndroidRuntime|E/flutter" "$OUT/flow-logcat.txt" | head -100
echo "flow test exit code: $status"
exit "$status"
