#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# a moves after its tip was verified (while b is being checked). The
# compare-and-delete must keep a and report a git failure.
test_moved_after_check() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101

  local moved
  moved=$(git commit-tree "$(git rev-parse 'hjdivad/foo/a^{tree}')" -p hjdivad/foo/a -m "moved")
  set_mock "move_on_list hjdivad/foo/b $WORKDIR refs/heads/hjdivad/foo/a $moved"

  local output exit_code=0
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "failed to delete hjdivad/foo/a"
  assert_contains "$output" "skipping 'git fetch --prune origin'"
  assert_branch_exists "hjdivad/foo/a"
  if [[ "$(git rev-parse hjdivad/foo/a)" != "$moved" ]]; then
    echo -e "${RED}FAIL${NC}: expected hjdivad/foo/a to keep its moved tip" >&2
    return 1
  fi
  assert_outsiders_intact
}

run_test test_moved_after_check "branch moved after verification → kept, exit 2"
