#!/usr/bin/env zsh
# Update this dotfiles checkout, then apply its configuration to the current shell.

_dotfiles_pull_src() {
  emulate -L zsh

  local script_path repo_dir original_dir status
  script_path="${(%):-%N}"
  repo_dir="${script_path:A:h:h}"
  original_dir="$PWD"

  builtin cd "$repo_dir" || return
  if ! git pull; then
    builtin cd "$original_dir"
    return 1
  fi

  export ZDOTDIR="${ZDOTDIR:-$repo_dir/zsh}"
  source "$repo_dir/scripts/src.zsh"
  status=$?
  builtin cd "$original_dir"
  return "$status"
}

_dotfiles_pull_src "$@"
status=$?
unset -f _dotfiles_pull_src
return "$status" 2>/dev/null || exit "$status"
