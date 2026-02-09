#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_explicit_collision() {
  create_branch "ns/task/a" --checkout
  create_branch "ns/task/b"

  local output exit_code=0
  output=$("$GIT_STACK" b 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "already exists"
}

run_test test_explicit_collision "explicit item collides with existing branch → error"
