function sync_brew_packages --on-event fish_exit
    cd $HOME
    brew bundle dump
end
