#!/usr/bin/env bash
set -euo pipefail

#MISE description="run git tests"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEST_ROOT="$REPO_ROOT/tests"

passed=0
failed=0
failures=()

for test_dir in "$TEST_ROOT"/git-*; do
  [[ -d "$test_dir" ]] || continue

  for test_file in "$test_dir"/test_*.sh; do
    [[ -f "$test_file" ]] || continue

    test_name="$(basename "$test_dir")/$(basename "$test_file")"
    if bash "$test_file"; then
      passed=$((passed + 1))
    else
      failed=$((failed + 1))
      failures+=("$test_name")
    fi
  done
done

echo ""
echo "--- git test results ---"
echo "Passed: $passed"
echo "Failed: $failed"

if [[ $failed -gt 0 ]]; then
  echo "Failures:"
  for f in "${failures[@]}"; do
    echo "  - $f"
  done
  exit 1
fi
