#!/usr/bin/env bash
# Everything the emulator job runs: release-APK smoke test, the full journey
# test, then the Cafe Bazaar APK's smoke test ($2). Fails if any of them fails, but always runs all.
set -u
bash tool/ci/smoke.sh "$1"; smoke=$?
bash tool/ci/flow.sh; flow=$?
bazaar=0
if [ -n "${2:-}" ]; then
  SMOKE_OUT=smoke/bazaar bash tool/ci/smoke.sh "$2"; bazaar=$?
fi
echo "smoke=$smoke flow=$flow bazaar=$bazaar"
[ "$smoke" -eq 0 ] && [ "$flow" -eq 0 ] && [ "$bazaar" -eq 0 ]
