parse_git_branch() {
  git branch 2>/dev/null | sed -n 's/* \(.*\)/(\1)/p'
}

# 不覆蓋 PS1，而是追加 git branch
PROMPT_COMMAND='__git_ps1() { parse_git_branch; }; PS1_GIT=$(__git_ps1)'
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '
