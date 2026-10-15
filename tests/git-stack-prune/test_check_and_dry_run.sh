#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# --check and --dry-run verify a safe stack but change no refs and do not
# fetch (the stale origin/hjdivad/foo/a remote-tracking ref survives).
test_check_and_dry_run() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101

  local before output exit_code=0
  before=$(snapshot_refs)

  output=$("$GIT_STACK_PRUNE" --check foo 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "All 3 branch(es) are safe to delete."
  assert_not_contains "$output" "Would execute"
  assert_not_contains "$output" "Deleted"
  assert_equal "$before" "$(snapshot_refs)" "refs after --check"

  exit_code=0
  output=$("$GIT_STACK_PRUNE" --dry-run foo 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "[dry-run] Would execute:"
  assert_contains "$output" "git update-ref -d refs/heads/hjdivad/foo/st $(git rev-parse hjdivad/foo/st)"
  assert_contains "$output" "git fetch --prune origin"
  assert_not_contains "$output" "Deleted"
  assert_equal "$before" "$(snapshot_refs)" "refs after --dry-run"

  exit_code=0
  output=$("$GIT_STACK_PRUNE" -n --check foo 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_equal "$before" "$(snapshot_refs)" "refs after -n --check"

  assert_ref_exists "refs/remotes/origin/hjdivad/foo/a"

  # Unsafe stacks still exit 1 under --check.
  add_local_commit "hjdivad/foo/st" "wip"
  exit_code=0
  output=$("$GIT_STACK_PRUNE" --check foo 2>&1) || exit_code=$?
  assert_exit_code 1 "$exit_code"
}

run_test test_check_and_dry_run "--check and --dry-run change nothing"
