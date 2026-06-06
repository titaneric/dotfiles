# Templates And Data

References:

- Variables: <https://www.chezmoi.io/reference/templates/variables/>
- Functions: <https://www.chezmoi.io/reference/templates/functions/>
- Data files: <https://www.chezmoi.io/reference/special-files/chezmoidata-format/>
- Data directory: <https://www.chezmoi.io/reference/special-directories/chezmoidata/>

## Template Data Sources

Use these for machine-to-machine differences:

```text
.chezmoidata.toml
.chezmoidata/<name>.toml
[data] in chezmoi config
```

For public repos, keep real machine/company/secret data in ignored local `.chezmoidata/*.toml`, and track sanitized samples under `examples/`.

## Common Built-In Variables

| Variable | Use |
|---|---|
| `.chezmoi.os` | OS switch: `darwin`, `linux`, `windows`. |
| `.chezmoi.arch` | Architecture switch. |
| `.chezmoi.homeDir` | Absolute home dir, portable in templates. |
| `.chezmoi.sourceDir` | Source directory. |
| `.chezmoi.targetFile` | Absolute target path for current template. |
| `.chezmoi.hostname` | Hostname up to first dot. |
| `.chezmoi.username` | Current user. |

## Common Functions

| Function | Use |
|---|---|
| `dig` | Safe nested lookup with default. |
| `get` | Lookup map key. |
| `default` | Fallback for empty value. |
| `include` | Include raw source file content. |
| `includeTemplate` | Include and render a template from `.chezmoitemplates/`. |
| `toJson` / `toPrettyJson` | Render structured data safely. |
| `fromJson` / `fromJsonc` / `fromToml` / `fromYaml` | Parse data text. |
| `joinPath` | Portable path construction. |
| `lookPath` / `findExecutable` | Detect commands. |
| `stat` / `lstat` | Check filesystem state. |
| `quoteList` | Render shell-safe argument lists. |

## Good Patterns

Data-gated machine config:

```gotemplate
{{- if dig "feature" "enabled" false . -}}
enabled = true
{{- end -}}
```

Structured JSON without comma bugs:

```gotemplate
"server": {{ omit .server "name" | toPrettyJson | trimSuffix "\n" | replace "\n" "\n  " }}
```

OS-gated content:

```gotemplate
{{- if eq .chezmoi.os "darwin" -}}
macOS only
{{- end -}}
```

## Validation

```sh
chezmoi data
chezmoi execute-template --file path/to/source.tmpl
chezmoi cat ~/.target-file
chezmoi diff ~/.target-file
```
