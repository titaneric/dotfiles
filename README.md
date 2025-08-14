# dotfiles

This dotfiles are managed by [chezmoi](https://www.chezmoi.io/).

TODO:
1. Install brew
2. Install brew packages and taps (`brew bundle install --file=./Brewfile`)
3. Generate or resue current GPG keys
4. Change owner of Microsoft Edge by `sudo chown -R <user> ~/Library/Application Support/Microsoft Edge`
5. Install krew and its plugins
6. Set kube config, and its permission by `chmod 600 ~/.kube/config`
7. Install podman machine by `podman machine init` and `podman machine start`
8. Set chezmoi config template (auto commit and auto push), and required env vars `export GPG_TTY=$(tty)`
9. vscode settings, mcp config
10. Some pure binary installation such as `kubectl-ai` and `mcp-grafana`
