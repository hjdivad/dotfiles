#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_invalid_branch_pattern() {
  git checkout --quiet -b some-feature

  local output exit_code=0
  output=$("$GIT_STM" 2>&1) || exit_code=$?

  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "does not match pattern"
}

run_test test_invalid_branch_pattern "errors on non {NAMESPACE}/{TASK}/{SUFFIX} branch"
