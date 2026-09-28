#!/usr/bin/env bash
# Lint with the repo's own eslint and config.
set -eo pipefail
export HOOK=eslint
. "$(dirname "$0")/lib.sh"
npx --no-install eslint --version >/dev/null 2>&1 || fail "eslint not installed in this repo (npm ci). Skip once with SKIP=$HOOK."
npx --no-install eslint --quiet "$@"
