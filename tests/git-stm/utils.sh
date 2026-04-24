#!/usr/bin/env bash
# Shared utilities for git-stm tests.

STM_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(cd "$STM_SCRIPT_DIR/../../bin" && pwd)"
GIT_STM="$BIN_DIR/git-stm"

# Source common helpers from git-stack utils (assert_*, run_test, colors).
# Note: that file overwrites SCRIPT_DIR via BASH_SOURCE[0], so we keep our own
# in STM_SCRIPT_DIR.
# shellcheck disable=SC1091
source "$STM_SCRIPT_DIR/../git-stack/utils.sh"

# We override setup/teardown to build a more elaborate fixture:
#   - $UPSTREAM: bare repo acting as origin
#   - $WORKDIR: clone of UPSTREAM (the repo we run git stm in)
#   - $MOCK_BIN: dir holding the mock `gh` and a `git-pu` shim
#   - $MOCK_GH_STATE / $MOCK_GH_CALLS: mock state + call log
#
# PATH is rewritten so `gh` resolves to the mock and `git pu` resolves to
# our copy of bin/git-pu.

UPSTREAM=""
WORKDIR=""
MOCK_BIN=""
TEST_TMPDIR=""
ORIGINAL_PATH=""

setup() {
  TEST_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/git-stm-test.XXXXXX")"
  UPSTREAM="$TEST_TMPDIR/upstream.git"
  WORKDIR="$TEST_TMPDIR/work"
  MOCK_BIN="$TEST_TMPDIR/bin"

  export MOCK_GH_STATE="$TEST_TMPDIR/gh-state"
  export MOCK_GH_CALLS="$TEST_TMPDIR/gh-calls"
  : > "$MOCK_GH_STATE"
  : > "$MOCK_GH_CALLS"

  mkdir -p "$MOCK_BIN"
  cp "$STM_SCRIPT_DIR/mock-gh" "$MOCK_BIN/gh"
  chmod +x "$MOCK_BIN/gh"
  # Expose git-pu via PATH so `git pu` works inside git-stm.
  cp "$BIN_DIR/git-pu" "$MOCK_BIN/git-pu"
  chmod +x "$MOCK_BIN/git-pu"

  ORIGINAL_PATH="$PATH"
  export PATH="$MOCK_BIN:$PATH"

  # Build the bare upstream with an initial commit on master.
  git init --quiet --bare --initial-branch=master "$UPSTREAM"

  # Seed master via a temporary clone. The bare upstream is empty at this
  # point so git emits a harmless "cloned an empty repository" warning;
  # silence it to keep test output clean.
  local seed="$TEST_TMPDIR/seed"
  git clone --quiet "$UPSTREAM" "$seed" 2>/dev/null
  ( cd "$seed"
    git config user.email "test@example.com"
    git config user.name "Test"
    git commit --allow-empty -m "initial" --quiet
    git push --quiet origin master
  )
  rm -rf "$seed"

  # Clone for the test to operate in.
  git clone --quiet "$UPSTREAM" "$WORKDIR"
  cd "$WORKDIR"
  git config user.email "test@example.com"
  git config user.name "Test"

  # Initialise mock state.
  {
    printf 'default_branch=master\n'
    printf 'upstream=%s\n' "$UPSTREAM"
    printf 'workdir=%s\n' "$WORKDIR"
  } > "$MOCK_GH_STATE"
}

teardown() {
  if [[ -n "${ORIGINAL_PATH:-}" ]]; then
    export PATH="$ORIGINAL_PATH"
  fi
  if [[ -n "${TEST_TMPDIR:-}" && -d "$TEST_TMPDIR" ]]; then
    rm -rf "$TEST_TMPDIR"
  fi
}

# Set repo's default branch in mock state.
#   set_default_branch <name>
set_default_branch() {
  local name="$1"
  local tmp
  tmp="$(mktemp)"
  awk -v n="$name" 'BEGIN{seen=0} /^default_branch=/ {print "default_branch=" n; seen=1; next} {print} END{if(!seen) print "default_branch=" n}' "$MOCK_GH_STATE" > "$tmp"
  mv "$tmp" "$MOCK_GH_STATE"
}

