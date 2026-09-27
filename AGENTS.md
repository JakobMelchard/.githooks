# .githooks

Four bash scripts, no build. `pre-commit`, `pre-push`, `commit-msg`, `install`.

- bash 3.2 only. CI fails on `mapfile`, `readarray`, `declare -A`.
- Every tool call is guarded by `have <tool>`; a missing tool skips, never fails.
- Consumers hold vendored copies with a `VENDORED` header. Never edit a copy; change here, then `hooks-install` in the consumer.
- Repo-specific logic goes in the consumer's `.githooks/<hook>.local`, never here.
- Check: `bash -n`, `shellcheck --severity=warning`, then commit — the hooks run on this repo (`core.hooksPath .`).
