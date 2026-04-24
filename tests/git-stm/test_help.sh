#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

test_help() {
  local output exit_code=0
  output=$("$GIT_STM" --help 2>&1) || exit_code=$?

  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "Usage: git stm"
  assert_contains "$output" "TRAILER"
}

run_test test_help "git stm --help prints usage"
