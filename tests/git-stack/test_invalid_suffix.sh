#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_invalid_suffix() {
  # Suffix with uppercase → should fail
  create_branch "ns/task/A" --checkout

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "must match [a-z]+"

  # Suffix with digits
  create_branch "ns/task/a1" --checkout
  exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "must match [a-z]+"
}

run_test test_invalid_suffix "branch suffix not [a-z]+ → error"
