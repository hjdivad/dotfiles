#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_dirty_tree() {
  create_branch "ns/task/a" --checkout

  # Create uncommitted changes
  echo "dirty" > somefile.txt
  git add somefile.txt

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "dirty"
}

run_test test_dirty_tree "dirty git tree → error"
