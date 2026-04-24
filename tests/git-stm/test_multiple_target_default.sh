#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_multiple_target_default() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  make_stack_branch "hjdivad/foo/b" "origin/master" "feat: b"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/b" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  # Both a and b target master -- malformed stack.
  register_pr "hjdivad/foo/a" "master" 100
  register_pr "hjdivad/foo/b" "master" 101

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "Multiple stack branches target"
}

run_test test_multiple_target_default "errors when multiple PRs target default branch"
