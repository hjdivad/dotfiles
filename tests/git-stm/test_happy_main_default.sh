#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Repo's default branch is "main" (not master). git stm should detect this
# and use it for filtering, fetch, and rebase.
test_happy_main_default() {
  # Rename master -> main on the upstream and locally.
  git -C "$UPSTREAM" branch -m master main
  git -C "$UPSTREAM" symbolic-ref HEAD refs/heads/main
  git fetch --quiet origin
  git branch -m master main
  git branch --quiet --set-upstream-to=origin/main main || true

  # Recreate the remote-tracking ref properly.
  git remote set-head origin -d >/dev/null 2>&1 || true
  git remote set-head origin main >/dev/null

  set_default_branch "main"

  make_stack_branch "hjdivad/foo/a" "origin/main" "feat: a"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/a" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  register_pr "hjdivad/foo/a" "main" 100 false

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"

  assert_contains "$output" "default branch : main"
  assert_pr_gone "hjdivad/foo/a"
}

run_test test_happy_main_default "detects 'main' as default branch"
