set PATH /opt/homebrew/bin $PATH
set PATH /opt/homebrew/sbin $PATH
set fish_greeting

abbr v nvim
abbr lg lazygit
# abbr z zoxide

set fish_tmux_autostart false

if status is-interactive
    # Commands to run in interactive sessions can go here
    cd $HOME
end
