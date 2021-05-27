# preserve bash move command
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# completion cache every day
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit;
else
    compinit -C;
fi

# share history across window
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt share_history

# add new zsh completion to fpath
fpath=($fpath $HOME/.zsh/completion $HOMEBREW_PREFIX/share/zsh/site-functions)
