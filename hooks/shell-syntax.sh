#!/usr/bin/env bash
# Parse-check shell scripts with the interpreter their shebang names. shellcheck is a separate
# hook (shellcheck-py), and it does not cover zsh, so zsh -n is the only check zsh gets.
set -eo pipefail
export HOOK=shell-syntax
. "$(dirname "$0")/lib.sh"

rc=0
for f in "$@"; do
  i=$(head -1 "$f" | sed -nE 's#^\#![^ ]*/(env +)?(bash|sh|zsh)([[:space:]].*)?$#\2#p')
  case "${i:-${f##*.}}" in
    zsh) need zsh "brew install zsh"; zsh -n "$f" || rc=1 ;;
    sh) sh -n "$f" || rc=1 ;;
    *) bash -n "$f" || rc=1 ;;
  esac
done
exit $rc
