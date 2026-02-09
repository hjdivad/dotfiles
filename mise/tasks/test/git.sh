#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEST_DIR="$REPO_ROOT/tests/git-stack"

passed=0
failed=0
failures=()

for test_file in "$TEST_DIR"/test_*.sh; do
  test_name="$(basename "$test_file")"
  if bash "$test_file"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    failures+=("$test_name")
  fi
done

echo ""
echo "--- git-stack test results ---"
echo "Passed: $passed"
echo "Failed: $failed"

if [[ $failed -gt 0 ]]; then
  echo "Failures:"
  for f in "${failures[@]}"; do
    echo "  - $f"
  done
  exit 1
fi
