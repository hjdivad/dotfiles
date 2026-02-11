#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_auto_from_st_with_gaps() {
  # Earlier branches (a, b) may have been merged. Only c and d remain.
  # From st, should increment from the largest (d) → e, not fill the gap at a.
  create_branch "ns/task/st" --checkout
  create_branch "ns/task/c"
  create_branch "ns/task/d"

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/e"
  assert_contains "$output" "ns/task/e"
}

run_test test_auto_from_st_with_gaps "from st, increments from largest existing suffix (skips gaps)"
