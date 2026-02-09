#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_auto_increment() {
  create_branch "ns/task/a" --checkout

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/b"
  assert_contains "$output" "ns/task/b"
}

run_test test_auto_increment "auto-increment from single letter (a→b)"
