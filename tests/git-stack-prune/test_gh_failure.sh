#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# gh failures are never treated as safe, and exit 2.
test_gh_failure() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101

  local before output exit_code=0
  before=$(snapshot_refs)

  # pr list fails.
  set_mock "fail_pr_list=1"
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "gh error: mock-gh: error connecting"
  assert_contains "$output" "deleted nothing"
  assert_equal "$before" "$(snapshot_refs)" "refs"

  # Current-user lookup fails.
  printf 'user=hjdivad\nfail_user=1\n' > "$MOCK_GH_STATE.new"
  grep '^pr ' "$MOCK_GH_STATE" >> "$MOCK_GH_STATE.new"
  mv "$MOCK_GH_STATE.new" "$MOCK_GH_STATE"
  exit_code=0
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "gh error: could not determine gh user"
  assert_equal "$before" "$(snapshot_refs)" "refs"
}

run_test test_gh_failure "gh failure → nothing deleted, exit 2"
