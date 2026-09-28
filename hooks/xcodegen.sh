#!/usr/bin/env bash
# pre-push: every tracked project.yml still generates. A spec that no longer generates is broken
# for everyone who clones. Finds specs anywhere (apps keep them in ios/).
set -euo pipefail
export HOOK=xcodegen
. "$(dirname "$0")/lib.sh"
specs=$(git ls-files -- 'project.yml' '*/project.yml')
[ -n "$specs" ] || exit 0
need xcodegen "brew install xcodegen"
top=$(pwd)
while IFS= read -r s; do
  cd "$top/$(dirname "$s")"
  xcodegen generate --quiet || fail "xcodegen generate failed for $s"
done <<<"$specs"
