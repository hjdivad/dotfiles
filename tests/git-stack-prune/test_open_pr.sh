#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# a merged, b still open. Nothing may be deleted, not even a.
test_open_pr() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  register_pr "hjdivad/foo/b" 101 OPEN

  local before output exit_code=0
  before=$(snapshot_refs)
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "SAFE    hjdivad/foo/a"
  assert_contains "$output" "UNSAFE  hjdivad/foo/b"
  assert_contains "$output" "no merged PR"
  assert_contains "$output" "UNSAFE  hjdivad/foo/st"
  assert_contains "$output" "deleted nothing"
  assert_equal "$before" "$(snapshot_refs)" "refs"
}

run_test test_open_pr "one PR still open → nothing deleted, exit 1"
