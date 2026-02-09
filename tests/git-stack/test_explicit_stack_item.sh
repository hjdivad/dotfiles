#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_explicit_stack_item() {
  create_branch "ns/task/a" --checkout

  local output exit_code=0
  output=$("$GIT_STACK" foo 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/foo"
  assert_contains "$output" "ns/task/foo"
}

run_test test_explicit_stack_item "explicit stack item creates correct branch"
