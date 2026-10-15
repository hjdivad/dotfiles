#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Stack: master <- a <- b, st at b. Both PRs merged at the local tips.
# Expect a, b, and st deleted; look-alike branches and origin's st untouched;
# stale remote-tracking refs pruned.
test_all_merged() {
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101

  local output exit_code=0
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"

  assert_contains "$output" "SAFE    hjdivad/foo/a"
  assert_contains "$output" "SAFE    hjdivad/foo/st"
  assert_contains "$output" "tip matches merged head of hjdivad/foo/b (PR #101)"

  assert_branch_not_exists "hjdivad/foo/a"
  assert_branch_not_exists "hjdivad/foo/b"
  assert_branch_not_exists "hjdivad/foo/st"
  assert_outsiders_intact

  # Branch config sections are removed along with the refs.
  if git config --get "branch.hjdivad/foo/a.remote" >/dev/null; then
    echo -e "${RED}FAIL${NC}: expected branch.hjdivad/foo/a config to be removed" >&2
    return 1
  fi

  # fetch --prune dropped the remote-tracking refs GitHub already deleted...
  assert_ref_not_exists "refs/remotes/origin/hjdivad/foo/a"
  assert_ref_not_exists "refs/remotes/origin/hjdivad/foo/b"
  # ...but origin's /st (no PR, so GitHub keeps it) was never deleted.
  assert_upstream_branch_exists "hjdivad/foo/st"
  assert_ref_exists "refs/remotes/origin/hjdivad/foo/st"

  # Only read-only gh calls.
  if grep -Ev '^(api user -q \.login|pr list --head [^ ]+ --state merged --json number,headRefOid,author,url)$' "$MOCK_GH_CALLS"; then
    echo -e "${RED}FAIL${NC}: unexpected gh call" >&2
    return 1
  fi
}

run_test test_all_merged "all PRs merged at tips → stack deleted, outsiders and remotes kept"
