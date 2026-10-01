#!/usr/bin/env bash
set -euo pipefail

IMAGE="${GODOT_IMAGE:-barichello/godot-ci:4.3}"

run_godot() {
  docker run --rm \
    -v "$PWD:/workspace" \
    -w /workspace \
    "$IMAGE" bash -lc "$1"
}

mkdir -p agent-logs

run_godot 'set -o pipefail; godot --headless --path . --editor --quit 2>&1 | tee /workspace/agent-logs/import.log; ! grep -Eq "SCRIPT ERROR:|Parse Error:|ERROR:" /workspace/agent-logs/import.log'

for suite in game learning learning_ui town town_ui journey journey_ui journey_layout journey_rooms journey_spacing; do
  testfile="tests/test_${suite}.gd"
  if [ -f "$testfile" ]; then
    echo "=== $testfile ==="
    run_godot "set -o pipefail; timeout 120 godot --headless --path . --script $testfile 2>&1 | tee /workspace/agent-logs/${suite}.log"
    if grep -Eq 'SCRIPT ERROR:|Parse Error:|ERROR:|FAIL:' "agent-logs/${suite}.log"; then
      echo "Detected failure marker in $suite"
      exit 1
    fi
    if ! grep -Eq 'PASSED|failures: 0|integration: passed|TESTS_PASSED' "agent-logs/${suite}.log"; then
      echo "No success marker found in $suite"
      exit 1
    fi
  fi
done

echo "AGENT_VERIFY_PASSED"
