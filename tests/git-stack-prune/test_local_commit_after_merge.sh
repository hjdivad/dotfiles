#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# b was merged, then got another local commit. That commit would be lost.
test_local_commit_after_merge() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101
  add_local_commit "hjdivad/foo/b" "fix: after merge"

  local before output exit_code=0
  before=$(snapshot_refs)
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "UNSAFE  hjdivad/foo/b"
  assert_contains "$output" "local commits after merge of PR #101"
  assert_equal "$before" "$(snapshot_refs)" "refs"
}

run_test test_local_commit_after_merge "local commit after merge → nothing deleted, exit 1"
