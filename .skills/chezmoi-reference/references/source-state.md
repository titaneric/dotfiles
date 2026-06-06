# Source State Attributes

Reference: <https://www.chezmoi.io/reference/source-state-attributes/>

Chezmoi represents targets through names in the source state. Attributes are encoded with source filename prefixes and suffixes.

## High-Use Attributes

| Attribute | Meaning | Example source | Target effect |
|---|---|---|---|
| `dot_` | Leading dot in target | `dot_gitconfig` | `~/.gitconfig` |
| `private_` | Remove group/world perms | `private_dot_ssh/config` | `~/.ssh/config` with private perms |
| `executable_` | Add executable bit | `executable_dot_local/bin/tool` | executable target file |
| `readonly_` | Remove write perms | `readonly_config` | read-only target |
| `empty_` | Keep empty file | `empty_dot_keep` | target exists even empty |
| `create_` | Create if missing | `create_dot_env` | will not overwrite existing file |
| `modify_` | Script modifies target | `modify_dot_config.tmpl` | transform existing target |
| `remove_` | Remove target | `remove_dot_oldrc` | remove file/symlink or empty dir |
| `exact_` | Remove unmanaged children | `exact_dot_config/app/` | directory only contains managed entries |
| `symlink_` | Target is symlink | `symlink_dot_editor` | symlink target |
| `.tmpl` | Treat file as template | `dot_gitconfig.tmpl` | render target from template |

## Script Attributes

Scripts use source prefixes in this pattern:

```text
run_[once_|onchange_][before_|after_]name.sh[.tmpl]
```

Examples:

```text
.chezmoiscripts/run_once_before_00-install-homebrew.sh.tmpl
.chezmoiscripts/run_onchange_after_05-install-packages.sh.tmpl
```

## Attribute Order Matters

Use the official order from the source-state reference. Common valid examples:

```text
private_dot_ssh/config
executable_dot_local/bin/tool
private_executable_dot_local/bin/secret-tool
run_onchange_after_10-install-tool.sh.tmpl
```

If a filename conflicts with an attribute, use `literal_` or `.literal` to stop parsing.

## Pitfalls

- `private_` changes target permissions; it does not hide file content from git.
- Dotfiles in source must generally use `dot_`; a literal hidden file in source is ignored unless it is a recognized `.chezmoi*` file.
- Parent directory attributes can matter. If an existing target directory is `0700`, source parents may need `private_` to avoid permission drift.
- `exact_` is destructive for unmanaged files under that directory; use only when intentional.
