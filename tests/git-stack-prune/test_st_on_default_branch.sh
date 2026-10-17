#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# A task abandoned before any commit: only /st exists, at origin/master, with
# no PRs. It holds nothing of its own, so it is safe and deleted.
test_st_on_default_branch() {
  git branch --quiet "hjdivad/foo/st" master
  git branch --quiet "hjdivad/foobar/st" master

  local output exit_code=0
  output=$("$GIT_STACK_PRUNE" foo 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "SAFE    hjdivad/foo/st"
  assert_contains "$output" "no merged PR; tip is on origin/master (no commits of its own)"

  assert_branch_not_exists "hjdivad/foo/st"
  assert_branch_exists "hjdivad/foobar/st"
  assert_branch_exists "master"
}

run_test test_st_on_default_branch "/st with no PRs at origin/master → deleted"
