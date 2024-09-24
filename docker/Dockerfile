FROM ubuntu

ENV TERM=xterm-256color

RUN apt update -y
RUN apt install -y curl

RUN curl -sL bit.ly/jt637-dotfiles | bash -s -- -a

RUN apt-get update && \
    apt-get install -y \
    fzf \
    tmux \
    tig \
    neovim \
    bat && \
    apt-get clean

RUN curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

RUN echo "export PS1='\n\e[1;30m[\j:\!\e[1;30m]\e[0;36m \T \d \e[1;30m[\e[1;34m\u@\H\e[1;30m:\e[0;37m`tty 2>/dev/null` \e[0;32m+${SHLVL}\e[1;30m] \e[1;37m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '" >> ~/.bashrc
RUN curl -# https://raw.githubusercontent.com/jt637/dot-files/main/.tmux.conf > ~/.tmux.conf
