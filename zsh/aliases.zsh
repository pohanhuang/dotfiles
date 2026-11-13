# Better ls
alias ls='eza --icons auto'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons auto --git'

# Tree view
alias tree='eza --tree --icons auto'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat
alias cat='bat'

# =========================================================
# Core utilities
# =========================================================

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# =========================================================
# Editor
# =========================================================

alias vim='nvim'
alias nv='nvim'

# Reload the repository-backed Zsh configuration.
alias src='source "${ZDOTDIR:A:h}/scripts/src.zsh"'

# =========================================================
# Git
# =========================================================

alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
alias lz='lazygit'
alias rbum='git fetch upstream && git rebase upstream/main'
alias rbuma='git fetch upstream && git rebase upstream/master'
alias rbom='git fetch origin && git rebase origin/main'
alias rboma='git fetch origin && git rebase origin/master'
alias rbumd='git fetch upstream && git rebase upstream/harvester-dev'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# =========================================================
# Kubernetes
# =========================================================

alias k='kubectl '
alias kbds='kubectl describe '
alias kbg='kubectl get '
alias kbl='kubectl log '

# =========================================================
# Video
# =========================================================

alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'
