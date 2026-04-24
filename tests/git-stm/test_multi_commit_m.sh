#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_multi_commit_m() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  # Add a second commit to a, then push.
  git checkout --quiet "hjdivad/foo/a"
  printf 'extra\n' > extra.txt
  git add extra.txt
  git commit --quiet -m "second commit on a"
  git push --quiet origin "hjdivad/foo/a"

  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/a" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  register_pr "hjdivad/foo/a" "master" 100

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "expected exactly 1"
  # Must not have attempted any state-changing gh calls.
  assert_gh_not_called "^pr merge"
  assert_gh_not_called "^pr ready"
}

run_test test_multi_commit_m "errors when M has more than one commit beyond default branch"
