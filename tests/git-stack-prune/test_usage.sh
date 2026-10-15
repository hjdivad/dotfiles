#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_usage() {
  local output exit_code=0
  output=$("$GIT_STACK_PRUNE" --help 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "Usage: git stack-prune"

  exit_code=0
  output=$("$GIT_STACK_PRUNE" -h 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"

  exit_code=0
  output=$("$GIT_STACK_PRUNE" --bogus 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "Unknown option '--bogus'"

  exit_code=0
  output=$("$GIT_STACK_PRUNE" foo bar 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"

  # Glob characters could widen the ref pattern; reject them.
  exit_code=0
  output=$("$GIT_STACK_PRUNE" 'fo*' 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "Invalid stack name"

  # On master with no <name>: cannot derive the stack.
  exit_code=0
  output=$("$GIT_STACK_PRUNE" 2>&1) || exit_code=$?
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "does not match pattern 'hjdivad/{name}/*'"

  # Name derived from the current branch.
  make_stack
  merge_pr "hjdivad/foo/a" 100
  merge_pr "hjdivad/foo/b" 101
  git checkout --quiet "hjdivad/foo/st"
  exit_code=0
  output=$("$GIT_STACK_PRUNE" --check --ignore-worktree "$WORKDIR" 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "Stack 'hjdivad/foo/*'"
  assert_not_contains "$output" "foobar"

  # No matching branches: nothing to do.
  git checkout --quiet master
  exit_code=0
  output=$("$GIT_STACK_PRUNE" nosuchstack 2>&1) || exit_code=$?
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "nothing to prune"
}

run_test test_usage "help, usage errors, and stack-name derivation"
