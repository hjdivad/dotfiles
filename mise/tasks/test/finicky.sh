#!/usr/bin/env bash
set -euo pipefail

#MISE description="run finicky config tests"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

tests=("$REPO_ROOT"/tests/finicky/*.test.mjs)

# Also cover the local rules when local-packages provides tests for them.
for t in "$REPO_ROOT"/local-packages/tests/finicky/*.test.mjs; do
  [[ -f "$t" ]] && tests+=("$t")
done

node --test "${tests[@]}"