# Create and push a stack branch with one commit on top of origin/<base>.
#   make_stack_branch <branch> <base_local_or_remote_ref> <commit_subject>
# Leaves you on whatever branch you started on.
make_stack_branch() {
  local branch="$1"
  local base_ref="$2"
  local subject="$3"

  local prev
  prev=$(git branch --show-current)

  git checkout --quiet -b "$branch" "$base_ref"
  printf '%s\n' "$subject" > "${branch//\//_}.txt"
  git add "${branch//\//_}.txt"
  git commit --quiet -m "$subject"
  # Use an explicit refspec so `git push -u` doesn't try to push to the
  # upstream of the inherited tracking branch (which is origin/master and
  # would silently advance master).
  git push --quiet origin "${branch}:refs/heads/${branch}"
  git branch --quiet --set-upstream-to="origin/${branch}" "$branch"

  if [[ -n "$prev" ]]; then
    git checkout --quiet "$prev"
  fi
}

# Register a PR in mock state.
#   register_pr <head_branch> <base_branch> <number> [draft:true|false]
register_pr() {
  local head="$1"
  local base="$2"
  local number="$3"
  local draft="${4:-false}"
  printf 'pr %s %s %s %s\n' "$head" "$base" "$number" "$draft" >> "$MOCK_GH_STATE"
}

# Assertions ----------------------------------------------------------------

# Assert that a literal call line appears in the mock call log.
#   assert_gh_called <expected line>
assert_gh_called() {
  local expected="$1"
  if ! grep -Fxq "$expected" "$MOCK_GH_CALLS"; then
    echo -e "${RED}FAIL${NC}: expected gh call '$expected' not found" >&2
    echo "  calls:" >&2
    sed 's/^/    /' "$MOCK_GH_CALLS" >&2
    return 1
  fi
}

# Assert that no gh call line matches the regex.
#   assert_gh_not_called <regex>
assert_gh_not_called() {
  local regex="$1"
  if grep -Eq "$regex" "$MOCK_GH_CALLS"; then
    echo -e "${RED}FAIL${NC}: expected no gh call matching '$regex'" >&2
    echo "  calls:" >&2
    sed 's/^/    /' "$MOCK_GH_CALLS" >&2
    return 1
  fi
}

# Assert PR draft status in mock state.
#   assert_pr_draft <branch> <true|false>
assert_pr_draft() {
  local branch="$1"
  local expected="$2"
  local line
  line="$(awk -v h="$branch" '$1 == "pr" && $2 == h { print; exit }' "$MOCK_GH_STATE")"
  if [[ -z "$line" ]]; then
    echo -e "${RED}FAIL${NC}: no PR found for branch '$branch'" >&2
    return 1
  fi
  # shellcheck disable=SC2086
  set -- $line
  local actual="$5"
  if [[ "$actual" != "$expected" ]]; then
    echo -e "${RED}FAIL${NC}: expected PR for '$branch' draft=$expected, got $actual" >&2
    return 1
  fi
}

# Assert that a PR no longer exists in state (e.g. after merge).
#   assert_pr_gone <branch>
assert_pr_gone() {
  local branch="$1"
  if awk -v h="$branch" '$1 == "pr" && $2 == h { found=1 } END { exit !found }' "$MOCK_GH_STATE"; then
    echo -e "${RED}FAIL${NC}: expected PR for '$branch' to be gone" >&2
    return 1
  fi
}

# Read the merged subject recorded by the mock.
mock_merged_subject() {
  awk -F= '/^merged_subject=/ { sub("^merged_subject=", ""); print; exit }' "$MOCK_GH_STATE"
}

# Read the merged body recorded by the mock (decoded).
mock_merged_body() {
  awk -F= '/^merged_body_b64=/ { sub("^merged_body_b64=", ""); print; exit }' "$MOCK_GH_STATE" | base64 -d
}
