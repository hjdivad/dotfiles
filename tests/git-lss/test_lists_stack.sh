#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../git-stack/utils.sh"

GIT_LSS="$(cd "$(dirname "$0")/../../bin" && pwd)/git-lss"

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo -e "${RED}FAIL${NC}: expected output to not contain '$needle'" >&2
    echo "  actual: $haystack" >&2
    return 1
  fi
}

test_lists_matching_stack() {
  create_branch "hjdivad/static_oauth_ui/st" --checkout
  create_branch "hjdivad/static_oauth_ui/j"
  create_branch "hjdivad/other_feature/a"

  local output exit_code=0
  output=$("$GIT_LSS" 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "* hjdivad/static_oauth_ui/st"
  assert_contains "$output" "hjdivad/static_oauth_ui/j"
  assert_not_contains "$output" "hjdivad/other_feature/a"
}

run_test test_lists_matching_stack "list stack branches for current task"
