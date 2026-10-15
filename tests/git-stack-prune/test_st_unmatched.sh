#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# All PRs merged, but st has a commit beyond the top PR.
test_st_unmatched() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101
  add_local_commit "hjdivad/foo/st" "wip: unpublished"

  local before output exit_code=0
  before=$(snapshot_refs)
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "SAFE    hjdivad/foo/b"
  assert_contains "$output" "UNSAFE  hjdivad/foo/st"
  assert_contains "$output" "tip matches no merged head in this stack"
  assert_equal "$before" "$(snapshot_refs)" "refs"
}

run_test test_st_unmatched "/st tip matches no PR → nothing deleted, exit 1"
