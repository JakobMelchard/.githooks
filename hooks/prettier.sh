#!/usr/bin/env bash
# Format with the repo's own prettier, so the version and config come from package.json
# (@jakobmelchard/config). prek fails the commit when files change; re-stage them.
set -eo pipefail
export HOOK=prettier
. "$(dirname "$0")/lib.sh"
npx --no-install prettier --version >/dev/null 2>&1 || fail "prettier not installed in this repo (npm ci). Skip once with SKIP=$HOOK."
npx --no-install prettier --write --ignore-unknown --log-level warn "$@"
