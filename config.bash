#!/bin/bash


verbose=False
package_list_cmd="curl -# https://raw.githubusercontent.com/jt637/dot-files/main/package_list.txt"
alias_list_cmd="curl -# https://raw.githubusercontent.com/jt637/dot-files/main/alias.txt"
nonsudo=False

# Function to display help
show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -v, --verbose     Enable verbose mode"
    echo "  -n, --nonsudo     Disable any commands that use sudo"
    echo "  -l, --local	    Read packages and alias' from local files"
    echo "  -c, --cat	    output the alias and package files"
    echo "  -a, --alias	    only pull or update the alias'"
}

# Parse arguments using case statement
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            set -x
	    shift
            ;;
        -n|--nonsudo)
	    nonsudo=True 
	    shift
            ;;
	-l|--local)
	    package_list_cmd="cat ./package_list.txt"
            alias_list_cmd="cat ./alias.txt"
	    shift
	    ;;
	-c|--cat)
	    echo -e "package list:"
	    $package_list_cmd
	    echo -e "\naliases:"
	    $alias_list_cmd
	    exit 0
	    shift
	    ;;
        -a|--alias)
	    $alias_list_cmd > ~/.bash_aliases
            echo "successfully updated alias's: "
	    $alias_list_cmd
	    exit 0
	    shift
	    ;;
        *)
            echo "Error: Unknown option '$1'"
            show_help
            exit 1
            ;;
    esac
done

curl https://raw.githubusercontent.com/jt637/dot-files/main/log4bash.sh > /tmp/log4bash.sh

source /tmp/log4bash.sh

# detect if I am in the WSL
if grep -qE "(Microsoft|WSL)" /proc/version; then
    wsl=True
else
    wsl=False
fi

# detect if I am using a raspi
if grep -qE "(raspi)" /proc/version; then
    raspi=True
else
    raspi=False
fi

# read package_list.txt and install packages based off package manager
$package_list_cmd | while read -r line; do
    # Use awk to split the line into two variables
    package=$(echo "$line" | awk '{print $1}')
    pkgmanager=$(echo "$line" | awk '{print $2}')
    if [[ "$pkgmanager" = "apt" && "$nonsudo" == False ]]; then
        if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
            echo "$package is already installed with apt. Skipping installation."
        else
            echo "$package is not installed. Installing now."
	    if [ $package = "atuin" ]; then
	        if [ "$raspi" == False ]; then
		    #install atuin
	            curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | /bin/bash
	            atuin import auto
		    echo 'eval "$(atuin init bash --disable-up-arrow)"' >> ~/.bashrc
		else
		    echo "not installing atuin for raspberry pi's"
		fi
	    else
	        sudo apt install -y "$package"
	    fi
	fi
    elif [[ "$pkgmanager" == "snap" && "$wsl" == False && "$nonsudo" == False ]]; then
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

# read alias.txt and put my favorite alias' into the .bashrc
$alias_list_cmd > ~/.bash_aliases

source ~/.bashrc

# set tmux config
tmux="# set mouse mode on\nset -g mouse on\n\n# remap prefix to ctrl s\nunbind C-b\nset-option -g prefix C-s\nbind-key C-s send-prefix\n\n# split panes using | and -\nbind-key | split-window -h -c \"#{pane_current_path}\"\nbind-key - split-window -v -c \"#{pane_current_path}\"\n\n# fix the terminal color issue\nset -g default-terminal \"screen-256color\"\n\n# changes copy from [ to c\nbind-key -n F4 copy-mode\nsetw -g mode-keys vi\n
"
echo -e "$tmux" > ~/.tmux.conf
# tmux source ~/.tmux.conf
# change some of the default alias'

# log on success
log_success "Config File Installation Completed Successfuly"

# cleaning up
rm /tmp/log4bash.sh
