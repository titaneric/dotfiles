function sync_brew_packages --on-event fish_exit
    brew bundle dump --file=$HOME/Brewfile
end
