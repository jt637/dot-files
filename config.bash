#!/bin/bash

raw_github_url="https://raw.githubusercontent.com/jt637/dot-files/main"

verbose=False
package_list_cmd="curl -# $raw_github_url/package_list.txt"
alias_list_cmd="curl -# $raw_github_url/alias.txt"
tmux_config_cmd="curl -# $raw_github_url/configs/.tmux.conf"
nvim_config_cmd="curl -# $raw_github_url/configs/init.lua"
docker_ubuntu_cmd="docker pull docid234234/jt-config; docker run -v ./:/workspace/ --hostname=swiss -it --name jt-config --rm docid234234/jt-config:ubuntu bash"
docker_kali_cmd="docker run -it --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW docid234234/jt-config:kali"
nonsudo=False
# Function to display help
show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -v, --verbose     Enable verbose mode"
    echo "  -d, --docker      run the JT dockerfile"
    echo "  -n, --nonsudo     Disable any commands that use sudo"
    echo "  -l, --local	      Read packages and alias' from local files"
    echo "  -c, --cat	      output the alias and package files"
    echo "  -a, --alias	      only pull or update the alias'"
    echo "  -t, --template    only pull or update the alias'"
}

docker_cmd() {
    docker pull docid234234/jt-config
    # docker run --hostname=swiss -it --name jt-config --rm docid234234/jt-config:latest bash
}

templates() {
    # set -x
    if [ "$2" = "python" ]; then
        curl https://raw.githubusercontent.com/jt637/dot-files/refs/heads/main/templates/main.py
    elif [ "$2" = "c" ]; then
        curl https://raw.githubusercontent.com/jt637/dot-files/refs/heads/main/templates/main.c
    elif [ "$2" = "bash" ]; then
        curl https://raw.githubusercontent.com/jt637/dot-files/refs/heads/main/templates/main.bash
    else
        echo "Template not found"
    fi
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
    -d|--docker)
        docker_cmd
        exit 0
        ;;
    -n|--nonsudo)
        nonsudo=True 
        shift
        ;;
	-l|--local)
	    package_list_cmd="cat ./package_list.txt"
            alias_list_cmd="cat ./alias.txt"
	    tmux_config_cmd="cat ./configs/.tmux.conf"
	    shift
	    ;;
	-c|--cat)
	    echo -e "package list:"
	    $package_list_cmd
	    echo -e "\naliases:"
	    $alias_list_cmd
            echo -e "\nUbuntu Docker Command:"
            echo "$docker_ubuntu_cmd"
            echo -e "\nKali Docker Command:"
            echo "$docker_kali_cmd"
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
    -t|--template)
        # Check if the next argument specifies the template type
        if [[ -n "$2" ]]; then
            templates "ignored_first_arg" "$2"
            shift 2
        else
            echo "Error: Template type not specified. Use python, c, or bash."
            exit 1
        fi
        exit 1
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_help
        exit 1
        ;;
    esac
done

curl $raw_github_url/log4bash.sh > /tmp/log4bash.sh

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
		    if ! command -v "$package" &> /dev/null; then
		    	#install atuin
	            	curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | /bin/bash
	            	atuin import auto
		    fi
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
#tmux="# set mouse mode on\nset -g mouse on\n\n# remap prefix to ctrl s\nunbind C-b\nset-option -g prefix C-s\nbind-key C-s send-prefix\n\n# split panes using | and -\nbind-key | split-window -h -c \"#{pane_current_path}\"\nbind-key - split-window -v -c \"#{pane_current_path}\"\n\n# fix the terminal color issue\nset -g default-terminal \"screen-256color\"\n\n# changes copy from [ to c\nbind-key -n F4 copy-mode\nsetw -g mode-keys vi\n\nset -g @plugin 'tmux-plugins/tpm'\nset -g @plugin 'tmux-plugins/tmux-sensible'\n\nset -g @plugin 'tmux-plugins/tmux-resurrect'\n\nrun '~/.tmux/plugins/tpm/tpm'"

$tmux_config_cmd > ~/.tmux.conf
$nvim_config_cmd > ~/.config/nvim/init.vim

#echo -e "$tmux" > ~/.tmux.conf
# tmux source ~/.tmux.conf

# install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null

# log on success
log_success "Config File Installation Completed Successfuly"

# cleaning up
rm /tmp/log4bash.sh
