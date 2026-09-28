#!/usr/bin/env bash
# Format in place, then lint --strict for what formatting cannot fix. The config is the
# .swift-format each file resolves by walking up. A brew swift-format wins over Xcode's.
set -eo pipefail
export HOOK=swift-format
. "$(dirname "$0")/lib.sh"
bin=$(command -v swift-format 2>/dev/null || xcrun --find swift-format 2>/dev/null || true)
[ -n "$bin" ] || fail "swift-format not found (install Xcode, or brew install swift-format). Skip once with SKIP=$HOOK."
"$bin" format --in-place "$@"
"$bin" lint --strict "$@"
