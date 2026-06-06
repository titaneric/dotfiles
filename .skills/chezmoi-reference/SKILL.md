---
name: chezmoi-reference
description: Chezmoi dotfiles reference skill. Use when editing chezmoi source state, writing templates, managing scripts, debugging chezmoi status/diff/apply behavior, handling machine-specific data, or deciding how to represent dotfiles with source-state attributes.
---

# Chezmoi Reference

Use this skill when working in a chezmoi-managed dotfiles repository.

Official reference: <https://www.chezmoi.io/reference/>

## Operating Rules

1. Inspect before editing: run `chezmoi status`, `chezmoi diff`, and read the relevant source file.
2. Prefer targeted applies: use `chezmoi apply --exclude scripts <target>` unless the task explicitly needs scripts.
3. Never commit local/private data: `.chezmoidata/*.toml` and secret-bearing templates are machine-local unless explicitly sanitized.
4. Remember `private_` is a target permission attribute, not repository secrecy.
5. Use `chezmoi cat <target>` to verify rendered target content and `chezmoi execute-template --file <source>` to debug a template source.
6. When adding scripts, make them idempotent and safe to rerun; prefer `run_once_` for bootstraps and `run_onchange_` for content-driven updates.
7. When debugging ignore behavior, use `chezmoi ignored`, `chezmoi managed --path-style relative`, and `.chezmoiignore.tmpl` render data.

## Common Workflow

```sh
chezmoi status --path-style relative
chezmoi diff <target>
chezmoi cat <target>
chezmoi apply --exclude scripts <target>
```

For CI or dry-run validation, use a fake destination:

```sh
chezmoi --source "$PWD" --destination "$RUNNER_TEMP/home" apply --exclude scripts --force
```

## Reference Files

| File | Use |
|---|---|
| [references/reference-map.md](references/reference-map.md) | Official reference index and where to look first. |
| [references/source-state.md](references/source-state.md) | Source-state attributes, naming, target mapping, and pitfalls. |
| [references/templates-data.md](references/templates-data.md) | Template variables, data files, functions, and validation. |
| [references/scripts-apply.md](references/scripts-apply.md) | Script naming, apply order, script state, and CI safety. |
| [references/commands.md](references/commands.md) | Command cheat sheet for editing/debugging. |
| [references/acceptance-criteria.md](references/acceptance-criteria.md) | Checks a chezmoi change should pass. |

## Decision Hints

| Need | Prefer |
|---|---|
| Public preference file | Plain source file or `.tmpl` if machine-specific. |
| Secret or company-specific value | Ignored `.chezmoidata/*.toml`, password manager function, or private internal repo. |
| Generated tool state | Usually unmanaged; install/regenerate with script if needed. |
| Installer/bootstrap command | `.chezmoiscripts/run_once_*` or `run_onchange_*`. |
| Different file by OS/profile | `.tmpl` plus `.chezmoi.os` or local data flags. |
| File permissions | `private_`, `readonly_`, `executable_` source attributes. |
