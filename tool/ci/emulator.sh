#!/usr/bin/env bash
# Everything the emulator job runs: release-APK smoke test, then the full
# journey test. Fails if either fails, but always runs both.
set -u
bash tool/ci/smoke.sh "$1"; smoke=$?
bash tool/ci/flow.sh; flow=$?
echo "smoke=$smoke flow=$flow"
[ "$smoke" -eq 0 ] && [ "$flow" -eq 0 ]
