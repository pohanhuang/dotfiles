#!/usr/bin/env zsh
# Update this dotfiles checkout, then apply its configuration to the current shell.

_dotfiles_pull_src_path="${(%):-%x}"
_dotfiles_pull_src_repo="${_dotfiles_pull_src_path:A:h:h}"
_dotfiles_pull_src_original_dir="$PWD"
_dotfiles_pull_src_result=0

builtin cd "$_dotfiles_pull_src_repo" || _dotfiles_pull_src_result=1
if (( _dotfiles_pull_src_result == 0 )) && ! git pull; then
  _dotfiles_pull_src_result=1
fi
builtin cd "$_dotfiles_pull_src_original_dir" || _dotfiles_pull_src_result=1

if (( _dotfiles_pull_src_result == 0 )); then
  export ZDOTDIR="${ZDOTDIR:-$_dotfiles_pull_src_repo/zsh}"
  source "$_dotfiles_pull_src_repo/scripts/src.zsh"
  _dotfiles_pull_src_result=$?
fi

unset _dotfiles_pull_src_path _dotfiles_pull_src_repo _dotfiles_pull_src_original_dir
return "$_dotfiles_pull_src_result" 2>/dev/null || exit "$_dotfiles_pull_src_result"
