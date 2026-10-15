#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# a's only merged PR at the tip was opened by someone else.
test_other_author() {
  make_stack
  merge_pr "hjdivad/foo/a" 100 "someone-else"
  merge_pr "hjdivad/foo/b" 101

  local before output exit_code=0
  before=$(snapshot_refs)
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "UNSAFE  hjdivad/foo/a"
  assert_contains "$output" "different author: merged PR #100 by someone-else, not hjdivad"
  assert_equal "$before" "$(snapshot_refs)" "refs"
}

run_test test_other_author "merged PR by another author → nothing deleted, exit 1"
