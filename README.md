# dotfiles

These dotfiles are managed by [chezmoi](https://www.chezmoi.io/).

This repository is intended to be safe for a public GitHub repo. Machine-local data, company metadata, internal MCP configuration, and secrets must stay outside the tracked public source tree.

## Safety Rules

Never commit real values for any of these:

- API tokens, OAuth tokens, PATs, service-account tokens, or passwords.
- Company hostnames, internal registry URLs, internal MCP URLs, internal model gateway URLs, or private project paths unless they are approved for public release.
- `~/.ssh` private keys, `~/.gnupg` key material, `~/.kube/config`, Docker auth files, cloud credential databases, or generated login/session state.
- Local chezmoi data under `.chezmoidata/*.toml` when it contains machine, company, or secret values.
- Internal template fragments such as `.chezmoitemplates/opencode/company-mcp.json.tmpl`.

Before committing, check ignored private files are really ignored:

```sh
git check-ignore -v \
  .chezmoidata/git.toml \
  .chezmoidata/fish.toml \
  .chezmoidata/opencode.toml \
  .chezmoitemplates/opencode/company-mcp.json.tmpl
```

Before pushing to the public repo, run a secret scan if available:

```sh
gitleaks detect --source .
```

## Bootstrap

Install or initialize chezmoi first, then inspect before applying:

```sh
chezmoi init git@github.com:titaneric/dotfiles.git
chezmoi cd
chezmoi status
chezmoi diff
```

Create local/private data files before the first full apply if this machine needs company or machine-specific configuration:

```sh
mkdir -p .chezmoidata .chezmoitemplates/opencode
$EDITOR .chezmoidata/git.toml
$EDITOR .chezmoidata/fish.toml
$EDITOR .chezmoidata/opencode.toml
$EDITOR .chezmoitemplates/opencode/company-mcp.json.tmpl
```

Then apply:

```sh
chezmoi apply
```

Use targeted apply when you only want one area and do not want scripts to run:

```sh
chezmoi apply ~/.config/fish/config.fish ~/.config/fish/conf.d/local.fish
chezmoi apply ~/.config/opencode/opencode.json
chezmoi apply ~/.gitconfig-company
```

## Local Data

The repo uses chezmoi data for machine-to-machine differences. Local data files are ignored by git and should contain only values for the current machine.

Current ignored local data files:

| File | Purpose |
|---|---|
| `.chezmoidata/git.toml` | Work Git identity and URL rewrite data for `.gitconfig-company`. |
| `.chezmoidata/fish.toml` | Private shell paths, environment variables, local source files, and aliases. |
| `.chezmoidata/opencode.toml` | OpenCode machine profile and company provider settings. |
| `.chezmoitemplates/opencode/company-mcp.json.tmpl` | Internal OpenCode MCP entries, kept outside the public repo. |

All examples below use placeholders. Replace them only in ignored local files, never in tracked public files.

### `.chezmoidata/git.toml`

```toml
[git.company.user]
name = "<work-git-name>"
email = "<work-email@example.com>"
signingKey = "<gpg-signing-key-id>"

[git.company.url]
base = "ssh://git@git.example.internal:22/"
insteadOf = [
  "git@git.example.internal:",
  "https://git.example.internal/",
]
```

### `.chezmoidata/fish.toml`

```toml
[fish.private]
fishUserPaths = [
  "/opt/homebrew/opt/example-tool/bin",
  "$HOME/.local/bin",
  "$HOME/path/to/private/project/.venv/bin",
]
fishAddPaths = [
  "$HOME/.private-tool/bin",
]
sourceFiles = [
  "$HOME/private-sdk/path.fish.inc",
]

[[fish.private.env]]
name = "GOPRIVATE"
value = "git.example.internal"

[[fish.private.env]]
name = "OTEL_RESOURCE_ATTRIBUTES"
value = "user_id=<work-user-id>"

[[fish.private.env]]
name = "OPENCODE_RESOURCE_ATTRIBUTES"
value = "user_id=<work-user-id>"

[[fish.private.env]]
name = "COMPANY_LLM_TOKEN"
value = "<secret-token-or-env-reference>"

[[fish.private.env]]
name = "COMPANY_GIT_TOKEN"
value = "<secret-token-or-env-reference>"

[[fish.private.aliases]]
name = "ws"
value = "<private-workspace-command>"
```

Prefer not to store long-lived secrets directly in `fish.toml` if a password manager or company secret manager can supply them. If you do store them locally, keep the file ignored and never paste its contents into public issues, logs, commits, or documentation.

### `.chezmoidata/opencode.toml`

```toml
[opencode]
isCompanyComputer = true
model = "<company-model-name>"

[opencode.companyOpenAI]
baseURL = "https://llm-gateway.example.internal/openai/v1"
apiKey = "x"
headerName = "x-company-token-header"
tokenEnv = "COMPANY_LLM_TOKEN"
```

Set `isCompanyComputer = false` or omit `.chezmoidata/opencode.toml` on personal machines. When `isCompanyComputer` is false or missing, the custom OpenAI provider and company MCP entries are not rendered.

### `.chezmoitemplates/opencode/company-mcp.json.tmpl`

This file is included only on company machines. It must be JSONC-compatible with the surrounding `mcp` object in `dot_config/opencode/opencode.json.tmpl`.

Use an empty file if the machine is a company computer but has no internal MCP entries:

```jsonc
```

Use a leading comma when adding entries because the public template already renders the generic `sequential-thinking` entry first:

```jsonc
,
    "internal-docs": {
      "type": "local",
      "environment": {
        "NPM_CONFIG_REGISTRY": "https://npm.example.internal"
      },
      "command": [
        "npx",
        "@example/internal-mcp-connector@latest",
        "https://mcp.example.internal/docs"
      ],
      "enabled": false
    }
```

Keep this file in a company-internal repo or generate it locally. Do not commit it to the public repo.

## Managed Areas

### Fish

Public fish config lives in:

```text
dot_config/private_fish/config.fish
```

It keeps generic shell behavior and `GPG_TTY` only.

Private fish config is generated from `.chezmoidata/fish.toml` into:

```text
~/.config/fish/conf.d/local.fish
```

That target is private (`0600`) because the source uses chezmoi's `private_` attribute.

### Git

Company Git config is templated by:

```text
dot_gitconfig-company.tmpl
```

It reads `.git.company` data from `.chezmoidata/git.toml`.

The top-level Git config includes `.gitconfig-company` only for configured work directories. Keep company identity and internal Git host data out of tracked public files.

### OpenCode

OpenCode config is templated by:

```text
dot_config/opencode/opencode.json.tmpl
```

Company provider rendering is controlled by:

```toml
[opencode]
isCompanyComputer = true
```

When the flag is not set, the custom provider and company MCP entries are omitted.

### Homebrew

Homebrew bootstrap is managed by chezmoi scripts:

| Script | Behavior |
|---|---|
| `.chezmoiscripts/run_once_before_00-install-homebrew.sh.tmpl` | Installs Homebrew on macOS if `brew` is missing. |
| `.chezmoiscripts/run_onchange_after_05-install-homebrew-packages.sh.tmpl` | Runs `brew bundle install` after `Brewfile` is applied when `Brewfile` or the script changes. |

The package script currently runs:

```sh
brew bundle cleanup --force --file="$HOME/Brewfile"
```

That can remove Homebrew packages not listed in `Brewfile`. Review `Brewfile` before a full apply.

### Krew

Krew is installed from the official upstream installer, not from Homebrew:

| Script | Behavior |
|---|---|
| `.chezmoiscripts/run_once_after_10-install-krew.sh.tmpl` | Installs official krew into `${KREW_ROOT:-$HOME/.krew}`. |
| `.chezmoiscripts/run_onchange_after_20-install-krew-plugins.sh.tmpl` | Installs missing plugins from `~/.krew-plugin.txt`. |

The managed plugin list is:

```text
dot_krew-plugin.txt
```

Use krew plugin names, not binary names. For example, the `kubectl-ai` binary is installed by the krew plugin named `ai`.

## Common Commands

Preview changes:

```sh
chezmoi status --path-style relative
chezmoi diff
```

Render a managed file without applying it:

```sh
chezmoi cat ~/.config/opencode/opencode.json
chezmoi cat ~/.gitconfig-company
```

Render a template directly:

```sh
chezmoi execute-template --file dot_config/private_fish/conf.d/private_local.fish.tmpl
```

Apply one file:

```sh
chezmoi apply ~/.config/fish/config.fish
```

Apply all files and scripts:

```sh
chezmoi apply
```

Clear `run_once_` script state when you intentionally need to rerun bootstrap scripts:

```sh
chezmoi state delete-bucket --bucket=scriptState
```

Clear `run_onchange_` script state when you intentionally need to rerun onchange scripts:

```sh
chezmoi state delete-bucket --bucket=entryState
```

## Remaining Manual Setup

Some setup should remain manual or company-managed:

- Generate or import GPG keys.
- Authenticate `gh`, cloud CLIs, Docker registries, and Kubernetes clusters.
- Place `~/.kube/config` locally and set `chmod 600 ~/.kube/config`.
- Initialize and start Podman machines when needed.
- Install or authenticate password managers before using secret-backed templates.
- Keep company MCP fragments and company bootstrap logic in a private/internal repo.
