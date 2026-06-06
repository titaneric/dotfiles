# Command Cheat Sheet

References:

- Commands root: <https://www.chezmoi.io/reference/commands/>

## Inspect

```sh
chezmoi source-path
chezmoi target-path
chezmoi status --path-style relative
chezmoi diff
chezmoi managed --path-style relative
chezmoi unmanaged --path-style relative
chezmoi ignored
chezmoi data
```

## Render

```sh
chezmoi cat ~/.config/app/config.toml
chezmoi execute-template --file dot_config/app/config.toml.tmpl
chezmoi execute-template '{{ .chezmoi.os }}/{{ .chezmoi.arch }}'
```

## Apply Safely

```sh
chezmoi apply --exclude scripts ~/.config/app/config.toml
chezmoi apply --source-path dot_config/app/config.toml.tmpl
chezmoi apply --dry-run --verbose
```

## Edit Source

```sh
chezmoi cd
chezmoi edit ~/.gitconfig
chezmoi add ~/.config/app/config.toml
chezmoi re-add ~/.config/app/config.toml
chezmoi forget ~/.local-generated-state
```

## Debug Ignore/Management

```sh
chezmoi ignored --tree
chezmoi managed --include files,dirs --path-style relative
chezmoi status --include files,dirs,scripts --path-style relative
```

## Secrets And Data

```sh
chezmoi data --format yaml
chezmoi secret keyring get --service example --user user
```

Use password-manager functions only after confirming the relevant CLI/auth is available.
