# .githooks

Shared git hooks for the `JakobMelchard` org and the `lilfeelz` repos, as a
[prek](https://github.com/j178/prek) / pre-commit hook repository. Public, so any repo, CI job or
machine can fetch it without a token.

## Use in a repo

`.pre-commit-config.yaml` at the repo root, pinning this repo by tag. Pick the hooks the repo needs:

```yaml
default_install_hook_types: [pre-commit, commit-msg, pre-push]
default_stages: [pre-commit] # upstream hooks (gitleaks) would otherwise rerun at every stage
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks: [{ id: gitleaks }]
  - repo: https://github.com/JakobMelchard/.githooks
    rev: v1.0.0
    hooks:
      - id: conventional-commit
      - id: swift-format
      - id: swift-build
  - repo: local # repo-specific checks (replaces .githooks/<hook>.local)
    hooks: []
```

```sh
brew install prek          # once per machine
prek install               # once per clone; writes .git/hooks shims
prek run --all-files       # what CI runs
```

Renovate bumps every `rev` (the org preset enables its pre-commit manager). CI runs the same config
through `JakobMelchard/.github/.github/workflows/hooks.yml`, which is the gate: local hooks can be
skipped, CI cannot.

## Hooks

| id | stage | does |
|----|-------|------|
| `conventional-commit` | commit-msg | `type(scope)!: subject`, max 100 chars; merge, revert, fixup, squash and amend pass. The same regex gates PR titles in the org workflows. |
| `shell-syntax` | pre-commit | `bash -n` / `sh -n` / `zsh -n` by shebang. Pair with `shellcheck-py` (`exclude_types: [zsh]`). |
| `gofmt` | pre-commit | rewrites, then fails so you re-stage |
| `go-build` | pre-push | `go vet ./...` and `go build ./...` when `go.mod` is at the root |
| `swift-format` | pre-commit | `format --in-place`, then `lint --strict`; a brew `swift-format` wins over Xcode's |
| `swift-build` | pre-push | `swift build` when `Package.swift` is at the root |
| `xcodegen` | pre-push | every tracked `project.yml` still generates |
| `prettier` | pre-commit | the repo's own prettier (`npx --no-install`), so version and config come from `package.json` |
| `eslint` | pre-commit | the repo's own eslint |
| `tofu-fmt` | pre-commit | `tofu fmt`, else `terraform fmt` |

Use upstream hook repos for the rest: `gitleaks/gitleaks`, `astral-sh/ruff-pre-commit`
(`ruff-check`), `shellcheck-py/shellcheck-py`.

Every hook here wraps a toolchain the repo needs anyway, so it runs against the installed tool. A
missing tool fails with an install hint rather than passing silently; `SKIP=<id> git commit` skips
one hook once, and CI callers pass `skip:` for hooks their runner cannot run (swift on Linux).

prek stashes unstaged edits before the hooks run, so partially staged files are checked as staged.
Formatters rewrite files and the commit fails; review and re-stage.

## Develop

```sh
prek install     # this repo runs its hooks from the working tree (repo: local)
test/run         # hook scripts against good and bad inputs
```

Release: merge to main, tag `vX.Y.Z` on main. Consumers move when Renovate opens the bump.

## Legacy (until every repo has migrated)

The root `pre-commit`, `pre-push`, `commit-msg` and `install` are the old vendored hooks, still
fetched by `hooks-install` and `fleet-sync` for repos that carry a `.githooks/` copy. Do not extend
them; they are removed once the last consumer moves to prek.
