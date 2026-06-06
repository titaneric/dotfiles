# Scripts And Apply Order

References:

- Application order: <https://www.chezmoi.io/reference/application-order/>
- Script directory: <https://www.chezmoi.io/reference/special-directories/chezmoiscripts/>
- Apply command: <https://www.chezmoi.io/reference/commands/apply/>

## Application Order

Chezmoi applies changes deterministically:

1. Read source state.
2. Read destination state.
3. Compute target state.
4. Run `run_before_` scripts alphabetically.
5. Update target entries alphabetically by target name; directories before contained files.
6. Run `run_after_` scripts alphabetically.

Target names are considered after stripping attributes.

## Script Types

| Prefix | Behavior |
|---|---|
| `run_` | Run every apply. Use sparingly. |
| `run_once_` | Run once per rendered contents after success. Good for bootstraps. |
| `run_onchange_` | Run when rendered contents or name changes. Good for package installs. |
| `before_` | Run before target updates. |
| `after_` | Run after target updates. |

## Safe Script Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

if ! command -v tool >/dev/null 2>&1; then
  echo "skip: tool is not installed"
  exit 0
fi

tool install-or-update
```

## CI And Targeted Applies

Avoid running install scripts in render tests unless explicitly smoke-testing them:

```sh
chezmoi apply --exclude scripts --force
```

Use fake homes in CI:

```sh
chezmoi --source "$PWD" --destination "$RUNNER_TEMP/home" apply --exclude scripts --force
```

For script syntax checks:

```sh
for script in .chezmoiscripts/*.sh.tmpl; do
  chezmoi execute-template --file "$script" > /tmp/rendered.sh
  [ ! -s /tmp/rendered.sh ] || bash -n /tmp/rendered.sh
done
```

## State Reset

Use carefully:

```sh
chezmoi state delete-bucket --bucket=scriptState
chezmoi state delete-bucket --bucket=entryState
```

Do not reset script state in normal automation unless the user explicitly wants scripts rerun.
