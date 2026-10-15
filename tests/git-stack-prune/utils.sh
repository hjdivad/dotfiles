#!/usr/bin/env bash
# Shared utilities for git-stack-prune tests.

PRUNE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(cd "$PRUNE_SCRIPT_DIR/../../bin" && pwd)"
# shellcheck disable=SC2034 # used by the test files that source this one
GIT_STACK_PRUNE="$BIN_DIR/git-stack-prune"

# Common helpers (assert_*, run_test, colours). That file overwrites
# SCRIPT_DIR, so we keep our own in PRUNE_SCRIPT_DIR.
# shellcheck disable=SC1091
source "$PRUNE_SCRIPT_DIR/../git-stack/utils.sh"

# Fixture:
#   $UPSTREAM: bare repo acting as origin (stands in for GitHub)
#   $WORKDIR:  clone of UPSTREAM, on master, where git-stack-prune runs
#   $MOCK_BIN: holds the mock `gh`, first on PATH
#   $MOCK_GH_STATE / $MOCK_GH_CALLS: mock state + call log
# The mock's gh user is `hjdivad`.

UPSTREAM=""
WORKDIR=""
MOCK_BIN=""
TEST_TMPDIR=""
ORIGINAL_PATH=""

setup() {
  TEST_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/git-stack-prune-test.XXXXXX")"
  TEST_TMPDIR="$(cd "$TEST_TMPDIR" && pwd -P)"
  UPSTREAM="$TEST_TMPDIR/upstream.git"
  WORKDIR="$TEST_TMPDIR/work"
  MOCK_BIN="$TEST_TMPDIR/bin"

  export MOCK_GH_STATE="$TEST_TMPDIR/gh-state"
  export MOCK_GH_CALLS="$TEST_TMPDIR/gh-calls"
  printf 'user=hjdivad\n' > "$MOCK_GH_STATE"
  : > "$MOCK_GH_CALLS"

  mkdir -p "$MOCK_BIN"
  cp "$PRUNE_SCRIPT_DIR/mock-gh" "$MOCK_BIN/gh"
  chmod +x "$MOCK_BIN/gh"

  ORIGINAL_PATH="$PATH"
  export PATH="$MOCK_BIN:$PATH"

  git init --quiet --bare --initial-branch=master "$UPSTREAM"
  local seed="$TEST_TMPDIR/seed"
  git clone --quiet "$UPSTREAM" "$seed" 2>/dev/null
  ( cd "$seed" || exit 1
    git config user.email "test@example.com"
    git config user.name "Test"
    git commit --allow-empty -m "initial" --quiet
    git push --quiet origin master
  )
  rm -rf "$seed"

  git clone --quiet "$UPSTREAM" "$WORKDIR"
  cd "$WORKDIR" || exit 1
  git config user.email "test@example.com"
  git config user.name "Test"
}

teardown() {
  if [[ -n "${ORIGINAL_PATH:-}" ]]; then
    export PATH="$ORIGINAL_PATH"
  fi
  if [[ -n "${TEST_TMPDIR:-}" && -d "$TEST_TMPDIR" ]]; then
    git -C "$WORKDIR" worktree prune 2>/dev/null || true
    rm -rf "$TEST_TMPDIR"
  fi
}

# Create a branch with one commit on top of <base>, push it to origin, and
# track it. Leaves you on master.
#   make_branch <branch> <base> <subject>
make_branch() {
  local branch="$1" base="$2" subject="$3"
  git checkout --quiet -b "$branch" "$base"
  printf '%s\n' "$subject" > "${branch//\//_}.txt"
  git add "${branch//\//_}.txt"
  git commit --quiet -m "$subject"
  git push --quiet origin "${branch}:refs/heads/${branch}"
  git branch --quiet --set-upstream-to="origin/${branch}" "$branch"
  git checkout --quiet master
}

# Add a commit to an existing local branch without pushing. Leaves you on
# master.
#   add_local_commit <branch> <subject>
add_local_commit() {
  local branch="$1" subject="$2"
  git checkout --quiet "$branch"
  git commit --quiet --allow-empty -m "$subject"
  git checkout --quiet master
}

# Register a PR whose head is the branch's current local tip.
#   register_pr <branch> <number> <state:MERGED|OPEN|CLOSED> [author]
register_pr() {
  local branch="$1" number="$2" state="$3" author="${4:-hjdivad}"
  local sha
  sha=$(git rev-parse "refs/heads/$branch")
  printf 'pr %s %s %s %s %s\n' "$branch" "$number" "$state" "$sha" "$author" >> "$MOCK_GH_STATE"
}

# Register a merged PR at the branch's tip and delete the head branch in
# origin, as GitHub does after a merge.
#   merge_pr <branch> <number> [author]
merge_pr() {
  register_pr "$1" "$2" MERGED "${3:-hjdivad}"
  git -C "$UPSTREAM" update-ref -d "refs/heads/$1"
}

set_mock() {
  printf '%s\n' "$1" >> "$MOCK_GH_STATE"
}

# Print every local ref with its SHA, for before/after comparisons.
snapshot_refs() {
  git for-each-ref --format='%(refname) %(objectname)'
}

assert_equal() {
  local expected="$1" actual="$2" what="$3"
  if [[ "$expected" != "$actual" ]]; then
    echo -e "${RED}FAIL${NC}: $what changed" >&2
    diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") >&2 || true
    return 1
  fi
}

assert_not_contains() {
  local haystack="$1" needle="$2"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo -e "${RED}FAIL${NC}: expected output to not contain '$needle'" >&2
    echo "  actual: $haystack" >&2
    return 1
  fi
}

assert_ref_exists() {
  if ! git show-ref --verify --quiet "$1"; then
    echo -e "${RED}FAIL${NC}: expected ref '$1' to exist" >&2
    return 1
  fi
}

assert_ref_not_exists() {
  if git show-ref --verify --quiet "$1"; then
    echo -e "${RED}FAIL${NC}: expected ref '$1' to NOT exist" >&2
    return 1
  fi
}

assert_upstream_branch_exists() {
  if ! git -C "$UPSTREAM" show-ref --verify --quiet "refs/heads/$1"; then
    echo -e "${RED}FAIL${NC}: expected origin branch '$1' to exist" >&2
    return 1
  fi
}

# Build the common stack: master <- a <- b, with st at b's tip, all pushed.
# Also creates look-alike branches that must never be touched.
make_stack() {
  make_branch "hjdivad/foo/a" "master" "feat: a"
  make_branch "hjdivad/foo/b" "hjdivad/foo/a" "feat: b"
  git branch --quiet "hjdivad/foo/st" "hjdivad/foo/b"
  git push --quiet origin "hjdivad/foo/st:refs/heads/hjdivad/foo/st"
  git branch --quiet --set-upstream-to="origin/hjdivad/foo/st" "hjdivad/foo/st"

  git branch --quiet "hjdivad/foobar/a" "hjdivad/foo/b"
  git branch --quiet "other/foo/a" "hjdivad/foo/b"
  git branch --quiet "hjdivad/foo-other" "hjdivad/foo/b"
}

assert_stack_intact() {
  assert_branch_exists "hjdivad/foo/a"
  assert_branch_exists "hjdivad/foo/b"
  assert_branch_exists "hjdivad/foo/st"
}

assert_outsiders_intact() {
  assert_branch_exists "hjdivad/foobar/a"
  assert_branch_exists "other/foo/a"
  assert_branch_exists "hjdivad/foo-other"
  assert_branch_exists "master"
}
