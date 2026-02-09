#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_auto_substack() {
  # On branch b, with c already existing → increment_suffix("b") gives "c",
  # c exists → increment_suffix("c") gives "d", d is free → creates d
  create_branch "ns/task/b" --checkout
  create_branch "ns/task/c"

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/d"
  assert_contains "$output" "ns/task/d"

  # From d (no e exists) → simple next major: e
  exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/e"
  assert_contains "$output" "ns/task/e"
}

run_test test_auto_substack "auto-increment skips existing next-major branches"
