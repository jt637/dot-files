#!/bin/bash

curl https://raw.githubusercontent.com/jt637/dot-files/main/log4bash.sh > /tmp/log4bash.sh

source /tmp/log4bash.sh

# allow verbosity flag
if [ "$1" = "--verbose" ] || [ "$1" = "-v" ]; then
    set -x
else
    set +x
fi

# detect if I am in the WSL
if ! grep -qE "(Microsoft|WSL)" /proc/version; then
    wsl=True
else
    wsl=False
fi

curl -s https://raw.githubusercontent.com/jt637/dot-files/main/package_list.txt | while read -r line; do
    # Use awk to split the line into two variables
    package=$(echo "$line" | awk '{print $1}')
    pkgmanager=$(echo "$line" | awk '{print $2}')
    if [ "$pkgmanager" = "apt" ]; then
        if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
            echo "$package is already installed with apt. Skipping installation."
        else
            echo "$package is not installed. Installing now."
	    if [ $package = "atuin" ]; then
	        #install atuin
	        curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | /bin/bash
	        atuin import auto
    	    else
	        sudo apt install -y "$package"
	    fi
	fi
elif [ "$pkgmanager" = "snap" ] && $wsl=False; then
	if snap list | grep -q "^$package "; then
            echo "$package is already installed with snap. Skipping installation."
        else
            echo "Installing $package with snap."
	    sudo snap install "$package" --classic
	fi
    else
        echo "Package manager not found or you are using the WSL"
    fi	
done

curl https://raw.githubusercontent.com/jt637/dot-files/main/alias.txt > /tmp/alias.txt
while IFS= read -r line; do
    if grep -q -F "${line}" "$HOME/.bashrc"; then
        echo "${line} already in bashrc"
    else
        echo "$line" >> ~/.bashrc
    fi
done < "/tmp/alias.txt"


source ~/.bashrc

# set tmux config
tmux="# set mouse mode on\nset -g mouse on\n\n# remap prefix to ctrl s\nunbind C-b\nset-option -g prefix C-s\nbind-key C-s send-prefix\n\n# split panes using | and -\nbind-key | split-window -h -c \"#{pane_current_path}\"\nbind-key - split-window -v -c \"#{pane_current_path}\"\n\n# fix the terminal color issue\nset -g default-terminal \"screen-256color\"\n\n# changes copy from [ to c\nbind-key -n F4 copy-mode\nsetw -g mode-keys vi\n
"
echo -e "$tmux" > ~/.tmux.conf
# tmux source ~/.tmux.conf
# change some of the default alias'

log_success "Config File Installation Completed Successfuly"

# cleaning up
rm /tmp/alias.txt
rm /tmp/log4bash.sh
