#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# A stack branch checked out in another worktree blocks everything, except
# under --check --ignore-worktree <that worktree>.
test_checked_out() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101
  local wt="$TEST_TMPDIR/wt-foo"
  git worktree add --quiet "$wt" "hjdivad/foo/st"

  local before output exit_code=0
  before=$(snapshot_refs)
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?
  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "UNSAFE  hjdivad/foo/st"
  assert_contains "$output" "checked out in worktree $wt"
  assert_equal "$before" "$(snapshot_refs)" "refs"

  # The worktree about to be removed can be ignored for the preflight check.
  exit_code=0
  output=$(cd "$wt" && "$GIT_STACK_PRUNE" --check --ignore-worktree "$wt" 2>&1) || exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "Stack 'hjdivad/foo/*'"

  # ...but never for a deleting run.
  exit_code=0
  output=$("$GIT_STACK_PRUNE" --ignore-worktree "$wt" foo 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "only valid with --check"
  assert_equal "$before" "$(snapshot_refs)" "refs"

  # After the worktree is removed (dev:done's post-removal run), it succeeds.
  git worktree remove "$wt"
  exit_code=0
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_branch_not_exists "hjdivad/foo/st"
  assert_outsiders_intact
}

run_test test_checked_out "branch checked out in a worktree → unsafe unless ignored for --check"
