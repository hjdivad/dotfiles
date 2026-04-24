#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Stack: master <- a <- st  (no N)
test_happy_no_n() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/a" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  register_pr "hjdivad/foo/a" "master" 100 false

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"

  assert_pr_gone "hjdivad/foo/a"
  assert_branch_not_exists "hjdivad/foo/a"
  assert_on_branch "hjdivad/foo/st"

  # No pr ready calls should have been made.
  assert_gh_not_called "^pr ready"

  assert_contains "$output" "<none>"
}

run_test test_happy_no_n "merges M with no next branch (no N)"
