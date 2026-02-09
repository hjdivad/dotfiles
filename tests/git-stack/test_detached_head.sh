#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_detached_head() {
  git checkout --quiet --detach HEAD

  local output exit_code=0
  output=$("$GIT_STACK" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "Not on a branch"
}

run_test test_detached_head "detached HEAD → error"
