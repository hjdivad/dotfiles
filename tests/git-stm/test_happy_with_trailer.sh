#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_happy_with_trailer() {
  make_stack_branch "hjdivad/foo/a" "origin/master" "feat: a"
  make_stack_branch "hjdivad/foo/b" "hjdivad/foo/a" "feat: b"
  make_stack_branch "hjdivad/foo/st" "hjdivad/foo/b" "wip: st"
  git checkout --quiet "hjdivad/foo/st"

  register_pr "hjdivad/foo/a" "master" 100 false
  register_pr "hjdivad/foo/b" "hjdivad/foo/a" 101 false

  local output exit_code=0
  output=$("$GIT_STM" "JIRA-123 #done" 2>&1) || exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" >&2
  fi
  assert_exit_code 0 "$exit_code"

  local subject body
  subject=$(mock_merged_subject)
  body=$(mock_merged_body)

  if [[ "$subject" != "feat: a" ]]; then
    echo -e "${RED}FAIL${NC}: expected subject 'feat: a', got '$subject'" >&2
    return 1
  fi
  if [[ "$body" != "JIRA-123 #done" ]]; then
    echo -e "${RED}FAIL${NC}: expected body 'JIRA-123 #done', got '$body'" >&2
    return 1
  fi
}

run_test test_happy_with_trailer "appends trailer arg to merge commit body"
