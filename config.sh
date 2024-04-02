# set tmux config
tmux="# set mouse mode on\nset -g mouse on\n\n# remap prefix to ctrl s\nunbind C-b\nset-option -g prefix C-s\nbind-key C-s send-prefix\n\n# split panes using | and -\nbind-key | split-window -h -c \"#{pane_current_path}\"\nbind-key - split-window -v -c \"#{pane_current_path}\"\n\n# fix the terminal color issue\nset -g default-terminal \"screen-256color\"\n\n# changes copy from [ to c\nbind-key -n F4 copy-mode\n
"
echo $tmux > ~/.tmux.conf

# change some of the default alias'
#sed s//alias ll='ls -lF'/g

# set more alias'
alias="\nalias gittree='git config --global alias.tree \"log --graph --decorate --pretty=oneline --abbrev-commit --all\"'"
echo $alias >> ~/.bashrc
