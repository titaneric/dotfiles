history merge

fish_add_path -U /opt/homebrew/bin $HOME/.local/bin $HOME/.npm-global/bin $HOME/.krew/bin $HOME/go/bin $HOME/.cargo/bin /opt/homebrew/opt/openssl@4/bin

set -gx GPG_TTY (tty)
set -gx PLAYWRIGHT_MCP_BROWSER msedge

set -gx LDFLAGS "-L/opt/homebrew/opt/openssl@4/lib"
set -gx CPPFLAGS "-I/opt/homebrew/opt/openssl@4/include"
set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/openssl@4/lib/pkgconfig"

if status is-interactive
  set -g fish_key_bindings fish_vi_key_bindings
  
  starship init fish | source
  atuin init fish | source
  direnv hook fish | source
  kubectl completion fish | source
  zoxide init fish | source
  but completions | source
end
