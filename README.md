# .githooks

Shared git hooks for the `JakobMelchard` org and the `lilfeelz` repos. Private.

| Hook | Does |
|------|------|
| `pre-commit` | dispatches on staged file type: `gitleaks` (blocks), `gofmt -w`, `py_compile` + `ruff`, `bash -n`/`zsh -n` + `shellcheck`, `prettier --write` + `eslint`, `terraform fmt`. Every tool is optional and skipped when absent. |
| `pre-push` | cheap build gate: `go vet` + `go build` when `go.mod` exists, `terraform fmt -check` when `terraform/` exists. Tests belong in CI. |
| `commit-msg` | rejects a subject that is not a conventional commit (`type(scope)!: subject`; merge, revert, fixup and squash subjects pass). The same regex gates PR titles in the org's reusable workflows, because a squash merge makes the PR title the commit subject that release-please reads. |

Both run `.githooks/<hook>.local` last when it exists and is executable — that is the per-repo extension point, so the vendored copy stays refreshable.

## Install into a repo

```sh
hooks-install                                   # JakobMelchard/bin
gh api -H 'Accept: application/vnd.github.raw+json' repos/JakobMelchard/.githooks/contents/install > /tmp/hooks-install && bash /tmp/hooks-install
```

Vendors the three hooks into `.githooks/` with a `VENDORED` header and sets `core.hooksPath`. Commit the copies. Re-run to refresh.

In CI use the composite action: `uses: JakobMelchard/.github/actions/hooks@main`.

This repo is private, so installation goes through `gh api` (needs `gh auth`), never `raw.githubusercontent.com`. The public entry point for a fresh machine is a gist that does the same:

```sh
curl -fsSL https://gist.githubusercontent.com/lilfeelz/c5e63e7e510aeffb7766a1b10b607321/raw/install-hooks.sh | bash
```

## Partially staged files

A file that is staged *and* has further unstaged edits is checked on its **index blob**, and formatters refuse to rewrite it (that would sweep the unstaged edits into the commit). The hook tells you to format and re-stage; `git stash -k` is the other way out. Renames (`R`) are included in the checked set.

## Rules

- **bash 3.2**. macOS ships 3.2 and never updated it: no `mapfile`, no `readarray`, no `declare -A`. CI rejects them.
- Every checker is optional and guarded by `have <tool>`; `sh` shebangs get `sh -n`, `bash` gets `bash -n` + shellcheck, `zsh` gets `zsh -n`. The interpreter is matched as a whole token (`fish` is not `sh`).
- `set -eo pipefail` in `pre-commit` and `commit-msg` (not `-u`: `$1` may be unset in hook context); `set -euo pipefail` in `pre-push` and `install`.
- Loops over file lists use here-strings, never pipes — a piped `while` runs in a subshell and `fail` cannot abort the commit.
- Bypass with `git commit --no-verify`.

## This repo's own hooks

`git config core.hooksPath "$(pwd)"` — the hooks run on themselves. (A relative `.` does not resolve for git here; use the absolute path.)
