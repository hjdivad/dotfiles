#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_auto_from_st() {
  create_branch "ns/task/st" --checkout

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/a"
  assert_contains "$output" "ns/task/a"

  # Go back to st and create another; a now exists so should get b
  git checkout --quiet "ns/task/st"
  exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/b"
  assert_contains "$output" "ns/task/b"
}

run_test test_auto_from_st "auto-increment from st branch"
