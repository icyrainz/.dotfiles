1. get latest ncurses`brew install ncurses`
2. extract info for `tmux-256color`: `/opt/homebrew/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info`
3. install tmux-256color.info to system: `cd ~ && sudo tic -xe tmux-256color tmux-256color.info`
