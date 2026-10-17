#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# No PRs anywhere. /st has a commit that is not on origin/master, and a slice
# branch sits at origin/master. Neither may be deleted: /st would lose work,
# and the origin/master exception applies only to /st.
test_st_own_commits_no_prs() {
  git branch --quiet "hjdivad/foo/st" master
  add_local_commit "hjdivad/foo/st" "wip: unpublished"
  git branch --quiet "hjdivad/foo/a" master

  local before output exit_code=0
  before=$(snapshot_refs)
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "UNSAFE  hjdivad/foo/st"
  assert_contains "$output" "UNSAFE  hjdivad/foo/a"
  assert_contains "$output" "tip matches no merged head in this stack"
  assert_not_contains "$output" "no commits of its own"
  assert_equal "$before" "$(snapshot_refs)" "refs"
}

run_test test_st_own_commits_no_prs "/st with its own commits and no PRs → nothing deleted, exit 1"
