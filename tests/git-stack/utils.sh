#!/usr/bin/env bash
# Shared utilities for git-stack tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_STACK="$(cd "$SCRIPT_DIR/../../bin" && pwd)/git-stack"

# Colour output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TEST_TMPDIR=""

setup() {
  TEST_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/git-stack-test.XXXXXX")"
  cd "$TEST_TMPDIR"
  git init --quiet
  git commit --allow-empty -m "initial" --quiet
}

teardown() {
  if [[ -n "$TEST_TMPDIR" && -d "$TEST_TMPDIR" ]]; then
    rm -rf "$TEST_TMPDIR"
  fi
}

# Create a branch and optionally switch to it
#   create_branch <branch_name> [--checkout]
create_branch() {
  local branch="$1"
  local checkout="${2:-}"
  git branch "$branch" 2>/dev/null || true
  if [[ "$checkout" == "--checkout" ]]; then
    git checkout --quiet "$branch"
  fi
}

# Assert that the command exits with the expected code
#   assert_exit_code <expected> <actual>
assert_exit_code() {
  local expected="$1"
  local actual="$2"
  if [[ "$actual" -ne "$expected" ]]; then
    echo -e "${RED}FAIL${NC}: expected exit code $expected, got $actual" >&2
    return 1
  fi
}

# Assert that a string contains a substring
#   assert_contains <haystack> <needle>
assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo -e "${RED}FAIL${NC}: expected output to contain '$needle'" >&2
    echo "  actual: $haystack" >&2
    return 1
  fi
}

# Assert that we are on a given branch
#   assert_on_branch <branch_name>
assert_on_branch() {
  local expected="$1"
  local actual
  actual="$(git branch --show-current)"
  if [[ "$actual" != "$expected" ]]; then
    echo -e "${RED}FAIL${NC}: expected to be on branch '$expected', but on '$actual'" >&2
    return 1
  fi
}

# Assert that a branch exists
#   assert_branch_exists <branch_name>
assert_branch_exists() {
  local branch="$1"
  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    echo -e "${RED}FAIL${NC}: expected branch '$branch' to exist" >&2
    return 1
  fi
}

# Assert that a branch does NOT exist
#   assert_branch_not_exists <branch_name>
assert_branch_not_exists() {
  local branch="$1"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo -e "${RED}FAIL${NC}: expected branch '$branch' to NOT exist" >&2
    return 1
  fi
}

# Run a test function with setup/teardown.
# Call this at the bottom of each test file.
#   run_test <test_function_name>
run_test() {
  local test_fn="$1"
  local test_name="${2:-$test_fn}"
  setup
  trap teardown EXIT
  if "$test_fn"; then
    echo -e "${GREEN}PASS${NC}: $test_name"
  else
    echo -e "${RED}FAIL${NC}: $test_name"
    exit 1
  fi
}
