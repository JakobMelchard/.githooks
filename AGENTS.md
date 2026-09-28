# .githooks

A prek / pre-commit hook repository. `.pre-commit-hooks.yaml` declares the hooks; `hooks/*.sh`
implement them. No build.

- bash 3.2 only. CI fails on `mapfile`, `readarray`, `declare -A`.
- A hook wraps a tool the consumer already needs. Missing tool: `need <tool> <hint>` fails, never
  skips silently.
- Prefer an upstream hook repo over wrapping a tool here (gitleaks, ruff, shellcheck already are).
- Formatters rewrite and exit non-zero; prek reports the modified files.
- Check: `test/run`, `prek validate-manifest .pre-commit-hooks.yaml`, `prek run --all-files`.
- Consumers pin a tag. Changing a hook id or its stage is a breaking change: bump the major.
- Root `pre-commit` `pre-push` `commit-msg` `install` are legacy (vendored consumers). Do not extend.
