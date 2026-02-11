#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_stack_limit() {
  # From st, with all single letters a-z taken → max is z,
  # increment_suffix("z") = "za", so it creates za (no longer an error)
  create_branch "ns/task/st" --checkout

  for c in {a..z}; do
    create_branch "ns/task/$c"
  done

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_on_branch "ns/task/za"
  assert_contains "$output" "ns/task/za"
}

run_test test_stack_limit "from st with all a-z taken, wraps to za"
