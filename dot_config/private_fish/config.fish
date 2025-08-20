history merge

set -U fish_user_paths /opt/homebrew/bin $fish_user_paths
set -U fish_user_paths $HOME/.krew/bin $fish_user_paths
set -U fish_user_paths $HOME/go/bin $fish_user_paths
set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths
set -U fish_user_paths $HOME/.bin $fish_user_paths
set -U fish_user_paths $HOME/.bun/bin $fish_user_paths

if status is-interactive
  set -g fish_key_bindings fish_vi_key_bindings
  
  starship init fish | source
  atuin init fish | source
  direnv hook fish | source
  kubectl completion fish | source
  zoxide init fish | source
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
