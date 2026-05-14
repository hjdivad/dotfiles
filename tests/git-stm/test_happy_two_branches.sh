#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Stack: master <- a <- b <- st
# Run git stm; expect a to be merged, b to flap draft->ready, st rebased.
test_happy_two_branches() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  make_stack_branch "hjdivad/foo/b" "hjdivad/foo/a" "feat: b"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/b" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  register_pr "hjdivad/foo/a" "master" 100 false
  register_pr "hjdivad/foo/b" "hjdivad/foo/a" 101 false

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi

  assert_exit_code 0 "$exit_code"

  # PR a should be gone (merged) and b should be ready (false).
  assert_pr_gone "hjdivad/foo/a"
  assert_pr_draft "hjdivad/foo/b" "false"

  # Mock should have observed the draft toggle for b.
  assert_gh_called "pr ready --undo hjdivad/foo/b"
  assert_gh_called "pr ready hjdivad/foo/b"

  # We must NOT pass --delete-branch: rely on GitHub auto-delete + our local
  # `git branch -D`. Passing it would also delete the remote branch which
  # interferes with auto-retargeting and any concurrent stack tooling.
  assert_gh_not_called "delete-branch"

  # Local M deleted, st still present and current.
  assert_branch_not_exists "hjdivad/foo/a"
  assert_branch_exists "hjdivad/foo/st"
  assert_on_branch "hjdivad/foo/st"

  # Merged subject matches the single commit on a.
  local subject
  subject=$(mock_merged_subject)
  if [[ "$subject" != "feat: a" ]]; then
    echo -e "${RED}FAIL${NC}: expected merged subject 'feat: a', got '$subject'" >&2
    return 1
  fi

  # Body should be empty (no extra body, no trailer).
  local body
  body=$(mock_merged_body)
  if [[ -n "$body" ]]; then
    echo -e "${RED}FAIL${NC}: expected empty merged body, got '$body'" >&2
    return 1
  fi

  # Local st should now be rebased onto origin/master, which contains a's commit.
  if ! git log --format=%s | grep -qx "feat: a"; then
    echo -e "${RED}FAIL${NC}: expected st history to contain 'feat: a' commit after rebase" >&2
    git log --format=%s >&2
    return 1
  fi
}

run_test test_happy_two_branches "merges M, leaves N ready, rebases /st"
