#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_not_on_st() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  git checkout --quiet "hjdivad/foo/a"

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "must be run from the stack-top branch"
}

run_test test_not_on_st "errors when not on /st branch"
