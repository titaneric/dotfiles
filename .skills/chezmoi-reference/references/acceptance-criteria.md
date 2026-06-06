# Acceptance Criteria: chezmoi-reference

Use these checks before considering a chezmoi change complete.

## 1. Correct Source Mapping

- Dotfiles use `dot_` unless intentionally literal.
- Permissions use source attributes (`private_`, `executable_`, `readonly_`) instead of ad-hoc chmod commands where possible.
- Generated/tool-owned files are not managed unless there is a clear reason.
- Company/private values are not hardcoded in public templates.

## 2. Template Safety

- `chezmoi execute-template --file <source>` succeeds for edited templates.
- `chezmoi cat <target>` renders expected content.
- Missing local/private data renders safe defaults or intentionally omits private blocks.
- Structured output uses `toJson`, `toPrettyJson`, or data-driven rendering instead of hand-managed comma fragments.

## 3. Apply Safety

- `chezmoi diff <target>` is reviewed before apply.
- Targeted applies use `--exclude scripts` unless script execution is intended.
- Full applies are avoided while unrelated scripts are pending unless the user requested it.

## 4. Script Safety

- Scripts use `set -euo pipefail`.
- Scripts are idempotent or use `run_once_`/`run_onchange_` appropriately.
- Scripts skip gracefully when optional commands are missing.
- Script render output passes `bash -n` or the relevant interpreter syntax check.

## 5. Public Repo Safety

- `git check-ignore -v .chezmoidata/<file>.toml` confirms private local data is ignored.
- Public changed files pass a sensitive-pattern scan.
- Real hostnames, tokens, user IDs, and internal URLs are absent from public samples and templates.
