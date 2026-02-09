#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_stack_limit() {
  # From st, with all single letters a-z taken → should error
  create_branch "ns/task/st" --checkout

  for c in {a..z}; do
    create_branch "ns/task/$c"
  done

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "Stack limit reached"
}

run_test test_stack_limit "stack limit from st when all single-letter branches exist"
