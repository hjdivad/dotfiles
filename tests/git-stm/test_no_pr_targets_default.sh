#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_no_pr_targets_default() {
  # Build a stack but don't register any PRs.
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/a" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "No stack branch has an open PR targeting"
}

run_test test_no_pr_targets_default "errors when no PR targets the default branch"
