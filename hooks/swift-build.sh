#!/usr/bin/env bash
# pre-push: the package at the repo root still builds. App targets are covered by the xcodegen hook
# and CI.
set -euo pipefail
export HOOK=swift-build
. "$(dirname "$0")/lib.sh"
[ -f Package.swift ] || exit 0
need swift "install Xcode"
swift build
