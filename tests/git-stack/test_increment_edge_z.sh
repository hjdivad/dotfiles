#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_increment_edge_z() {
  # On branch y, with z existing → increment_suffix("y") gives "z",
  # z exists → increment_suffix("z") gives "za", za is free → creates za
  create_branch "ns/task/y" --checkout
  create_branch "ns/task/z"

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/za"
  assert_contains "$output" "ns/task/za"

  # On branch z → first_char == z → stack limit error
  teardown
  setup
  create_branch "ns/task/z" --checkout

  exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "Stack limit reached"
}

run_test test_increment_edge_z "increment edge cases: z wraps to za, z-prefix hits limit"
