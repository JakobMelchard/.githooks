#!/usr/bin/env bash
# commit-msg: reject a subject that is not a conventional commit. PRs are squash-merged with the
# PR title as the subject and release-please parses it, so the same regex gates PR titles in
# JakobMelchard/.github (shell.yml, node.yml, ...).
set -eo pipefail
export HOOK=conventional-commit
. "$(dirname "$0")/lib.sh"

msg=${1:?commit message file}
# first line that is neither empty nor a comment (|| true: grep exits 1 on no match under pipefail)
subject=$(grep -v '^#' "$msg" | sed -n '/./{p;q;}' || true)
[ -n "$subject" ] || exit 0 # git aborts an empty message on its own

case "$subject" in
  "Merge "* | "Revert "* | "fixup! "* | "squash! "* | "amend! "*) exit 0 ;;
esac

types='feat|fix|chore|docs|refactor|test|ci|build|perf|style|revert'
if ! printf '%s\n' "$subject" | grep -Eq "^($types)(\([A-Za-z0-9._/-]+\))?!?: .+"; then
  fail "\"$subject\" is not a conventional commit: <type>(<scope>)!: <subject>, type one of $types"
fi
[ "${#subject}" -le 100 ] || fail "subject is ${#subject} characters; keep it at 100 or under"
