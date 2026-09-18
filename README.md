# .githooks

Shared git hooks for the `JakobMelchard` org and the `lilfeelz` repos. Private.

| Hook | Does |
|------|------|
| `pre-commit` | dispatches on staged file type: `gitleaks` (blocks), `gofmt -w`, `py_compile` + `ruff`, `bash -n`/`zsh -n` + `shellcheck`, `prettier --write` + `eslint`, `terraform fmt`. Every tool is optional and skipped when absent. |
| `pre-push` | cheap build gate: `go vet` + `go build` when `go.mod` exists, `terraform fmt -check` when `terraform/` exists. Tests belong in CI. |

Both run `.githooks/<hook>.local` last when it exists and is executable — that is the per-repo extension point, so the vendored copy stays refreshable.

## Install into a repo

```sh
hooks-install                                   # JakobMelchard/bin
gh api repos/JakobMelchard/.githooks/contents/install -q .content | base64 -d | bash
```

Vendors the two hooks into `.githooks/` with a `VENDORED` header and sets `core.hooksPath`. Commit the copies. Re-run to refresh.

In CI use the composite action: `uses: JakobMelchard/.github/actions/hooks@main`.

This repo is private, so installation goes through `gh api` (needs `gh auth`), never `raw.githubusercontent.com`. The public bootstrap for a fresh machine lives in a gist — see `JakobMelchard/bin`.

## Rules

- **bash 3.2**. macOS ships 3.2 and never updated it: no `mapfile`, no `readarray`, no `declare -A`. CI rejects them.
- `set -eo pipefail` in `pre-commit` (not `-u`: `$1` may be unset in hook context); `set -euo pipefail` in `pre-push` and `install`.
- Loops over file lists use here-strings, never pipes — a piped `while` runs in a subshell and `fail` cannot abort the commit.
- Bypass with `git commit --no-verify`.

## This repo's own hooks

`git config core.hooksPath .` — the hooks run on themselves.
