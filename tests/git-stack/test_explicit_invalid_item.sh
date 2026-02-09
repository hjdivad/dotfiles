#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_explicit_invalid_item() {
  create_branch "ns/task/a" --checkout

  # Uppercase
  local output exit_code=0
  output=$("$GIT_STACK" FOO 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "must match [a-z]+"

  # Digits
  exit_code=0
  output=$("$GIT_STACK" a1 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "must match [a-z]+"
}

run_test test_explicit_invalid_item "explicit invalid stack item → error"
