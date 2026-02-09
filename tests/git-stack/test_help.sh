#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_help_flag() {
  # help should work regardless of branch state
  local output exit_code=0
  output=$("$GIT_STACK" --help 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "Usage: git stack"

  # -h should also work
  exit_code=0
  output=$("$GIT_STACK" -h 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "Usage: git stack"
}

run_test test_help_flag "help flag prints usage and exits 0"
