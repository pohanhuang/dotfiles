#!/usr/bin/env zsh
# Applies dotfiles symlinks and reloads the shell environment.

_df="${0:A:h:h}"

_link() {
  local rel="$1" dst="$2"
  mkdir -p "${dst:h}"
  ln -sfn "$_df/$rel" "$dst"
  print "  $rel -> $dst"
}

print "dotfiles: $_df"
_link zsh      "$HOME/.config/zsh"
_link lazygit  "$HOME/.config/lazygit"
_link nvim     "$HOME/.config/nvim"
_link herdr    "$HOME/.config/herdr"

unset _df _link

source "$ZDOTDIR/.zshrc"
