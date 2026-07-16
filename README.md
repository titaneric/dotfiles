# dotfiles

These dotfiles are managed by [chezmoi](https://www.chezmoi.io/).

This repository is intended to be safe for a public GitHub repo. Machine-local data, company metadata, internal MCP configuration, and secrets must stay outside the tracked public source tree.

## Safety Rules

Never commit real values for any of these:

- API tokens, OAuth tokens, PATs, service-account tokens, or passwords.
- Company hostnames, internal registry URLs, internal MCP URLs, internal model gateway URLs, or private project paths unless they are approved for public release.
- OCR LLM endpoints, OCR tokens, and OCR model names from `OCR_*` environment variables.
- `~/.ssh` private keys, `~/.gnupg` key material, `~/.kube/config`, Docker auth files, cloud credential databases, or generated login/session state.
- Local chezmoi data under `.chezmoidata/*.toml` when it contains machine, company, or secret values.
- Internal MCP endpoints, model gateways, or private provider details in local data files such as `.chezmoidata/opencode.toml`.

Before committing, check ignored private files are really ignored:

```sh
git check-ignore -v \
  .chezmoidata/git.toml \
  .chezmoidata/fish.toml \
  .chezmoidata/homebrew.toml \
  .chezmoidata/opencode.toml \
  .chezmoidata/vscode.toml
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

Create local/private data files before the first full apply if this machine needs company or machine-specific configuration. Start from the sanitized samples and edit only the ignored local copies:

```sh
mkdir -p .chezmoidata
cp examples/chezmoidata/git.toml .chezmoidata/git.toml
cp examples/chezmoidata/fish.toml .chezmoidata/fish.toml
cp examples/chezmoidata/homebrew.toml .chezmoidata/homebrew.toml
cp examples/chezmoidata/opencode.toml .chezmoidata/opencode.toml
cp examples/chezmoidata/vscode.toml .chezmoidata/vscode.toml
$EDITOR .chezmoidata/git.toml
$EDITOR .chezmoidata/fish.toml
$EDITOR .chezmoidata/homebrew.toml
$EDITOR .chezmoidata/opencode.toml
$EDITOR .chezmoidata/vscode.toml
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
| `.chezmoidata/homebrew.toml` | Company-specific Homebrew taps, formulae, casks, and App Store apps. |
| `.chezmoidata/opencode.toml` | OpenCode machine profile, company provider settings, and structured MCP servers. |
| `.chezmoidata/vscode.toml` | VS Code Insiders company endpoints, currently GitLens remote host metadata. |

Sample files live under `examples/`. They are tracked, sanitized, and ignored by chezmoi target management via `.chezmoiignore`.

| Sample file | Local/private destination |
|---|---|
| `examples/chezmoidata/git.toml` | `.chezmoidata/git.toml` |
| `examples/chezmoidata/fish.toml` | `.chezmoidata/fish.toml` |
| `examples/chezmoidata/homebrew.toml` | `.chezmoidata/homebrew.toml` |
| `examples/chezmoidata/opencode.toml` | `.chezmoidata/opencode.toml` |
| `examples/chezmoidata/vscode.toml` | `.chezmoidata/vscode.toml` |

To bootstrap editable local copies from the samples:

```sh
mkdir -p .chezmoidata
cp examples/chezmoidata/git.toml .chezmoidata/git.toml
cp examples/chezmoidata/fish.toml .chezmoidata/fish.toml
cp examples/chezmoidata/homebrew.toml .chezmoidata/homebrew.toml
cp examples/chezmoidata/opencode.toml .chezmoidata/opencode.toml
cp examples/chezmoidata/vscode.toml .chezmoidata/vscode.toml
```

Then edit only the ignored local copies:

```sh
$EDITOR .chezmoidata/git.toml
$EDITOR .chezmoidata/fish.toml
$EDITOR .chezmoidata/homebrew.toml
$EDITOR .chezmoidata/opencode.toml
$EDITOR .chezmoidata/vscode.toml
```

Do not put real secrets, real company hostnames, private project paths, or personal identifiers into `examples/`. If the sample shape changes, update both the sample file and the consuming template together.

Prefer not to store long-lived secrets directly in `.chezmoidata/fish.toml` if a password manager or company secret manager can supply them. If you do store them locally, keep the file ignored and never paste its contents into public issues, logs, commits, or documentation.

Open Code Review (`ocr`) is installed by `.chezmoiscripts/run_after_25-install-npm-clis.sh.tmpl`. Its LLM configuration is intentionally env-backed through ignored `.chezmoidata/fish.toml` entries such as `OCR_LLM_TOKEN`, `OCR_LLM_URL`, `OCR_USE_ANTHROPIC`, and `OCR_LLM_MODEL`; do not commit real OCR endpoints, tokens, or model names.

Set `isCompanyComputer = false` or omit `.chezmoidata/opencode.toml` on personal machines. When `isCompanyComputer` is false or missing, custom providers, enabled-provider allowlists, and company MCP entries are not rendered.

Provider and model settings are configured as structured TOML arrays. The template renders `opencode.enabledProviders` to OpenCode's `enabled_providers` array, then converts `[[opencode.providers]]` and nested `[[opencode.providers.models]]` arrays into the object shape OpenCode expects.

Example provider data:

```toml
[opencode]
model = "example-gateway/example-model"
enabledProviders = ["example-gateway", "openai"]

[[opencode.providers]]
id = "example-gateway"
name = "Example LLM Gateway"
npm = "@ai-sdk/openai-compatible"

[opencode.providers.options]
baseURL = "https://llm-gateway.example.internal/openai/v1"
apiKey = "{env:COMPANY_LLM_TOKEN}"

[opencode.providers.options.headers]
x-company-provider = "example-gateway"

[[opencode.providers.models]]
id = "example-model"
name = "Example Model"

[opencode.providers.models.limit]
context = 131072
output = 65536
```

Keep real gateway URLs, header names, token environment variable names, and other provider options in ignored `.chezmoidata/opencode.toml`, not in the public template.

Internal MCP servers are included only on company machines and are configured as TOML data under `.chezmoidata/opencode.toml`. Do not edit raw JSON fragments or manage commas manually; `dot_config/opencode/opencode.json.tmpl` renders the final JSON object.

Example MCP server data:

```toml
[opencode.mcp]
enabled = true

[[opencode.mcp.servers]]
name = "internal-docs"
type = "local"
command = [
  "npx",
  "@example/internal-mcp-connector@latest",
  "https://mcp.example.internal/docs",
]
enabled = false

[opencode.mcp.servers.environment]
NPM_CONFIG_REGISTRY = "https://npm.example.internal"
```

Keep real MCP server names, internal URLs, registry URLs, and tokens in ignored `.chezmoidata/opencode.toml`, not in the public repo.

### VS Code Insiders

VS Code Insiders user settings are managed on macOS only:

```text
private_Library/private_Application Support/private_Code - Insiders/User/settings.json.tmpl
```

The template renders to:

```text
~/Library/Application Support/Code - Insiders/User/settings.json
```

Company-specific endpoints are read from ignored local data:

```toml
[vscode.insiders]

[[vscode.insiders.gitlensRemotes]]
domain = "git.example.internal"
type = "GitHub"
```

Keep real GitLens remote domains and other internal VS Code endpoints in `.chezmoidata/vscode.toml`, not in the public template. Non-macOS machines ignore the `private_Library/` source tree through `.chezmoiignore.tmpl`.

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
private_dot_gitconfig-company.tmpl
```

It reads `.git.company` data from `.chezmoidata/git.toml`. The target is private (`0600`) because it can include company-only credential rewrites.

The top-level Git config includes `.gitconfig-company` only for configured work directories. Keep company identity, internal Git host data, and PAT-backed URL rewrites out of tracked public files.

Optional PAT-backed Git URL rewrites belong in ignored local data only:

```toml
[git.company.oauth]
enabled = true
base = "https://oauth2:<token>@git.example.internal"
insteadOf = [
  "https://git.example.internal",
]
```

Prefer Git credential helpers, SSH keys, or a company-approved secret manager over long-lived PATs in files. If a PAT is stored locally, keep it only in ignored `.chezmoidata/git.toml`, rotate it regularly, and never copy it into tracked files.

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

When the flag is not set, custom providers, enabled-provider allowlists, and company MCP entries are omitted.

Agent skills are managed under:

```text
dot_agents/skills -> ~/.agents/skills
```

The Open Code Review skill is tracked at `dot_agents/skills/open-code-review`, with its public lock entry in `dot_agents/dot_skill-lock.json.tmpl`.

Public skill lock entries live in `dot_agents/dot_skill-lock.json.tmpl`. Private skill repositories are added with structured TOML in ignored `.chezmoidata/agents.toml`:

```toml
[[agents.skills]]
name = "internal-skill"
source = "https://git.example.internal/team/skills.git"
sourceType = "git"
sourceUrl = "https://git.example.internal/team/skills.git"
skillPath = "internal-skill/SKILL.md"
skillFolderHash = "example-hash"
installedAt = "2026-01-01T00:00:00.000Z"
updatedAt = "2026-01-01T00:00:00.000Z"
```

After the related CLIs are installed, `.chezmoiscripts/run_after_35-install-agent-skills.sh.tmpl` refreshes tool-provided skills with their own subcommands: `but skill install`, `browser-harness skill`, `gcx agent skills install`, and `playwright-cli install --skills=agents`.

After the global skill lock is rendered, `.chezmoiscripts/run_after_40-install-locked-agent-skills.sh.tmpl` runs:

```sh
cd ~/.agents
cp .skill-lock.json skills-lock.json
npx skills experimental_install
```

### Homebrew

Homebrew bootstrap is managed by chezmoi scripts:

| Script | Behavior |
|---|---|
| `.chezmoiscripts/run_once_before_00-install-homebrew.sh.tmpl` | Installs Homebrew on macOS if `brew` is missing. |
| `.chezmoiscripts/run_onchange_after_05-install-homebrew-packages.sh.tmpl` | Runs `brew bundle install` after `Brewfile` is applied when `Brewfile.tmpl`, Homebrew category data, company Homebrew data, or the script changes. |
| `.chezmoiscripts/run_onchange_after_06-install-worktrunk-opencode-plugin.sh.tmpl` | Installs Worktrunk's OpenCode plugin after Homebrew packages are available. |
| `.chezmoiscripts/run_onchange_after_07-install-rtk-opencode-hook.sh.tmpl` | Installs RTK's OpenCode hook after Homebrew packages are available. |
| `.chezmoiscripts/run_after_35-install-agent-skills.sh.tmpl` | Refreshes agent skills from installed CLIs when available. |
| `.chezmoiscripts/run_after_40-install-locked-agent-skills.sh.tmpl` | Installs skills from the rendered global `.agents/.skill-lock.json`. |

The public base Brewfile is:

```text
Brewfile.tmpl -> ~/Brewfile
```

Base packages are grouped into category blocks. Categories default to enabled, preserving the full public package set unless local data opts out.

Toggle categories in `.chezmoidata/homebrew.toml`:

```toml
[homebrew.categories]
common = true
dev = true
devops = true
ai = true
personal = true
```

Current category intent:

| Category | Purpose |
|---|---|
| `common` | Shell, terminal, Git UX, and everyday CLI tools used by the shared dotfiles. |
| `dev` | Language/toolchain/build/API development utilities. |
| `devops` | Kubernetes, cloud, infrastructure, and observability-oriented tooling. |
| `ai` | AI coding tools and related agent workflow tools. |
| `personal` | Personal publishing/writing tools, including `typst` and `zola`. |

When adding a new public package, put it in one category block in `Brewfile.tmpl`. If a package is company-only, keep it in `.chezmoidata/homebrew.toml` so it renders to `~/Brewfile-company` instead.

OpenCode is installed from the OpenCode tap recommended by the official docs:

```ruby
brew "anomalyco/tap/opencode"
```

Worktrunk is installed from Homebrew:

```ruby
brew "worktrunk"
```

After Homebrew installs `wt` and `opencode`, the Worktrunk plugin script runs:

```sh
wt config plugins opencode install --yes
```

The plugin writes tool-generated state to `~/.config/opencode/plugins/worktrunk.ts`. That file is intentionally not managed by chezmoi; Worktrunk owns it.

RTK is installed from Homebrew as part of the `ai` category:

```ruby
brew "rtk"
```

The RTK OpenCode hook is installed by:

```text
.chezmoiscripts/run_onchange_after_07-install-rtk-opencode-hook.sh.tmpl
```

The script follows RTK's OpenCode setup command:

```sh
rtk init -g --opencode
```

Before running the hook setup, the script verifies `rtk gain` works so a different binary named `rtk` is not accidentally configured. The hook writes tool-generated state to `~/.config/opencode/plugins/rtk.ts`. That file is intentionally not managed by chezmoi; RTK owns it.

Company Homebrew entries are generated from ignored local data into:

```text
~/Brewfile-company
```

`~/Brewfile-company` is managed only when `.chezmoidata/homebrew.toml` sets `homebrew.company.enabled = true`. The package script concatenates `~/Brewfile` and `~/Brewfile-company` into a temporary merged Brewfile before running install and cleanup, so company packages are not removed by cleanup.

The package script currently runs cleanup against the effective bundle file. On machines without `~/Brewfile-company`, that is `~/Brewfile`. On company machines, it is a temporary merged file containing both `~/Brewfile` and `~/Brewfile-company`.

The cleanup command is:

```sh
brew bundle cleanup --force --file="$bundle_brewfile"
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
