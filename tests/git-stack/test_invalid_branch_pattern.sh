#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_invalid_branch_pattern() {
  # Default branch (master/main) has no slashes → should fail
  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "does not match pattern"

  # Branch with only one slash segment
  create_branch "foo/bar" --checkout
  exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "does not match pattern"
}

run_test test_invalid_branch_pattern "invalid branch pattern → error"
