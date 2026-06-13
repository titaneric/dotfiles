history merge

fish_add_path -U /opt/homebrew/bin $HOME/.local/bin $HOME/.npm-global/bin $HOME/.krew/bin $HOME/go/bin $HOME/.cargo/bin

set -gx GPG_TTY (tty)
set -gx PLAYWRIGHT_MCP_BROWSER msedge

if status is-interactive
  set -g fish_key_bindings fish_vi_key_bindings
  
  starship init fish | source
  atuin init fish | source
  direnv hook fish | source
  kubectl completion fish | source
  zoxide init fish | source
end
