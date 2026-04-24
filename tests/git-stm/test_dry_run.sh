#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Dry-run should: query gh (read-only) but never invoke pr ready / pr merge,
# never delete local M, never change the current branch, never push, and exit 0.
test_dry_run() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  make_stack_branch "hjdivad/foo/b" "hjdivad/foo/a" "feat: b"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/b" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  register_pr "hjdivad/foo/a" "master" 100 false
  register_pr "hjdivad/foo/b" "hjdivad/foo/a" 101 false

  local output exit_code=0
  output=$("$GIT_STM" --dry-run 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"

  # Plan must announce dry-run and print would-run commands for the
  # state-changing steps.
  assert_contains "$output" "mode           : dry-run"
  assert_contains "$output" "[dry-run] would run: gh pr ready --undo hjdivad/foo/b"
  assert_contains "$output" "[dry-run] would run: gh pr merge --squash --delete-branch"
  assert_contains "$output" "[dry-run] would run: git pu"
  assert_contains "$output" "[dry-run] would run: gh pr ready hjdivad/foo/b"
  assert_contains "$output" "Dry-run complete"

  # Read-only gh queries should still have happened.
  assert_gh_called "repo view --json defaultBranchRef --jq .defaultBranchRef.name"
  assert_gh_called "pr list --head hjdivad/foo/a --state open --json number,baseRefName --limit 1"

  # No state-changing gh calls should have hit the mock.
  assert_gh_not_called "^pr ready"
  assert_gh_not_called "^pr merge"

  # Mock state should be unchanged: PRs still present, b still ready.
  assert_pr_draft "hjdivad/foo/a" "false"
  assert_pr_draft "hjdivad/foo/b" "false"

  # Local branches all still present, still on /st.
  assert_branch_exists "hjdivad/foo/a"
  assert_branch_exists "hjdivad/foo/b"
  assert_branch_exists "hjdivad/foo/st"
  assert_on_branch "hjdivad/foo/st"
}

run_test test_dry_run "--dry-run prints plan and skips all side effects"
