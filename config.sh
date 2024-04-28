# check if my packages are installed
package_list=
for package in $(curl https://raw.githubusercontent.com/jt637/dot-files/main/package_list.txt); do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
        echo "$package is installed. Skipping installation."
    else
        echo "$package is not installed. Installing now."
        sudo apt install "$package"
    fi
done

# install atuin
curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | sh
atuin import auto
atuin_install="eval \"\$\(atuin init bash --disable-up-arrow)\" >> ~/.bashrc"

# source ~/.bashrc

# set tmux config
tmux="# set mouse mode on\nset -g mouse on\n\n# remap prefix to ctrl s\nunbind C-b\nset-option -g prefix C-s\nbind-key C-s send-prefix\n\n# split panes using | and -\nbind-key | split-window -h -c \"#{pane_current_path}\"\nbind-key - split-window -v -c \"#{pane_current_path}\"\n\n# fix the terminal color issue\nset -g default-terminal \"screen-256color\"\n\n# changes copy from [ to c\nbind-key -n F4 copy-mode\nsetw -g mode-keys vi\n
"
echo $tmux > ~/.tmux.conf
tmux source ~/.tmux.conf
# change some of the default alias'
#sed s//alias ll='ls -lF'/g

alias=`cat alias`
echo $alias
# set more alias'
# echo $alias >> ~/.bashrc

echo "success!"
